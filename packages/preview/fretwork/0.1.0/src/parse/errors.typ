// Error reporting for the parsers.
//
// Typst can only point at a whole string argument, never inside it, so a parse
// error has to carry its own location. Every message names the measure and the
// token ordinal, and shows the offending source line with a caret under it.

/// The location of a parse error within a source string.
#let at(measure: 1, token: 0, col: 0) = (measure: measure, token: token, col: col)

/// Extract the source line containing `col`, and the column within that line.
#let _line-at(source, col) = {
  let chars = source.clusters()
  let col = calc.min(col, chars.len())
  let start = 0
  let i = 0
  while i < col {
    if chars.at(i) == "\n" { start = i + 1 }
    i += 1
  }
  let end = col
  while end < chars.len() and chars.at(end) != "\n" {
    end += 1
  }
  (text: chars.slice(start, end).join(), col: col - start)
}

/// Build a full error message. Exposed separately from `fail` so tests can
/// inspect the wording without triggering a panic.
#let format(kind, loc, message, source: none) = {
  let head = (
    kind
      + ": measure "
      + str(loc.measure)
      + ", token "
      + str(loc.token)
      + ": "
      + message
  )
  if source == none { return head }
  let line = _line-at(source, loc.col)
  head + "\n  " + line.text + "\n  " + " " * line.col + "^"
}

/// Abort with a located parse error.
#let fail(kind, loc, message, source: none) = panic(format(kind, loc, message, source: source))
