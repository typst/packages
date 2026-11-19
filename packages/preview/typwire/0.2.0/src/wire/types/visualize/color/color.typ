#import "luma.typ"
#import "oklab.typ"
#import "oklch.typ"
#import "linear-rgb.typ"
#import "rgb.typ"
#import "cmyk.typ"
#import "hsl.typ"
#import "hsv.typ"
#import "../../../utils.typ": is-debug-assert

/// Encode a color into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The color to encode.
  ///
  /// -> color
  color,
  /// The wire format being encoded for. Forwarded to the per-color-space
  /// `encode`, though none of them currently use it either -- every color
  /// space has the same tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(color) == std.color,
      message: "color.encode: color must be of type color",
    )
  }

  let c = color.components(alpha: true)
  let space = color.space()

  if space == std.color.luma {
    luma.encode(c.at(0), c.at(1), format: format)
  } else if space == std.color.oklab {
    oklab.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.oklch {
    oklch.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.linear-rgb {
    linear-rgb.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.rgb {
    rgb.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.cmyk {
    cmyk.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.hsl {
    hsl.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else if space == std.color.hsv {
    hsv.encode(c.at(0), c.at(1), c.at(2), c.at(3), format: format)
  } else {
    panic("color.encode: Unsupported color type")
  }
}

/// Map a color space name to its Typst color space.
///
/// -> function
#let color-space(
  /// A color space name.
  ///
  /// -> str
  name,
) = {
  if name == "luma" {
    color.luma
  } else if name == "oklab" {
    color.oklab
  } else if name == "oklch" {
    color.oklch
  } else if name == "linear-rgb" {
    color.linear-rgb
  } else if name == "rgb" {
    color.rgb
  } else if name == "cmyk" {
    color.cmyk
  } else if name == "hsl" {
    color.hsl
  } else if name == "hsv" {
    color.hsv
  } else {
    panic("typwire.decode: unsupported color space `" + name + "`")
  }
}

/// Every color space's `decode`, keyed by its `typwire-type` tag --
/// merged into `wire/decode.typ`'s own `decoders` table, so a tagged color
/// dispatches straight to its space's `decode` with a single lookup.
///
/// -> dictionary
#let decoders = (
  (luma.type-name): luma.decode,
  (oklab.type-name): oklab.decode,
  (oklch.type-name): oklch.decode,
  (linear-rgb.type-name): linear-rgb.decode,
  (rgb.type-name): rgb.decode,
  (cmyk.type-name): cmyk.decode,
  (hsl.type-name): hsl.decode,
  (hsv.type-name): hsv.decode,
)
