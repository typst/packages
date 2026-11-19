#let type-name = "auto"

/// Encode `auto` into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The wire format being encoded for. Unused -- `auto` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  (
    typwire-type: type-name,
  )
}

/// Decode a wire-compatible dictionary into `auto`.
///
/// -> auto
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `auto` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  auto
}
