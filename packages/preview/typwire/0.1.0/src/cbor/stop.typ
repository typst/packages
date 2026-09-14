/// Encode a stop into a CBOR-compatible dictionary.
///
/// - color (color): A color,
/// - offset (ratio): A ratio value between 0% and 100%.
/// -> dictionary
#let encode(color, offset) = {
  assert(type(color) == std.color, message: "stop.encode: color must be of type color")
  assert(type(offset) == ratio, message: "stop.encode: offset must be of type ratio")

  (
    "color": color,
    "offset": offset
  )
}
