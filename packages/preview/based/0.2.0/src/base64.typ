#let plugin = plugin("based.wasm")

/// Encodes the given data in base64 format.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
/// - pad: Whether to pad the output with "=" characters.
/// - url: Whether to use the URL safe alphabet.
///
/// Returns: The encoded string.
#let encode(data, pad: true, url: false) = {
  let flags = bytes((if pad { 1 } else { 0 }, if url { 1 } else { 0 }))
  str(plugin.encode64(bytes(data), flags))
}

/// Decodes the given base64 string.
///
/// URL safe characters are automatically converted to their standard
/// counterparts.
///
/// Arguments:
/// - string: The string to decode.
///
/// Returns: The decoded bytes.
#let decode(string) = {
  let flags = bytes((0, 0))
  let string = string.replace("-", "+").replace("_", "/").trim("=", at: end)
  plugin.decode64(bytes(string), flags)
}
