#import "../../utils.typ": is-debug-assert

#let type-name = "arguments"

/// Encode captured arguments into a CBOR-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// Captured arguments.
  ///
  /// -> arguments
  value,
  /// The wire format being encoded for. Unused -- `arguments` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == arguments,
      message: "arguments.encode: value must be of type arguments",
    )
  }

  (
    typwire-type: type-name,
    pos: value.pos(),
    named: value.named(),
  )
}

/// Decode a CBOR-compatible dictionary into captured arguments.
///
/// -> arguments
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `arguments` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "arguments.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.pos) == array,
      message: "arguments.decode: value.pos must be of type array, Found "
        + str(type(value.pos)),
    )
    assert(
      type(value.named) == dictionary,
      message: "arguments.decode: value.named must be of type dictionary, Found "
        + str(type(value.named)),
    )
  }

  arguments(..value.pos, ..value.named)
}
