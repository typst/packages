// Shared ACM bibliography rendering primitives.

#import "tex.typ": tex-to-content

// ---- render seam ----------------------------------------------------------
// Field values flow through the formatter as RAW TeX (BibTeX-style); the single
// string->content boundary is `render`, the active `tex-render` callback (the
// acmart() option, default tex-to-content). Every helper that emits *visible*
// field text routes through it, so a user override sees the raw TeX of every
// title/journal/note.
#let tex-render-state = state("acmref-texrender", tex-to-content)
#let render(s) = (tex-render-state.get())(s)
#let ends-punct(s) = {
  let t = s.trim()
  t != "" and t.last() in (".", "!", "?")
}
#let blx-ends-punct(s) = {
  let t = s.trim()
  while t != "" and t.last() in (")", "]", "}", "\"", "\u{201D}", "'", "\u{2019}") {
    t = t.slice(0, -1).trim()
  }
  t != "" and t.last() in (".", "!", "?")
}
// a value carried through the emitter: rendered content + whether its raw text
// ends in .?! (drives the .bst add.period$ / block separators)
#let V(text, c: none) = (c: render(if c == none { text } else { c }), p: ends-punct(text))
#let it(x) = text(style: "italic", x)

// ---- field access ---------------------------------------------------------
#let fld(e, name, d: none) = e.fields.at(name, default: d)
#let has(e, name) = name in e.fields and e.fields.at(name).trim() != ""
#let articleno-of(e) = if has(e, "articleno") { fld(e, "articleno") } else if has(e, "eid") { fld(e, "eid") } else { none }

// ---- names ----------------------------------------------------------------
#let is-others(n) = n.last == "others" and n.first == "" and n.von == ""
#let one-name(n) = (n.first, n.von, n.last).filter(p => p != "").join(" ") + (
  if n.jr != "" { ", " + n.jr } else { "" })

// format.names: list authors/editors in "First von Last, Jr" order
#let join-names(people) = {
  let n = people.len()
  let out = ""
  for (i, person) in people.enumerate() {
    let nm = if is-others(person) { "et al." } else { one-name(person) }
    if i == 0 { out = nm }
    else if i < n - 1 { out = out + ", " + nm }
    else {
      if n > 2 { out = out + "," }
      out = out + (if is-others(person) { " " } else { " and " }) + nm
    }
  }
  out
}

// ---- small shared helpers -------------------------------------------------
#let dashify(s) = s.replace("--", "\u{2013}").replace("-", "\u{2013}")
#let von-last(n) = (n.von, n.last).filter(p => p != "").join(" ")
// ---- year piece -----------------------------------------------------------
#let year-value(e) = {
  // `date` may be shorter than a full YYYY (malformed input); guard the slice
  // as blx-date-parts does rather than letting .slice(0, 4) panic.
  let date = fld(e, "date", d: "")
  let y = if has(e, "year") { fld(e, "year") } else if date.len() >= 4 { date.slice(0, 4) } else { "[n.d.]" }
  (c: y, p: false)
}
