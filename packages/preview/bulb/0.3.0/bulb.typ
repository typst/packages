#let _plugin = plugin("bulb_typst.wasm")

#let _dither-methods = (
  "bayer2x2": 0,
  "bayer4x4": 1,
  "bayer8x8": 2,
  "cluster4": 3,
  "cluster6": 4,
  "cluster8": 5,
  "bayer2": 0,
  "bayer4": 1,
  "bayer8": 2,
)

#let _palette-methods = (
  "hybrid": 0,
  "fps": 1,
  "kmeans": 2,
)

#let _resize-filters = (
  "nearest": 0,
  "triangle": 1,
  "catmull-rom": 2,
  "gaussian": 3,
  "lanczos3": 4,
)

// Internal wire ids for the three kinds of colour target. Kept private: users
// select a target through the single `colors` parameter, not by naming a mode.
#let _targets = (
  "bw": 0,
  "rgb": 1,
  "palette": 2,
)

#let _presets = (
  "gameboy": 0,
  "nes": 1,
  "cga": 2,
  "pico8": 3,
  "mac": 4,
  "c64": 5,
)

// Convert a hex string or a Typst color into a (r, g, b) u8 triple.
#let _to-rgb-triple(c) = {
  let comps = rgb(c).components(alpha: false)
  comps.map(r => int(calc.round(r / 100% * 255)))
}

#let _u32-le(n) = {
  bytes((
    calc.rem(n, 256),
    calc.rem(calc.quo(n, 256), 256),
    calc.rem(calc.quo(n, 65536), 256),
    calc.rem(calc.quo(n, 16777216), 256),
  ))
}

// Fixed-point scale shared with the Rust side (must match FIXED_SCALE in src/lib.rs).
#let _fixed-scale = 10000

// Encode a float as i32 little-endian after multiplying by _fixed-scale.
#let _fixed-le(x) = {
  let n = int(calc.round(x * _fixed-scale))
  if n < 0 { n = n + 4294967296 }
  _u32-le(n)
}

