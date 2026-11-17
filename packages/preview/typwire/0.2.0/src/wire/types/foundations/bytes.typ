#import "../../utils.typ": is-debug-assert

#let type-name = "bytes"

/// Encode a `bytes` value for the wire.
///
/// CBOR has a native byte-string type, so `bytes` passes straight through
/// unchanged there. JSON doesn't -- Typst's own `json.encode(bytes(..))`
/// confirmed empirically to silently produce the useless placeholder
/// string `"bytes(3)"` rather than actual content -- so it gets a tagged
/// array of byte integers instead. Not base64: Typst has no built-in
/// base64 codec to match a base64 string against, so the array form needs
/// no new dependency on either side.
///
/// -> bytes | dictionary
#let encode(
  /// The bytes to encode.
  ///
  /// -> bytes
  value,
  /// The wire format being encoded for.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == bytes,
      message: "bytes.encode: value must be of type bytes",
    )
  }

  if format == "cbor" {
    value
  } else {
    (
      typwire-type: type-name,
      data: array(value),
    )
  }
}

/// Decode a tagged bytes dictionary back into `bytes`.
///
/// Only ever reached for JSON, the one format with no native byte-string
/// type: CBOR's own `bytes` values pass straight through
/// `wire/decode.typ::decode`'s catch-all primitive case before ever
/// reaching its `decoders` tag dispatch, so this never runs with
/// `format == "cbor"`.
///
/// -> bytes
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- the tag alone already
  /// fully determines how to decode it.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "bytes.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.data) == std.array,
      message: "bytes.decode: value.data must be of type array, Found "
        + str(type(value.data)),
    )
  }

  bytes(value.data)
}
