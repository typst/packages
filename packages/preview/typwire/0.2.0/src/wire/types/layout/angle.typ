#import "../../utils.typ": is-debug-assert

#let type-name = "angle"

/// Encode an angle into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// An angle.
  ///
  /// -> angle
  angle,
  /// The wire format being encoded for. Unused -- `angle` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(angle) == std.angle,
      message: "angle.encode: angle must be of type angle",
    )
  }

  (
    typwire-type: type-name,
    radians: angle.rad(),
  )
}

/// Decode a wire-compatible dictionary into an angle.
///
/// -> angle
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `angle` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "angle.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.radians) == std.float,
      message: "angle.decode: value.radians must be a float. Found "
        + str(type(value.radians)),
    )
  }

  value.radians * 1rad
}
