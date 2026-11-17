#import "../../utils.typ": is-debug-assert, unescape-repr-string

#let type-name = "regex"

/// Encode a regular expression into a wire-compatible dictionary.
///
/// Same situation as `path`: no built-in string conversion, only
/// `repr()`, which wraps the pattern as the Typst source expression
/// `regex("...")`. Unlike a path, a regex pattern routinely contains
/// literal backslashes (`\d`, `\s`, `\.`, ...), which is exactly the case
/// `unescape-repr-string` had to be fixed to handle correctly (see its own
/// comment in `utils.typ`).
///
/// -> dictionary
#let encode(
  /// A regular expression.
  ///
  /// -> regex
  value,
  /// The wire format being encoded for. Unused -- `regex` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == regex,
      message: "regex.encode: value must be of type regex",
    )
  }

  let inner = unescape-repr-string(repr(value).slice(6, -1))

  (
    typwire-type: type-name,
    pattern: inner,
  )
}

/// Decode a wire-compatible dictionary into a regular expression.
///
/// -> regex
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `regex` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "regex.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.pattern) == str,
      message: "regex.decode: value.pattern must be of type str, Found "
        + str(type(value.pattern)),
    )
  }

  regex(value.pattern)
}