// Dither an image. Returns PNG bytes suitable for passing to `image()`.
//
// - `path`: a `path` object that resolves to a JPEG or PNG image
// - `colors`: the colours the output may use. One of:
//   - `"bw"`: black and white (grayscale, two levels)
//   - `"rgb"`: a uniform grid of `levels` values per RGB channel
//   - an integer `n` >= 2: generate an `n`-colour palette from the image
//   - a preset name: `"gameboy"`, `"nes"`, `"cga"`, `"pico8"`, `"mac"`, `"c64"`
//   - an array of >= 2 colours (hex strings or Typst colours)
// - `method`: dither method — `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`,
//   `"cluster4"`, `"cluster6"`, `"cluster8"`
// - `size`: max pixel size of the longest axis; `none` to keep original
// - `filter`: resize filter: `"nearest"` (default), `"triangle"`, `"catmull-rom"`,
//   `"gaussian"`, `"lanczos3"`. Nearest is fastest, Lanczos3 highest quality.
// - `levels`: colour levels per channel (`colors: "rgb"` only, default 3)
// - `accent`: accent colours for the hybrid palette generator
//   (`colors: <int>` only, defaults to one third of the requested colours)
// - `palette-method`: `"hybrid"`, `"fps"`, or `"kmeans"` (`colors: <int>` only)
// - `linear`: linear light for palette selection (`colors: <int>` only, default true)
// - `perceptual-cap`: cap dominant colour weight (`colors: <int>` only, default false)
// - `transparent`: dither alpha channel to on/off for images with an alpha channel (default true)
// - `gamma`: gamma correction applied before dithering (default 1.0, no change)
// - `contrast`: contrast multiplier around 0.5 (default 1.0, no change)
// - `brightness`: additive brightness offset in [-1, 1] (default 0.0, no change)
// - `edge-threshold`: `none` (default, off) or a non-negative number.
//   When set, pixels whose normalised Sobel gradient magnitude on luminance
//   exceeds the threshold are snapped to the nearest level/colour (no Bayer or
//   cluster modulation). Smaller values snap more pixels. Works with every
//   colour target.
#let dither(
  path,
  colors: "rgb",
  method: "bayer8x8",
  size: none,
  filter: "nearest",
  levels: 3,
  accent: none,
  palette-method: "hybrid",
  linear: true,
  perceptual-cap: false,
  transparent: true,
  gamma: 1.0,
  contrast: 1.0,
  brightness: 0.0,
  edge-threshold: none,
) = {
  // Resolve the single `colors` argument into an internal target plus palette
  // source. `num-colors` is only meaningful when generating a palette.
  let mode = "palette"
  let palette-source = 0
  let preset-id = 0
  let num-colors = 8
  if colors == "bw" {
    mode = "bw"
  } else if colors == "rgb" {
    mode = "rgb"
  } else if type(colors) == int {
    assert(
      colors >= 2,
      message: "colors must be an integer >= 2 to generate a palette, got " + repr(colors),
    )
    num-colors = colors
  } else if type(colors) == str {
    assert(
      colors in _presets,
      message: "unknown color preset: " + repr(colors) + ", expected one of: " + repr(_presets.keys()),
    )
    palette-source = 1
    preset-id = _presets.at(colors)
  } else if type(colors) == array {
    assert(
      colors.len() >= 2,
      message: "colors must contain at least 2 colours, got " + repr(colors.len()),
    )
    palette-source = 2
  } else {
    panic(
      "colors must be \"bw\", \"rgb\", an integer >= 2, a preset name in "
        + repr(_presets.keys())
        + ", or an array of >= 2 colours, got "
        + repr(colors),
    )
  }

  assert(
    method in _dither-methods,
    message: "unknown method: " + repr(method) + ", expected one of: " + repr(_dither-methods.keys()),
  )
  assert(
    size == none or (type(size) == int and size > 0),
    message: "size must be none or a positive integer, got " + repr(size),
  )
  assert(
    filter in _resize-filters,
    message: "unknown filter: " + repr(filter) + ", expected one of: " + repr(_resize-filters.keys()),
  )
  assert(
    type(gamma) in (int, float) and gamma > 0,
    message: "gamma must be a positive number, got " + repr(gamma),
  )
  assert(
    type(contrast) in (int, float),
    message: "contrast must be a number, got " + repr(contrast),
  )
  assert(
    type(brightness) in (int, float) and brightness >= -1 and brightness <= 1,
    message: "brightness must be a number in [-1, 1], got " + repr(brightness),
  )
  assert(
    edge-threshold == none or (type(edge-threshold) in (int, float) and edge-threshold >= 0),
    message: "edge-threshold must be none or a non-negative number, got " + repr(edge-threshold),
  )

  if mode == "rgb" {
    assert(
      type(levels) == int and levels >= 2,
      message: "levels must be an integer >= 2, got " + repr(levels),
    )
  } else {
    assert(
      levels == 3,
      message: "levels is only used with colors: \"rgb\", got colors: " + repr(colors),
    )
  }

  if mode == "palette" and palette-source == 0 {
    // A palette is being generated from the image: the tuning knobs apply.
    assert(
      accent == none or (type(accent) == int and accent >= 0),
      message: "accent must be none or a non-negative integer, got " + repr(accent),
    )
    assert(
      palette-method in _palette-methods,
      message: "unknown palette-method: "
        + repr(palette-method)
        + ", expected one of: "
        + repr(_palette-methods.keys()),
    )
  } else {
    // Fixed colours (bw/rgb) or a fixed palette (preset/array): tuning is unused.
    let hint = "colors: an integer >= 2"
    assert(accent == none, message: "accent is only used with " + hint + ", got " + repr(accent))
    assert(
      palette-method == "hybrid",
      message: "palette-method is only used with " + hint + ", got " + repr(palette-method),
    )
    assert(linear == true, message: "linear is only used with " + hint + ", got " + repr(linear))
    assert(
      perceptual-cap == false,
      message: "perceptual-cap is only used with " + hint + ", got " + repr(perceptual-cap),
    )
  }

  let mode-id = _targets.at(mode)
  let method-id = _dither-methods.at(method)
  let max-size = if size == none { 0 } else { size }

  let param1 = if mode == "palette" { num-colors } else { levels }
  let n-accent = if accent == none { calc.quo(num-colors, 3) } else { accent }
  let param2 = n-accent

  let pal-id = _palette-methods.at(palette-method)
  let filter-id = _resize-filters.at(filter)
  let flags = (
    (if linear { 1 } else { 0 }) // first bit is linearity
      + (if perceptual-cap { 2 } else { 0 }) // second bit is perceptual-cap
      + if transparent { 4 } else { 0 } // third bit is transparrency
      // one padding bit
      + filter-id * 16 // three filter-id bits
    // one unused bit
  )

  let custom-palette-bytes = bytes(())
  let custom-palette-len = 0
  if palette-source == 2 {
    custom-palette-len = colors.len()
    for hex in colors {
      custom-palette-bytes = custom-palette-bytes + bytes(_to-rgb-triple(hex))
    }
  }

  // Header layout matches src/lib.rs. 38 bytes total + variable custom palette.
  let header = (
    bytes((mode-id, method-id))
      + _u32-le(max-size)
      + _u32-le(param1)
      + _u32-le(param2)
      + bytes((pal-id, flags))
      + _fixed-le(gamma)
      + _fixed-le(contrast)
      + _fixed-le(brightness)
      + (if edge-threshold == none { _u32-le(4294967295) } else { _fixed-le(edge-threshold) })
      + bytes((palette-source, preset-id))
      + _u32-le(custom-palette-len)
  )

  let data = read(path, encoding: none)

  _plugin.dither(header + custom-palette-bytes + data)
}
