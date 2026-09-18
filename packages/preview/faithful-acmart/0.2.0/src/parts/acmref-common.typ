// Field access and rendering helpers shared by the custom bibliography backends.

#import "tex.typ": tex-to-content
#import "theorems.typ": cfg-state

#let fixing() = {
  let cfg = cfg-state.get()
  cfg != none and cfg.fix-quirks
}

#let nolinkurl(s) = {
  let cfg = cfg-state.get()
  if cfg != none and cfg.urlstyle-sans { text(font: cfg.fonts.sans, s) } else { s }
}

#let tex-render-state = state("acmref-texrender", tex-to-content)
#let render(s) = (tex-render-state.get())(s)
#let ends-punct(s) = {
  let t = s.trim()
  t != "" and t.last() in (".", "!", "?")
}
// A closing delimiter hides preceding punctuation from BibLaTeX's punctuation tracker.
#let blx-visible-tail(s) = {
  let t = s.trim()
  while t != "" and t.last() in (")", "]", "}", "\"", "\u{201D}", "'", "\u{2019}") {
    t = t.slice(0, -1).trim()
  }
  t
}
#let blx-ends-punct(s) = {
  let t = blx-visible-tail(s)
  t != "" and t.last() in (".", "!", "?")
}
// Carry rendered content and its terminal-punctuation flag together through the emitter.
#let V(text, c: none) = (c: render(if c == none { text } else { c }), p: ends-punct(text))
#let it(x) = text(style: "italic", x)

#let fld(e, name, d: none) = e.fields.at(name, default: d)
#let has(e, name) = {
  if name not in e.fields { return false }
  e.fields.at(name).trim() != ""
}
#let articleno-of(e) = {
  if has(e, "articleno") { fld(e, "articleno") } else if has(e, "eid") { fld(e, "eid") } else { none }
}
#let fV(e, name) = if has(e, name) { V(fld(e, name)) } else { none }

#let is-others(n) = n.last == "others" and n.first == "" and n.von == "" and n.jr == ""
#let one-name(n, suffix-comma: true) = (n.first, n.von, n.last).filter(p => p != "").join(" ") + (
  if n.jr != "" { (if suffix-comma { ", " } else { " " }) + n.jr } else { "" })

#let join-names(people, suffix-comma: true) = {
  let n = people.len()
  let out = ""
  for (i, person) in people.enumerate() {
    let nm = if is-others(person) { "et al." } else { one-name(person, suffix-comma: suffix-comma) }
    if i == 0 { out = nm }
    else if i < n - 1 { out = out + ", " + nm }
    else {
      if n > 2 { out = out + "," }
      out = out + (if is-others(person) { " " } else { " and " }) + nm
    }
  }
  out
}

#let dashify(s) = s.replace(regex("-+"), m => if m.text.len() >= 3 { "\u{2014}" } else { "\u{2013}" })
#let von-last(n) = (n.von, n.last).filter(p => p != "").join(" ")
#let date-year(e) = {
  let date = fld(e, "date", d: "")
  if has(e, "year") { fld(e, "year") } else if date.len() >= 4 { date.slice(0, 4) } else { none }
}
#let year-value(e, nodate: "[n.\u{2009}d.]") = {
  let y = date-year(e)
  (c: if y == none { nodate } else { y }, p: false)
}
