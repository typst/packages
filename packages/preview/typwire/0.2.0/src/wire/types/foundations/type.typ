#import "../../utils.typ": is-debug-assert

#let type-name = "type"

/// Encode a type into a wire-compatible string.
///
/// -> str
#let encode(
  /// A type.
  ///
  /// -> type
  type,
  /// The wire format being encoded for. Unused -- `type` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      std.type(type) == std.type,
      message: "type.encode: type must be of type type",
    )
  }

  (
    typwire-type: type-name,
    ty: str(type),
  )
}

/// Decode a wire-compatible dictionary into a type.
///
/// -> type
#let decode(
  /// A dictionary representing the `encode`d value.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `type` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "type.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      std.type(value.ty) == std.str,
      message: "type.decode: value.ty must be of type str, Found "
        + str(std.type(value.ty)),
    )
  }

  let ty = value.ty
  if ty == "integer" {
    int
  } else if ty == "float" {
    float
  } else if ty == "bytes" {
    bytes
  } else if ty == "string" {
    str
  } else if ty == "boolean" {
    bool
  } else if ty == "none" {
    type(none)
  } else if ty == "auto" {
    type(auto)
  } else if ty == "array" {
    (1, 2, 3)
  } else if ty == "dictionary" {
    dictionary
  } else if ty == "alignment" {
    alignment
  } else if ty == "angle" {
    angle
  } else if ty == "length" {
    length
  } else if ty == "ratio" {
    ratio
  } else if ty == "color" {
    color
  } else if ty == "gradient" {
    gradient
  } else if ty == "stroke" {
    stroke
  } else if ty == "datetime" {
    datetime
  } else if ty == "decimal" {
    decimal
  } else if ty == "duration" {
    duration
  } else if ty == "label" {
    label
  } else if ty == "version" {
    version
  } else if ty == "type" {
    type
  } else if ty == "path" {
    path
  } else if ty == "symbol" {
    symbol
  } else if ty == "regex" {
    regex
  } else if ty == "arguments" {
    arguments
  } else if ty == "content" {
    content
  } else if ty == "function" {
    function
  } else {
    panic("typwire.decode: cannot reconstruct unknown type object `" + ty + "`")
  }
}
