#import "../../../utils.typ": is-debug-assert
#import "../color/color.typ"
#import "center.typ"
#import "stop.typ"

#let type-name = "gradient-conic"

/// Encode a conic gradient into a wire-compatible dictionary.
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
  /// An encoded center.
  ///
  /// -> dictionary
  center,
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
      message: "conic.encode: stops must be of type array",
    )
    assert(
      type(angle) == std.angle,
      message: "conic.encode: angle must be of type angle",
    )
    assert(
      type(center) == std.dictionary,
      message: "conic.encode: center must be of type dictionary",
    )
    assert(
      type(space) == std.str,
      message: "conic.encode: space must be of type str",
    )
  }

  (
    typwire-type: type-name,
    stops: stops,
    angle: angle.rad(),
    center: center,
    space: space,
  )
}

/// Decode a wire-compatible dictionary into a conic gradient.
///
/// -> gradient
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Forwarded to each stop's/center's
  /// `decode`, though neither uses it either.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "conic.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.stops) == std.array,
      message: "conic.decode: value.stops must be of type array, Found "
        + str(type(value.stops)),
    )
    assert(
      type(value.angle) == std.float,
      message: "conic.decode: value.angle must be of type float, Found "
        + str(type(value.angle)),
    )
    assert(
      type(value.center) == std.dictionary,
      message: "conic.decode: value.center must be of type dictionary, Found "
        + str(type(value.center)),
    )
    assert(
      type(value.space) == std.str,
      message: "conic.decode: value.space must be of type str, Found "
        + str(type(value.space)),
    )
  }

  let stops = ()
  for s in value.stops {
    stops.push(stop.decode(s, format: format))
  }
  let space = color.color-space(value.space)

  gradient.conic(
    ..stops,
    angle: value.angle * 1rad,
    center: center.decode(value.center, format: format),
    space: space,
  )
}
