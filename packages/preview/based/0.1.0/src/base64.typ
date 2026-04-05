#import "coder.typ"

#let alphabet-64     = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
#let alphabet-64-url = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

/// Encodes the given data in base64 format.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
/// - pad: Whether to pad the output with "=" characters.
/// - url: Whether to use the URL safe alphabet.
///
/// Returns: The encoded string.
#let encode(data, pad: true, url: false) = {
    let alphabet = if url { alphabet-64-url } else { alphabet-64 }
    coder.encode(data, alphabet, pad: pad)
}

/// Decodes the given base64 string.
///
/// URL safe characters are automatically converted to their standard
/// counterparts. Invalid characters are ignored.
///
/// Arguments:
/// - string: The string to decode.
///
/// Returns: The decoded bytes.
#let decode(string) = {
    string = string.replace("-", "+").replace("_", "/")
    coder.decode(string, alphabet-64)
}
