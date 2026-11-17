#import "../../utils.typ": is-debug-assert

#let type-name = "label"

/// Encode a label into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The label to encode.
  ///
  /// -> label
  value,
  /// The wire format being encoded for. Unused -- `label` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == label,
      message: "label.encode: value must be of type label",
    )
  }

  (
    typwire-type: type-name,
    name: str(value),
  )
}

/// Decode a wire-compatible dictionary into a label.
///
/// -> label
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `label` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "label.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.name) == str,
      message: "label.decode: value.name must be of type string, Found "
        + str(type(value.name)),
    )
  }

  label(value.name)
}
