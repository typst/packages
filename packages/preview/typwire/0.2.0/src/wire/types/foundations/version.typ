#import "../../utils.typ": is-debug-assert

#let type-name = "version"

/// Encode a version into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// A version.
  ///
  /// -> version
  version,
  /// The wire format being encoded for. Unused -- `version` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(version) == std.version,
      message: "version.encode: version must be of type version",
    )
  }

  (
    typwire-type: type-name,
    components: array(version),
  )
}

/// Decode a wire-compatible dictionary into a version.
///
/// -> version
#let decode(
  /// A dictionary representing the `encode`d value.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "version.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )

    assert(
      type(value.components) == array,
      message: "version.decode: value.components must be of type array, Found "
        + str(type(value.components)),
    )
  }

  version(value.components)
}
