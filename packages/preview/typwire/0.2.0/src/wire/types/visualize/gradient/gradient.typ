#import "linear.typ"
#import "radial.typ"
#import "conic.typ"
#import "stop.typ"
#import "center.typ"
#import "../../../utils.typ": is-debug-assert

/// Encode a gradient into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// A gradient.
  ///
  /// -> gradient
  gradient,
  /// The wire format being encoded for. Forwarded to every nested `encode`
  /// call (stops, center(s), and the kind-specific encoder), though none
  /// of them currently use it either.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(gradient) == std.gradient,
      message: "gradient.encode: gradient must be of type gradient",
    )
  }

  let stops = ()
  for (color, offset) in gradient.stops() {
    stops.push(stop.encode(color, offset, format: format))
  }
  let gradient-space = gradient.space()
  let space = if gradient-space == std.color.luma {
    "luma"
  } else if gradient-space == std.color.oklab {
    "oklab"
  } else if gradient-space == std.color.oklch {
    "oklch"
  } else if gradient-space == std.color.linear-rgb {
    "linear-rgb"
  } else if gradient-space == std.color.rgb {
    "rgb"
  } else if gradient-space == std.color.cmyk {
    "cmyk"
  } else if gradient-space == std.color.hsl {
    "hsl"
  } else if gradient-space == std.color.hsv {
    "hsv"
  } else {
    panic("gradient.encode: Invalid gradient color space")
  }

  let kind = gradient.kind()
  if kind == std.gradient.linear {
    linear.encode(stops, gradient.angle(), space, format: format)
  } else if kind == std.gradient.radial {
    radial.encode(
      stops,
      center.encode(..gradient.center(), format: format),
      gradient.radius(),
      center.encode(..gradient.focal-center(), format: format),
      gradient.focal-radius(),
      space,
      format: format,
    )
  } else if kind == std.gradient.conic {
    conic.encode(
      stops,
      gradient.angle(),
      center.encode(..gradient.center(), format: format),
      space,
      format: format,
    )
  } else {
    panic("gradient.encode: Invalid gradient type")
  }
}

/// Every gradient kind's `decode`, keyed by its `typwire-type` tag --
/// merged into `wire/decode.typ`'s own `decoders` table, the same way
/// `color.typ`'s is.
///
/// -> dictionary
#let decoders = (
  (linear.type-name): linear.decode,
  (radial.type-name): radial.decode,
  (conic.type-name): conic.decode,
)
