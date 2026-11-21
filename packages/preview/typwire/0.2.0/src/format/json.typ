#import "../wire/lib.typ" as wire

/// Encode a value into a JSON string.
///
/// JSON has no native byte-string type, so any `bytes` value is tagged
/// into an array instead -- handled directly by `wire.encode(value,
/// "json")`, in the same recursive pass as everything else.
///
/// -> str
#let encode(
  /// The value to encode.
  ///
  /// -> any
  value,
) = json.encode(wire.encode(value, format: "json"))

/// Decode a JSON string or bytes and reconstruct supported native Typst
/// values.
///
/// A plain `str` is coerced to `bytes` first -- Typst's own `json(...)`
/// treats a bare `str` argument as a *file path* to load, not inline
/// content, so passing `encode`'s own `str` output straight through would
/// silently try to read a file instead of decoding it.
///
/// -> any
#let decode(
  /// The encoded Typwire value.
  ///
  /// -> bytes | str
  data,
) = {
  assert(
    type(data) == str or type(data) == bytes,
    message: "typwire.json.decode: data must be str or bytes",
  )

  if type(data) == str {
    data = bytes(data)
  }

  wire.decode(json(data), format: "json")
}

/// Call a typed Typwire plugin function with positional arguments, using
/// JSON as the wire format.
///
/// Each argument is encoded independently and the returned bytes are
/// decoded. Plugin calls require `bytes` arguments, so each encoded string
/// is wrapped with `bytes(..)` before the call.
///
/// -> any
#let call(
  /// The plugin function to call.
  ///
  /// -> function
  function,
  /// The positional arguments to pass to the function.
  ///
  /// -> any
  ..args,
) = {
  assert(
    type(function) == std.function,
    message: "typwire.json.call: function must be a plugin function",
  )
  assert(
    args.named().len() == 0,
    message: "typwire.json.call: named arguments are not supported",
  )

  let encoded = args.pos().map(value => bytes(encode(value)))
  let called = function(..encoded)
  let decoded = decode(called)

  decoded
}
