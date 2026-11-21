#import "../../../utils.typ": is-debug-assert
// Imported under a distinct name since `encode`'s own parameter is
// already called `color`.
#import "../color/color.typ" as color-type

/// Encode a stop into a wire-compatible dictionary: its color fully encoded
/// already (a finished tree, not walked again by `wire/encode.typ`), its
/// offset a bare fraction -- the stop's position in a gradient already says
/// it's a ratio, so it needs no tag of its own.
///
/// -> dictionary
#let encode(
  /// A color.
  ///
  /// -> color
  color,
  /// A ratio value between 0% and 100%.
  ///
  /// -> ratio
  offset,
  /// The wire format being encoded for. Forwarded to the color's own
  /// `encode`.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(color) == std.color,
      message: "stop.encode: color must be of type color",
    )
    assert(
      type(offset) == std.ratio,
      message: "stop.encode: offset must be of type ratio",
    )
  }

  (
    color: color-type.encode(color, format: format),
    offset: offset / 100%,
  )
}

/// Decode a wire-compatible dictionary into a stop tuple.
///
/// -> (color, ratio)
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `stop` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value.color) == std.color,
      message: "stop.decode: value.color must be of type color, Found "
        + str(type(value.color)),
    )
    assert(
      type(value.offset) == std.float,
      message: "stop.decode: value.offset must be of type float, Found "
        + str(type(value.offset)),
    )
  }

  (value.color, value.offset * 100%)
}
