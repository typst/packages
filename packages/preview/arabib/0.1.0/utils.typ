// arabib/utils.typ – Pure utility functions
//
// These helpers have no dependency on citrus or arabib state
// and can be imported independently.


/// Convert Western digits (0–9) to Arabic-Indic digits (٠–٩).
///
/// Applies a scoped show rule, so only content nested inside
/// the call is affected.
#let to-arabic-numerals(body) = {
  show regex("[0-9]"): it => {
    ("٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩").at(int(it.text))
  }
  body
}


/// Decode a single hex character to its numeric value (0–15).
/// Returns `none` for non-hex characters.
#let _hex-digit(c) = {
  let code = c.to-unicode()
  if code >= 48 and code <= 57 { code - 48 }        // 0–9
  else if code >= 65 and code <= 70 { code - 55 }   // A–F
  else if code >= 97 and code <= 102 { code - 87 }  // a–f
  else { none }
}

/// Decode a single `%XX` hex-pair into a byte value.
/// Returns `none` if either nibble is not a valid hex digit.
#let _decode-hex-pair(hi-char, lo-char) = {
  let hi = _hex-digit(hi-char)
  let lo = _hex-digit(lo-char)
  if hi != none and lo != none { hi * 16 + lo } else { none }
}

/// Determine how many bytes a UTF-8 lead byte requires.
#let _utf8-byte-count(byte) = {
  if byte >= 0xF0 { 4 }
  else if byte >= 0xE0 { 3 }
  else if byte >= 0xC0 { 2 }
  else { 1 }
}

/// Percent-decode a URL string (`%XX` sequences → characters).
///
/// Handles multi-byte UTF-8 sequences so that encoded Arabic,
/// CJK, emoji, etc. are decoded correctly.
#let percent-decode(url) = {
  let chars = url.clusters()
  let len = chars.len()
  let out = ""
  let i = 0

  while i < len {
    if chars.at(i) == "%" and i + 2 < len {
      let byte = _decode-hex-pair(chars.at(i + 1), chars.at(i + 2))

      if byte != none {
        let num-bytes = _utf8-byte-count(byte)
        let bytes-arr = (byte,)
        let valid = true
        let j = 1

        // Collect continuation bytes (%XX %XX …)
        while j < num-bytes {
          let pos = i + 3 * j
          if pos + 2 < len and chars.at(pos) == "%" {
            let cont = _decode-hex-pair(chars.at(pos + 1), chars.at(pos + 2))
            if cont != none {
              bytes-arr.push(cont)
            } else { valid = false }
          } else { valid = false }
          j += 1
        }

        if valid and bytes-arr.len() == num-bytes {
          out += str(bytes(bytes-arr))
          i += num-bytes * 3
        } else {
          out += chars.at(i)
          i += 1
        }
      } else {
        out += chars.at(i)
        i += 1
      }
    } else {
      out += chars.at(i)
      i += 1
    }
  }

  out
}
