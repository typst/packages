#import "../../utils.typ": is-debug-assert

#let type-name = "length"

/// Encode a length into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// A length.
  ///
  /// -> length
  length,
  /// The wire format being encoded for. Unused -- `length` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(length) == std.length,
      message: "length.encode: length must be of type length",
    )
  }

  (
    typwire-type: type-name,
    points: length.pt(),
  )
}

/// Decode a wire-compatible dictionary into a length.
///
/// -> length
#let decode(
  /// A dictionary representing the `encode`d length.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `length` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "length.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.points) == std.float,
      message: "length.decode: value.points must be of type float",
    )
  }

  value.points * 1pt
}
