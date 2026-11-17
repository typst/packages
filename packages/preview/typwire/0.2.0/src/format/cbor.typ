#import "../wire/lib.typ" as wire

/// Encode a value into CBOR bytes.
///
/// -> bytes
#let encode(
  /// The value to encode.
  ///
  /// -> any
  value,
) = cbor.encode(wire.encode(value, format: "cbor"))

/// Decode CBOR bytes and reconstruct supported native Typst values.
///
/// -> any
#let decode(
  /// The encoded Typwire value.
  ///
  /// -> bytes
  data,
) = {
  assert(
    type(data) == bytes,
    message: "typwire.cbor.decode: data must be bytes",
  )

  wire.decode(cbor(data), format: "cbor")
}

/// Call a typed Typwire plugin function with positional arguments, using
/// CBOR as the wire format.
///
/// Each argument is encoded independently and the returned bytes are decoded.
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
    message: "typwire.cbor.call: function must be a plugin function",
  )
  assert(
    args.named().len() == 0,
    message: "typwire.cbor.call: named arguments are not supported",
  )

  let encoded = args.pos().map(encode)
  let called = function(..encoded)
  let decoded = decode(called)

  decoded
}
