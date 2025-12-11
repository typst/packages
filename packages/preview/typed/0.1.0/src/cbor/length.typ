/// Encode a length into a CBOR-compatible dictionary.
///
/// - length (length): A length.
/// -> dictionary
#let encode(length) = {
  assert(type(length) == std.length, message: "length.encode: length must be of type length")
  
  (
    "typed-type": "length",
    "points": length.pt(),
  )
}
