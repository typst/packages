
/// Encode the given string with percent encoding
/// escaping all UTF-8 characters.
/// Based on RFC 3986 section 2.1.
/// Encoding works by converting the UTF-8 representation of
/// a grapheme cluster (single piece of printable character)
/// for each byte to a string of upper case formatted hexadecimal.
///
/// *NOTE:* This function will encode every character in the string!
///
/// *Example*
///
/// ```example
/// #percencode.percent-encode("Hello, World!")
/// ```
///
/// -> str
#let percent-encode(
  /// String to encode in percent escape sequence.
  ///
  /// -> str
  message,
  /// Pattern of grapheme clusters not to escape.
  ///
  /// -> str | regex
  exclude: none,
) = {
  return message
    .clusters()
    .map(cluster => {
      if exclude != none and cluster.contains(exclude) {
        cluster
      } else {
        // Convert grapheme cluster to bytes representing the unicode point.
        // Then drop zero bytes, only the least significant non-zero bytes are of use.
        // At last, convert each byte to uppercase hex and prepend a '%'.
        array(bytes(cluster)).map(byte => "%" + upper(str(byte, base: 16))).join("")
      }
    })
    .join()
}

/// Escapes all characters except:
/// ```
/// A–Z a–z 0–9 - _ . ! ~ * ' ( ) ; / ? : @ & = + $ , #
/// ```
/// conforming to RFC 2396.
/// This function is meant to be used to encode entire URLs.
///
/// ```example
/// #percencode.url-encode("https://example.com/how much is 23€ wörth?")
/// ```
///
/// -> str
#let url-encode(
  /// URL string to encode
  ///
  /// -> str
  url,
) = {
  percent-encode(url, exclude: regex(`[a-zA-Z0-9\-_.!~*'();/?:@&=+$,#]`.text))
}
