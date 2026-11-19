#import "../../../utils.typ": is-debug-assert
#import "../color/color.typ"
#import "stop.typ"

#let type-name = "gradient-linear"

/// Encode a linear gradient into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// An array of encoded stops.
  ///
  /// -> array
  stops,
  /// The angle of the gradient.
  ///
  /// -> angle
  angle,
  /// The name of the color space.
  ///
  /// -> str
  space,
  /// The wire format being encoded for. Unused -- `stops` and `angle` are
  /// already encoded by the caller, and the rest of this shape is the
  /// same in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(stops) == std.array,
      message: "linear.encode: stops must be of type array",
    )
    assert(
      type(angle) == std.angle,
      message: "linear.encode: angle must be of type angle",
    )
    assert(
      type(space) == std.str,
      message: "linear.encode: space must be of type str",
    )
  }

  (
    typwire-type: type-name,
    stops: stops,
    angle: angle.rad(),
    space: space,
  )
}

/// Decode a wire-compatible dictionary into a linear gradient.
///
/// -> gradient
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Forwarded to each stop's
  /// `decode`, though it doesn't use it either.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "linear.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.stops) == std.array,
      message: "linear.decode: value.stops must be of type array, Found "
        + str(type(value.stops)),
    )
    assert(
      type(value.angle) == std.float,
      message: "linear.decode: value.angle must be of type float, Found "
        + str(type(value.angle)),
    )
    assert(
      type(value.space) == std.str,
      message: "linear.decode: value.space must be of type str, Found "
        + str(type(value.space)),
    )
  }

  let stops = ()
  for s in value.stops {
    stops.push(stop.decode(s, format: format))
  }
  let space = color.color-space(value.space)

  gradient.linear(..stops, angle: value.angle * 1rad, space: space)
}
