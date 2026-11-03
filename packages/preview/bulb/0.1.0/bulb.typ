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

#let _modes = (
  "bw": 0,
  "rgb": 1,
  "palette": 2,
)

#let _u32-le(n) = {
  bytes((
    calc.rem(n, 256),
    calc.rem(calc.quo(n, 256), 256),
    calc.rem(calc.quo(n, 65536), 256),
    calc.rem(calc.quo(n, 16777216), 256),
  ))
}

// Dither an image. Returns PNG bytes suitable for passing to `image()`.
//
// - `data`: image bytes (PNG or JPEG), e.g. `read("photo.png", encoding: none)`
// - `mode`: `"bw"` (black & white), `"rgb"` (multi-level), or `"palette"` (extracted palette)
// - `method`: dither method — `"bayer2x2"`, `"bayer4x4"`, `"bayer8x8"`,
//   `"cluster4"`, `"cluster6"`, `"cluster8"`, `"noise"`
// - `size`: max pixel size of the longest axis; `none` to keep original
// - `levels`: colour levels per channel (rgb mode only, default 3)
// - `colors`: total palette colours (palette mode only, default 8)
// - `accent`: FPS accent colours for hybrid mode (default: colors / 3)
// - `palette-method`: `"hybrid"`, `"fps"`, or `"kmeans"`
// - `linear`: linear light for palette selection (default true)
// - `perceptual-cap`: cap dominant colour weight (default false)
#let dither(
  data,
  mode: "rgb",
  method: "bayer8x8",
  size: none,
  levels: 3,
  colors: 8,
  accent: none,
  palette-method: "hybrid",
  linear: true,
  perceptual-cap: false,
) = {
  assert(mode in _modes, message: "unknown mode: " + repr(mode) + ", expected one of: " + repr(_modes.keys()))
  assert(
    method in _dither-methods,
    message: "unknown method: " + repr(method) + ", expected one of: " + repr(_dither-methods.keys()),
  )
  assert(
    size == none or (type(size) == int and size > 0),
    message: "size must be none or a positive integer, got " + repr(size),
  )

  if mode == "palette" {
    assert(levels == 3, message: "levels is not used in palette mode (did you mean colors?)")
  } else {
    assert(type(levels) == int and levels >= 2, message: "levels must be an integer >= 2, got " + repr(levels))
    assert(colors == 8, message: "colors is only used in palette mode, not " + repr(mode))
    assert(accent == none, message: "accent is only used in palette mode, not " + repr(mode))
    assert(palette-method == "hybrid", message: "palette-method is only used in palette mode, not " + repr(mode))
    assert(linear == true, message: "linear is only used in palette mode, not " + repr(mode))
    assert(perceptual-cap == false, message: "perceptual-cap is only used in palette mode, not " + repr(mode))
  }

  if mode == "palette" {
    assert(type(colors) == int and colors >= 2, message: "colors must be an integer >= 2, got " + repr(colors))
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
  }

  let mode-id = _modes.at(mode)
  let method-id = _dither-methods.at(method)
  let max-size = if size == none { 0 } else { size }

  let param1 = if mode == "palette" { colors } else { levels }
  let n-accent = if accent == none { calc.quo(colors, 3) } else { accent }
  let param2 = n-accent

  let pal-id = _palette-methods.at(palette-method)
  let flags = (if linear { 1 } else { 0 }) + (if perceptual-cap { 2 } else { 0 })

  let header = (
    bytes((mode-id, method-id)) + _u32-le(max-size) + _u32-le(param1) + _u32-le(param2) + bytes((pal-id, flags))
  )

  _plugin.dither(header + data)
}
