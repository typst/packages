#let plugin = plugin("based.wasm")

/// Encodes the given data in base32 format.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
/// - pad: Whether to pad the output with "=" characters.
/// - hex: Whether to use the extended base32hex alphabet.
///
/// Returns: The encoded string.
#let encode(data, pad: true, hex: false) = {
  let flags = bytes((if pad { 1 } else { 0 }, if hex { 1 } else { 0 }))
  str(plugin.encode32(bytes(data), flags))
}

/// Decodes the given base32 string.
///
/// Arguments:
/// - string: The string to decode.
/// - hex: Whether to use the extended base32hex alphabet.
///
/// Returns: The decoded bytes.
#let decode(string, hex: false) = {
  let flags = bytes((0, if hex { 1 } else { 0 }))
  let string = string.trim("=", at: end)
  plugin.decode32(bytes(string), flags)
}
