/// Encode a type into a CBOR-compatible string.
///
/// - type (type): A type.
/// -> str
#let encode(type) = {
  assert(std.type(type) == std.type, message: "type.encode: type must be of type type")

  (
    "typed-type": "type",
    "ty": str(type),
  )
}
