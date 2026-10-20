#let _plugin = plugin("bulb_typst.wasm")

#let _dither-methods = (
  "bayer2x2": 0,
  "bayer4x4": 1,
  "bayer8x8": 2,
  "cluster4": 3,
  "cluster6": 4,
  "cluster8": 5,
  "noise": 6,
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

#let _modes = (
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
// - `data`: image bytes (PNG or JPEG), e.g. `read("photo.png", encoding: none)`
// - `mode`: `"bw"` (black & white), `"rgb"` (multi-level), or `"palette"` (extracted palette)
// - `method`: dither method — `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`,
//   `"cluster4"`, `"cluster6"`, `"cluster8"`, `"noise"`
// - `size`: max pixel size of the longest axis; `none` to keep original
// - `filter`: resize filter: `"nearest"` (default), `"triangle"`, `"catmull-rom"`,
//   `"gaussian"`, `"lanczos3"`. Nearest is fastest, Lanczos3 highest quality.
// - `levels`: colour levels per channel (rgb mode only, default 3)
// - `colors`: total palette colours (palette mode only, default 8)
// - `accent`: FPS accent colours for hybrid mode (default: colors / 3)
// - `palette-method`: `"hybrid"`, `"fps"`, or `"kmeans"`
// - `linear`: linear light for palette selection (default true)
// - `perceptual-cap`: cap dominant colour weight (default false)
// - `gamma`: gamma correction applied before dithering (default 1.0, no change)
// - `contrast`: contrast multiplier around 0.5 (default 1.0, no change)
// - `brightness`: additive brightness offset in [-1, 1] (default 0.0, no change)
// - `edge-threshold`: `none` (default, off) or a non-negative number.
//   When set, pixels whose normalised Sobel gradient magnitude on luminance
//   exceeds the threshold are snapped to the nearest level/colour (no Bayer or
//   cluster modulation). Smaller values snap more pixels. Works in all modes.
// - `palette`: `none` to extract (default), a preset name string
//   (`"gameboy"`, `"nes"`, `"cga"`, `"pico8"`, `"mac"`, `"c64"`), or an array
//   of colours. Each entry can be a hex string (`"#000000"`) or a Typst colour
//   (`red`, `rgb("#ff8800")`, `hsl(...)`). When given, `mode` defaults to
//   `"palette"`; passing any other explicit mode is an error.
#let dither(
  data,
  mode: auto,
  method: "bayer8x8",
  size: none,
  filter: "nearest",
  levels: 3,
  colors: 8,
  accent: none,
  palette-method: "hybrid",
  linear: true,
  perceptual-cap: false,
  gamma: 1.0,
  contrast: 1.0,
  brightness: 0.0,
  edge-threshold: none,
  palette: none,
) = {
  if mode == auto {
    mode = if palette != none { "palette" } else { "rgb" }
  } else if palette != none {
    assert(
      mode == "palette",
      message: "palette requires mode: \"palette\" (or leave mode unset), got mode: "
        + repr(mode),
    )
  }
  assert(
    mode in _modes,
    message: "unknown mode: "
      + repr(mode)
      + ", expected one of: "
      + repr(_modes.keys()),
  )
  assert(
    method in _dither-methods,
    message: "unknown method: "
      + repr(method)
      + ", expected one of: "
      + repr(_dither-methods.keys()),
  )
  assert(
    size == none or (type(size) == int and size > 0),
    message: "size must be none or a positive integer, got " + repr(size),
  )
  assert(
    filter in _resize-filters,
    message: "unknown filter: "
      + repr(filter)
      + ", expected one of: "
      + repr(_resize-filters.keys()),
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
    edge-threshold == none
      or (type(edge-threshold) in (int, float) and edge-threshold >= 0),
    message: "edge-threshold must be none or a non-negative number, got "
      + repr(edge-threshold),
  )

  if mode == "palette" {
    assert(
      levels == 3,
      message: "levels is not used in palette mode (did you mean colors?)",
    )
  } else {
    assert(
      type(levels) == int and levels >= 2,
      message: "levels must be an integer >= 2, got " + repr(levels),
    )
    assert(
      colors == 8,
      message: "colors is only used in palette mode, not " + repr(mode),
    )
    assert(
      accent == none,
      message: "accent is only used in palette mode, not " + repr(mode),
    )
    assert(
      palette-method == "hybrid",
      message: "palette-method is only used in palette mode, not " + repr(mode),
    )
    assert(
      linear == true,
      message: "linear is only used in palette mode, not " + repr(mode),
    )
    assert(
      perceptual-cap == false,
      message: "perceptual-cap is only used in palette mode, not " + repr(mode),
    )
  }

  if mode == "palette" {
    if palette == none {
      assert(
        type(colors) == int and colors >= 2,
        message: "colors must be an integer >= 2, got " + repr(colors),
      )
      assert(
        accent == none or (type(accent) == int and accent >= 0),
        message: "accent must be none or a non-negative integer, got "
          + repr(accent),
      )
      assert(
        palette-method in _palette-methods,
        message: "unknown palette-method: "
          + repr(palette-method)
          + ", expected one of: "
          + repr(_palette-methods.keys()),
      )
    } else {
      assert(
        (type(palette) == str and palette in _presets)
          or (type(palette) == array and palette.len() >= 2),
        message: "palette must be none, a preset name in "
          + repr(_presets.keys())
          + ", or an array of >= 2 hex colours, got "
          + repr(palette),
      )
      assert(
        colors == 8,
        message: "colors is ignored when palette is given; remove it",
      )
      assert(
        accent == none,
        message: "accent is ignored when palette is given; remove it",
      )
      assert(
        palette-method == "hybrid",
        message: "palette-method is ignored when palette is given; remove it",
      )
      assert(
        linear == true,
        message: "linear is ignored when palette is given; remove it",
      )
      assert(
        perceptual-cap == false,
        message: "perceptual-cap is ignored when palette is given; remove it",
      )
    }
  } else {
    assert(
      palette == none,
      message: "palette requires mode: \"palette\", got mode: " + repr(mode),
    )
  }

  let mode-id = _modes.at(mode)
  let method-id = _dither-methods.at(method)
  let max-size = if size == none { 0 } else { size }

  let param1 = if mode == "palette" { colors } else { levels }
  let n-accent = if accent == none { calc.quo(colors, 3) } else { accent }
  let param2 = n-accent

  let pal-id = _palette-methods.at(palette-method)
  let filter-id = _resize-filters.at(filter)
  let flags = (
    (if linear { 1 } else { 0 })
      + (if perceptual-cap { 2 } else { 0 })
      + filter-id * 16
  )

  let palette-source = 0
  let preset-id = 0
  let custom-palette-bytes = bytes(())
  let custom-palette-len = 0
  if type(palette) == str {
    palette-source = 1
    preset-id = _presets.at(palette)
  } else if type(palette) == array {
    palette-source = 2
    custom-palette-len = palette.len()
    for hex in palette {
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

  _plugin.dither(header + custom-palette-bytes + data)
}
