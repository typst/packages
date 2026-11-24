/// Parse a color from string or pass through a Typst color value.
/// Accepts: "red", "blue", "#ff0000", rgb(255, 0, 0), etc.
#let parse-color(c) = {
  if c == auto { return auto }
  if type(c) == str {
    let named = (
      black: black, white: white, red: red, green: green, blue: blue,
      yellow: yellow, cyan: cyan, magenta: magenta, orange: orange,
      purple: purple, gray: luma(128), grey: luma(128),
    )
    let lower = lower(c)
    if lower in named { return named.at(lower) }
    if lower.starts-with("#") {
      return rgb(lower)
    }
    return c
  }
  c
}

/// Serialize a Typst color to a string suitable for CBOR transport.
/// Returns none for none/auto, string passthrough for strings,
/// and repr() for Typst color values.
#let color-to-hex(c) = {
  if c == none { return none }
  if c == auto { return none }
  if type(c) == str { return c }
  repr(c)
}
