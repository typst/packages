/// Encodes the given data as a hex string.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
///
/// Returns: The encoded string (lowercase).
#let encode(data) = {
  if data.len() == 0 { return "" }

  for byte in array(bytes(data)) {
    if byte < 16 { "0" }
    str(int(byte), base: 16)
  }
}

/// Decodes the given hex string.
///
/// Arguments:
/// - string: The string to decode (case-insensitive).
///
/// Returns: The decoded bytes.
#let decode(string) = {
  let dec(hex-digit) = {
    let code = str.to-unicode(hex-digit)
    if code >= 48 and code <= 57 { code - 48 } // 0-9
    else if code >= 65 and code <= 70 { code - 55 } // A-F
    else if code >= 97 and code <= 102 { code - 87 } // a-f
    else { panic("Invalid hex digit: " + hex-digit) }
  }

  let array = range(string.len(), step: 2).map(i => {
    16 * dec(string.at(i)) + dec(string.at(i + 1))
  })
  bytes(array)
}
