#import "coder.typ"

#let alphabet-32     = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
#let alphabet-32-hex = "0123456789ABCDEFGHIJKLMNOPQRSTUV"

/// Encodes the given data in base32 format.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
/// - pad: Whether to pad the output with "=" characters.
/// - hex: Whether to use the extended base32hex alphabet.
///
/// Returns: The encoded string.
#let encode(data, pad: true, hex: false) = {
    let alphabet = if hex { alphabet-32-hex } else { alphabet-32 }
    coder.encode(data, alphabet, pad: pad)
}

/// Decodes the given base32 string.
///
/// Arguments:
/// - string: The string to decode.
/// - hex: Whether to use the extended base32hex alphabet.
///
/// Returns: The decoded bytes.
#let decode(string, hex: false) = {
    let alphabet = if hex { alphabet-32-hex } else { alphabet-32 }
    coder.decode(string, alphabet)
}
