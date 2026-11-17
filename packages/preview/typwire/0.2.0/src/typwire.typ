// Bare imports (no `as`, no member list) bind each module under its own
// filename -- `lib.typ` re-exports these same bindings directly as
// `typwire.cbor`/`.json`/`.debug` so that namespace's own dot-call sugar
// keeps working. Typst allows `module.field(..)` for a module's own
// field, but refuses the identical syntax when the receiver is a plain
// dictionary whose value happens to be a function.
#import "format/cbor.typ"
#import "format/debug.typ"
#import "format/json.typ"

// Maps a format name to the module that implements it. `encode`/`decode`/
// `call` below are the single place that actually dispatches on `format`;
// every `typwire.<format>` namespace further down is just a fixed-format
// wrapper around them.
#let formats = (
  cbor: cbor,
  json: json,
)

#let resolve-format(format) = {
  assert(
    format in formats,
    message: "typwire: unknown format \""
      + format
      + "\" "
      + "(expected one of \"cbor\", \"json\")",
  )

  formats.at(format)
}

/// Encode a Typst value into a wire format's bytes/string.
///
/// -> bytes | str
#let encode(
  /// The value to encode.
  ///
  /// -> any
  value,
  /// The wire format to encode into -- one of `"cbor"` (the default,
  /// matching `#[typwire::export]`'s own default), `"json"`. Use
  /// `typwire.debug.encode` instead to inspect the shared tree with no
  /// serialization at all.
  ///
  /// -> str
  format: "cbor",
) = resolve-format(format).encode(value)

/// The mirror of `encode`: decode a wire format's bytes/string and
/// reconstruct supported native Typst values.
///
/// -> any
#let decode(
  /// The encoded Typwire value.
  ///
  /// -> bytes | str
  data,
  /// The wire format `data` was encoded with -- must match.
  ///
  /// -> str
  format: "cbor",
) = resolve-format(format).decode(data)

/// Call a typed Typwire plugin function with positional arguments, using
/// the given wire format -- the plugin export and the call site must agree
/// on the same one.
///
/// Each argument is encoded independently and the returned bytes are
/// decoded.
///
/// -> any
#let call(
  /// The plugin function to call.
  ///
  /// -> function
  function,
  /// Positional arguments to encode and pass.
  ///
  /// -> any
  ..args,
  /// The wire format to call with -- one of `"cbor"` (the default,
  /// matching `#[typwire::export]`'s own default), `"json"`.
  ///
  /// -> str
  format: "cbor",
) = resolve-format(format).call(function, ..args)
