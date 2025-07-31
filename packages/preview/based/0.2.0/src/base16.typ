#let plugin = plugin("based.wasm")

/// Encodes the given data as a hex string.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
///
/// Returns: The encoded string (lowercase).
#let encode(data) = {
  str(plugin.encode16(bytes(data)))
}

/// Decodes the given hex string.
///
/// Arguments:
/// - string: The string to decode (case-insensitive).
///
/// Returns: The decoded bytes.
#let decode(string) = {
  plugin.decode16(bytes(string))
}
