#let _plugin = plugin("bulb_typst.wasm")

// Convert a hex string or a Typst color into a (r, g, b) u8 triple.
#let _to-rgb-triple(c) = {
  let comps = rgb(c).components(alpha: false)
  comps.map(r => int(calc.round(r / 100% * 255)))
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
// - `method`: dither method. Ordered: `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`,
//   `"cluster4"`, `"cluster6"`, `"cluster8"`. Error diffusion:
//   `"floyd-steinberg"` or '"floyd"', `"atkinson"`, `"jarvis"`, `"stucki"`, `"burkes"`,
//   `"sierra"`, `"sierra-two-row"`, `"sierra-lite"`, `"simple"`
// - `size`: max pixel size of the longest axis; `none` to keep original
// - `filter`: resize filter: `"nearest"` (default), `"triangle"`, `"catmull-rom"`,
//   `"gaussian"`, `"lanczos3"`. Nearest is fastest, Lanczos3 highest quality.
// - `levels`: colour levels per channel (rgb mode only, default 3)
// - `hull-weight`: how strongly a generated palette reaches for the extreme
//   colours of the image instead of its large areas (default 50.0)
// - `transparent`: dither alpha channel to on/off for images with an alpha channel (default true)
// - `gamma`: gamma correction applied before dithering (default 1.0, no change)
// - `contrast`: contrast multiplier around 0.5 (default 1.0, no change)
// - `brightness`: additive brightness offset in [-1, 1] (default 0.0, no change)
//
// Names (`colors` presets, `method`, `filter`) are checked by the plugin.
#let dither(
  path,
  colors: "rgb",
  method: "bayer8x8",
  size: none,
  filter: "nearest",
  levels: 3,
  hull-weight: 50.0,
  transparent: true,
  gamma: 1.0,
  contrast: 1.0,
  brightness: 0.0,
) = {
  let generated = type(colors) == int
  if generated {
    assert(
      colors >= 2,
      message: "colors must be an integer >= 2 to generate a palette, got " + repr(colors),
    )
  } else if type(colors) == array {
    assert(
      colors.len() >= 2,
      message: "colors must contain at least 2 colours, got " + repr(colors.len()),
    )
  } else {
    assert(
      type(colors) == str,
      message: "colors must be \"bw\", \"rgb\", an integer >= 2, a preset name, or an array of >= 2 colours, got "
        + repr(colors),
    )
  }

  assert(
    size == none or (type(size) == int and size > 0),
    message: "size must be none or a positive integer, got " + repr(size),
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

  if colors == "rgb" {
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

  if generated {
    assert(
      type(hull-weight) in (int, float) and hull-weight >= 0,
      message: "hull-weight must be a non-negative number, got " + repr(hull-weight),
    )
  } else {
    assert(
      hull-weight == 50.0,
      message: "hull-weight is only used with colors: an integer >= 2, got " + repr(hull-weight),
    )
  }

  let colors = if type(colors) == array { colors.map(_to-rgb-triple) } else { colors }

  // Field order matches `Options` in src/lib.rs. Numbers go through `float()`
  // because the plugin decodes them as CBOR floats, not integers.
  let options = (
    colors,
    levels,
    method,
    filter,
    size,
    transparent,
    float(gamma),
    float(contrast),
    float(brightness),
    float(hull-weight),
  )

  _plugin.dither(cbor.encode(options), read(path, encoding: none))
}
