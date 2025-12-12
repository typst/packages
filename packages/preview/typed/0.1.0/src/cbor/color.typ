/// Encode a luma color into a CBOR-compatible dictionary.
///
/// - lightness (ratio): The lightness component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let luma(lightness, alpha) = {
  assert(type(lightness) == std.ratio, message: "color.luma: lightness must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.luma: alpha must be of type ratio")
  
  (
    "typed-type": "color-luma",
    "lightness": lightness,
    "alpha": alpha,
  )
}

/// Encode an OKLab color into a CBOR-compatible dictionary.
///
/// - lightness (ratio): The lightness component of the color.
/// - a (ratio): The 'a' component of the color.
/// - b (ratio): The 'b' component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let oklab(lightness, a, b, alpha) = {
  assert(type(lightness) == std.ratio, message: "color.oklab: lightness must be of type ratio")
  assert(type(a) == std.ratio, message: "color.oklab: a must be of type ratio")
  assert(type(b) == std.ratio, message: "color.oklab: b must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.oklab: alpha must be of type ratio")
  
  (
    "typed-type": "color-oklab",
    "lightness": lightness,
    "a": a,
    "b": b,
    "alpha": alpha,
  )
}

/// Encode an OKLCH color into a CBOR-compatible dictionary.
///
/// - lightness (ratio): The lightness component of the color.
/// - chroma (ratio): The chroma component of the color.
/// - hue (angle): The hue component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let oklch(lightness, chroma, hue, alpha) = {
  assert(type(lightness) == std.ratio, message: "color.oklch: lightness must be of type ratio")
  assert(type(chroma) == std.ratio, message: "color.oklch: chroma must be of type ratio")
  assert(type(hue) == std.angle, message: "color.oklch: hue must be of type angle")
  assert(type(alpha) == std.ratio, message: "color.oklch: alpha must be of type ratio")
  
  (
    "typed-type": "color-oklch",
    "lightness": lightness,
    "chroma": chroma,
    "hue": hue,
    "alpha": alpha,
  )
}

/// Encode a linear RGB color into a CBOR-compatible dictionary.
///
/// - r (ratio): The red component of the color.
/// - g (ratio): The green component of the color.
/// - b (ratio): The blue component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let linear-rgb(r, g, b, alpha) = {
  assert(type(r) == std.ratio, message: "color.linear-rgb: r must be of type ratio")
  assert(type(g) == std.ratio, message: "color.linear-rgb: g must be of type ratio")
  assert(type(b) == std.ratio, message: "color.linear-rgb: b must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.linear-rgb: alpha must be of type ratio")
  
  (
    "typed-type": "color-linear-rgb",
    "r": r,
    "g": g,
    "b": b,
    "alpha": alpha,
  )
}

/// Encode an RGB color into a CBOR-compatible dictionary.
///
/// - r (ratio): The red component of the color.
/// - g (ratio): The green component of the color.
/// - b (ratio): The blue component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let rgb(r, g, b, alpha) = {
  assert(type(r) == std.ratio, message: "color.rgb: r must be of type ratio")
  assert(type(g) == std.ratio, message: "color.rgb: g must be of type ratio")
  assert(type(b) == std.ratio, message: "color.rgb: b must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.rgb: alpha must be of type ratio")
  
  (
    "typed-type": "color-rgb",
    "r": r,
    "g": g,
    "b": b,
    "alpha": alpha,
  )
}

/// Encode a CMYK color into a CBOR-compatible dictionary.
///
/// - cyan (ratio): The cyan component of the color.
/// - magenta (ratio): The magenta component of the color.
/// - yellow (ratio): The yellow component of the color.
/// - key (ratio): The key (black) component of the color.
/// -> dictionary
#let cmyk(cyan, magenta, yellow, key) = {
  assert(type(cyan) == std.ratio, message: "color.cmyk: cyan must be of type ratio")
  assert(type(magenta) == std.ratio, message: "color.cmyk: magenta must be of type ratio")
  assert(type(yellow) == std.ratio, message: "color.cmyk: yellow must be of type ratio")
  assert(type(key) == std.ratio, message: "color.cmyk: key must be of type ratio")
  
  (
    "typed-type": "color-cmyk",
    "cyan": cyan,
    "magenta": magenta,
    "yellow": yellow,
    "key": key,
  )
}

/// Encode an HSL color into a CBOR-compatible dictionary.
///
/// - hue (angle): The hue component of the color.
/// - saturation (ratio): The saturation component of the color.
/// - lightness (ratio): The lightness component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let hsl(hue, saturation, lightness, alpha) = {
  assert(type(hue) == std.angle, message: "color.hsl: hue must be of type angle")
  assert(type(saturation) == std.ratio, message: "color.hsl: saturation must be of type ratio")
  assert(type(lightness) == std.ratio, message: "color.hsl: lightness must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.hsl: alpha must be of type ratio")
  
  (
    "typed-type": "color-hsl",
    "hue": hue,
    "saturation": saturation,
    "lightness": lightness,
    "alpha": alpha,
  )
}

/// Encode an HSV color into a CBOR-compatible dictionary.
///
/// - hue (angle): The hue component of the color.
/// - saturation (ratio): The saturation component of the color.
/// - value (ratio): The value (brightness) component of the color.
/// - alpha (ratio): The alpha (transparency) component of the color.
/// -> dictionary
#let hsv(hue, saturation, value, alpha) = {
  assert(type(hue) == std.angle, message: "color.hsv: hue must be of type angle")
  assert(type(saturation) == std.ratio, message: "color.hsv: saturation must be of type ratio")
  assert(type(value) == std.ratio, message: "color.hsv: value must be of type ratio")
  assert(type(alpha) == std.ratio, message: "color.hsv: alpha must be of type ratio")
  
  (
    "typed-type": "color-hsv",
    "hue": hue,
    "saturation": saturation,
    "value": value,
    "alpha": alpha,
  )
}

/// Encode a color into a CBOR-compatible dictionary.
///
/// - color (color): The color to encode.
/// -> dictionary
#let encode(color) = {
  assert(type(color) == std.color, message: "color.encode: color must be of type color")

  let c = color.components(alpha: true)
  
  if color.space() == std.color.luma {
    luma(c.at(0), c.at(1))
  } else if color.space() == std.color.oklab {
    oklab(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.oklch {
    oklch(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.linear-rgb {
    linear-rgb(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.rgb {
    rgb(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.cmyk {
    cmyk(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.hsl {
    hsl(c.at(0), c.at(1), c.at(2), c.at(3))
  } else if color.space() == std.color.hsv {
    hsv(c.at(0), c.at(1), c.at(2), c.at(3))
  } else {
    panic("color.encode: Unsupported color type")
  }
}
