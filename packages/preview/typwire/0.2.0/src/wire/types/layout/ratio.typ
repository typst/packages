#import "../../utils.typ": is-debug-assert

#let type-name = "ratio"

/// Encode a ratio into a wire-compatible float.
///
/// -> float
#let encode(
  /// A ratio of any value.
  ///
  /// -> ratio
  ratio,
  /// The wire format being encoded for. Unused -- `ratio` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(ratio) == std.ratio,
      message: "ratio.encode: ratio must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    ratio: ratio / 100%,
  )
}

/// Decode a wire-compatible dictionary into a ratio.
///
/// -> ratio
#let decode(
  /// A dictionary representing the `encode`d value.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `ratio` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "ratio.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.ratio) == std.float,
      message: "ratio.decode: value.ratio must be of type float, Found "
        + str(type(value.ratio)),
    )
  }

  value.ratio * 100%
}
