#import "../../../utils.typ": is-debug-assert
#import "../color/color.typ"
#import "center.typ"
#import "stop.typ"

#let type-name = "gradient-radial"

/// Encode a radial gradient into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// An array of encoded stops.
  ///
  /// -> array
  stops,
  /// An encoded center.
  ///
  /// -> dictionary
  center,
  /// The radius of the gradient.
  ///
  /// -> ratio
  radius,
  /// An encoded focal center.
  ///
  /// -> dictionary
  focal-center,
  /// The focal radius of the gradient.
  ///
  /// -> ratio
  focal-radius,
  /// The name of the color space.
  ///
  /// -> str
  space,
  /// The wire format being encoded for. Unused -- every nested value here
  /// is already encoded by the caller, and the rest of this shape is the
  /// same in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(stops) == std.array,
      message: "radial.encode: stops must be of type array",
    )
    assert(
      type(center) == std.dictionary,
      message: "radial.encode: center must be of type dictionary",
    )
    assert(
      type(radius) == std.ratio,
      message: "radial.encode: radius must be of type ratio",
    )
    assert(
      type(focal-center) == std.dictionary,
      message: "radial.encode: focal-center must be of type dictionary",
    )
    assert(
      type(focal-radius) == std.ratio,
      message: "radial.encode: focal-radius must be of type ratio",
    )
    assert(
      type(space) == std.str,
      message: "radial.encode: space must be of type str",
    )
  }

  (
    typwire-type: type-name,
    stops: stops,
    center: center,
    radius: radius / 100%,
    focal-center: focal-center,
    focal-radius: focal-radius / 100%,
    space: space,
  )
}

/// Decode a wire-compatible dictionary into a radial gradient.
///
/// -> gradient
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Forwarded to each stop's/center's
  /// `decode`, though none of them use it either.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "radial.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.stops) == std.array,
      message: "radial.decode: value.stops must be of type array, Found "
        + str(type(value.stops)),
    )
    assert(
      type(value.center) == std.dictionary,
      message: "radial.decode: value.center must be of type dictionary, Found "
        + str(type(value.center)),
    )
    assert(
      type(value.radius) == std.float,
      message: "radial.decode: value.radius must be of type float, Found "
        + str(type(value.radius)),
    )
    assert(
      type(value.focal-center) == std.dictionary,
      message: "radial.decode: value.focal-center must be of type dictionary, Found "
        + str(type(value.focal-center)),
    )
    assert(
      type(value.focal-radius) == std.float,
      message: "radial.decode: value.focal-radius must be of type float, Found "
        + str(type(value.focal-radius)),
    )
    assert(
      type(value.space) == std.str,
      message: "radial.decode: value.space must be of type str, Found "
        + str(type(value.space)),
    )
  }

  let stops = ()
  for s in value.stops {
    stops.push(stop.decode(s, format: format))
  }
  let space = color.color-space(value.space)

  gradient.radial(
    ..stops,
    center: center.decode(value.center, format: format),
    radius: value.radius * 100%,
    focal-center: center.decode(value.focal-center, format: format),
    focal-radius: value.focal-radius * 100%,
    space: space,
  )
}
