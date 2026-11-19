#import "../../../utils.typ": is-debug-assert

#let type-name = "color-luma"

/// Encode a luma color into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The lightness component of the color.
  ///
  /// -> ratio
  lightness,
  /// The alpha (transparency) component of the color.
  ///
  /// -> ratio
  alpha,
  /// The wire format being encoded for. Unused -- `luma` has the same
  /// shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(lightness) == std.ratio,
      message: "luma.encode: lightness must be of type ratio",
    )
    assert(
      type(alpha) == std.ratio,
      message: "luma.encode: alpha must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    lightness: lightness / 100%,
    alpha: alpha / 100%,
  )
}

/// Decode a wire-compatible dictionary into a luma color.
///
/// -> color
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `luma` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "luma.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.lightness) == std.float,
      message: "luma.decode: value.lightness must be of type float, Found "
        + str(type(value.lightness)),
    )
    assert(
      type(value.alpha) == std.float,
      message: "luma.decode: value.alpha must be of type float, Found "
        + str(type(value.alpha)),
    )
  }

  color.luma(value.lightness * 100%, value.alpha * 100%)
}
