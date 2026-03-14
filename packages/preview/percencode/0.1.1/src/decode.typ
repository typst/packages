
/// Decods a string previously percent encoded.
/// Every sequence of %XY where XY are hexadecimal letters
/// will be decoded to UTF-8.
///
/// *Example*
///
/// ```example
/// #percencode.percent-decode("%4F%62%66%75%73%63%61%74%65%64%21")
/// ```
///
/// -> str
#let percent-decode(
  /// Percent encoded string to decode.
  ///
  /// -> str
  message) = {
  let decode-percent-sequence(sequence) = {
    sequence.text.split("%").filter(cp => cp != "").map(hex => eval("0x" + hex))
  }

  message.replace(
    regex(`(%[a-fA-F0-9]{2})+`.text),
    // Dirty workaround as I couldn*t find an offical way of
    // converting a hex string to an integer programatically.
    matches => str(bytes(decode-percent-sequence(matches))),
  )
}
