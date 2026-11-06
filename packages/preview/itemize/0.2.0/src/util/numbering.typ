/// Determines the numbering kind from a character.
///
/// - c: The character to check.
/// -> string
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let numbering-kind-from-char(c) = {
  let numberings = (
    "1",
    "a",
    "A",
    "i",
    "I",
    "α",
    "Α",
    "*",
    "א",
    "一",
    "壹",
    "あ",
    "い",
    "ア",
    "イ",
    "ㄱ",
    "가",
    "\u{0661}",
    "\u{06F1}",
    "\u{0967}",
    "\u{09E7}",
    "\u{0995}",
    "①",
    "⓵",
  )
  if c in numberings { c }
}

/// Parses a numbering pattern string into its components.
///
/// - pattern: The numbering pattern string.
/// -> dictionary
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let numbering-pattern-from-str(pattern) = {
  let pieces = ()
  let handled = 0
  let pattern-to-codepoints = pattern.codepoints()
  for (i, c) in pattern-to-codepoints.enumerate() {
    let kind = numbering-kind-from-char(c)
    if kind == none { continue }
    let prefix = pattern-to-codepoints.slice(handled, i).join()
    pieces.push((prefix, kind))
    handled = 1 + i
  }

  let suffix = pattern-to-codepoints.slice(handled).join()
  if pieces.len() == 0 {
    panic("invalid numbering pattern")
  }
  (pieces: pieces, suffix: suffix, trimmed: false)
}

/// Applies the numbering pattern to the k-th level with the given number.
///
/// - numbering: The numbering pattern.
/// - k: The level index.
/// - number: The number to format.
/// -> string
///
/// Reference: Andrew's solution (https://forum.typst.app/t/can-i-use-show-rule-only-in-content-of-enum-but-not-numbering/4590/2)
#let apply-numbering-kth(numbering, k, number) = {
  let fmt = ""
  let self = numbering-pattern-from-str(numbering)
  if self.pieces.len() > 0 {
    let (prefix, _) = self.pieces.first()
    fmt += prefix
    let (_, kind) = if k < self.pieces.len() {
      self.pieces.at(k)
    } else {
      self.pieces.last()
    }
    fmt += std.numbering(kind, number)
  }
  fmt += self.suffix
  return fmt
}
