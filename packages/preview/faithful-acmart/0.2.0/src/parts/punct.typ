// Reproduce LaTeX's \@addpunct rules for terminal punctuation.

// \@addpunct tests TeX's space factor.
// An uppercase letter followed by a period still permits an added period: "UK..".

#let _sfcode(c) = {
  if c == ")" or c == "]" or c == "'" or c.trim() == "" { 0 }
  else if c == "." or c == "?" or c == "!" { 3000 }
  else if c == ":" { 2000 }
  else if c == ";" { 1500 }
  else if c == "," { 1250 }
  else if upper(c) == c and lower(c) != c { 999 }
  else { 1000 }
}

#let _space-factor(s) = {
  let sf = 1000
  for c in s {
    let f = _sfcode(c)
    if f == 0 { continue }
    sf = if f == 1000 or (sf < 1000 and f > 1000) { 1000 } else { f }
  }
  sf
}

// Math and boxes reset TeX's space factor to 1000, represented here by a digit.
// Invisible content leaves the preceding factor intact.
#let _opaque = "0"

#let _trailing(c, want: 16) = {
  if type(c) == str { return c }
  if type(c) != content { return "" }
  // Some element functions are not exposed as bindings, so compare their names.
  let name = repr(c.func())
  if name in ("space", "h", "v", "parbreak", "linebreak", "pagebreak", "place",
              "metadata", "state", "counter", "update") { return "" }
  if name in ("equation", "box", "image", "hide") { return _opaque }
  if name == "smartquote" { return "'" }
  if c.has("text") { return c.text }
  if c.has("body") { return _trailing(c.body, want: want) }
  if c.has("children") {
    let out = ""
    for child in c.children.rev() {
      out = _trailing(child, want: want - out.len()) + out
      if out.len() >= want { break }
    }
    return out
  }
  _opaque
}

// Literal closing quotes need the same treatment as smart quotes, which _trailing represents as apostrophes.
#let _closing-quotes = ("\"", "\u{201D}", "\u{2019}")

#let _ends-punct(s) = {
  let last = none
  for c in s {
    if _sfcode(c) != 0 and c not in _closing-quotes { last = c }
  }
  last != none and _sfcode(last) > 1000
}

#let needs-punct(c, fix: false) = {
  let t = _trailing(c)
  if fix { not _ends-punct(t) } else { _space-factor(t) <= 1000 }
}

#let add-punct(c, mark: [.], fix: false) = if needs-punct(c, fix: fix) { [#c#mark] } else { c }
