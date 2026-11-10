// https://github.com/typst/typst/pull/7529/changes: ա Ա
#let numberings = (
  (
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
    + if sys.version > std.version(0, 14, 2) { ("ա", "Ա") }
)

/// Parses a numbering pattern string into its components.
///
/// - pattern: The numbering pattern string.
/// -> dictionary
///
/// Reference: Andrew's solution (https://github.com/typst/typst/issues/5095#issuecomment-2973642456)
#let numbering-pattern-from-str(pattern) = {
  let pieces = ()
  let handled = 0
  let pattern-to-codepoints = pattern.codepoints()
  for (i, c) in pattern-to-codepoints.enumerate() {
    let kind = if c in numberings { c }
    if kind == none { continue }
    let prefix = pattern-to-codepoints.slice(handled, i).join()
    pieces.push((prefix, kind))
    handled = 1 + i
  }

  let suffix = pattern-to-codepoints.slice(handled).join()
  if pieces.len() == 0 {
    panic("invalid numbering pattern")
  }
  (pieces: pieces, suffix: suffix)
}

/// Applies the numbering pattern to the k-th level with the given number.
///
/// - numbering: The numbering pattern.
/// - k: The level index.
/// - number: The number to format.
/// -> string
///
/// Reference: Andrew's solution (https://github.com/typst/typst/issues/5095#issuecomment-2973642456)
#let apply-numbering-kth(numbering, k, number) = {
  if type(numbering) == str {
    let fmt = ""
    let self = numbering-pattern-from-str(numbering)
    if self.pieces.len() > 0 {
      let (prefix, _) = self.pieces.first()
      fmt += prefix
      let last = self.pieces.last()
      let (_, kind) = self.pieces.at(k, default: last)
      fmt += std.numbering(kind, number)
    }
    fmt += self.suffix
    return fmt
  } else {
    return std.numbering(numbering, number)
  }
}
