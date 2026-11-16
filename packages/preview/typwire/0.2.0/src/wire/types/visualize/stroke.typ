#import "../../utils.typ": is-debug-assert

#let type-name = "stroke"

/// Encode a stroke into a wire-compatible dictionary. Every field is
/// already one of the wire's other supported shapes (`auto`, a color or
/// gradient, a length, a plain string, `none`, or a plain dictionary of
/// lengths/strings for `dash`) -- so, like `arguments`, this just reads
/// the fields back and leaves recursing into them to the caller.
///
/// -> dictionary
#let encode(
  /// The stroke to encode.
  ///
  /// -> stroke
  value,
  /// The wire format being encoded for. Unused -- every field's own
  /// recursive encode (done by the caller, not here) is what actually
  /// varies by format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == stroke,
      message: "stroke.encode: value must be of type stroke",
    )
  }

  (
    typwire-type: type-name,
    paint: value.paint,
    thickness: value.thickness,
    cap: value.cap,
    join: value.join,
    dash: value.dash,
    miter-limit: value.miter-limit,
  )
}

/// Decode a wire-compatible dictionary into a stroke.
///
/// -> stroke
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- every field's own
  /// recursive decode (done by the caller, not here) is what actually
  /// varies by format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "stroke.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
  }

  stroke(
    paint: value.paint,
    thickness: value.thickness,
    cap: value.cap,
    join: value.join,
    dash: value.dash,
    miter-limit: value.miter-limit,
  )
}
