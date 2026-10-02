// Content splitting.
//
// Content is cut into "units" (roughly CJK clusters, punctuation, words and
// spaces) so that the flow functions can measure and redistribute it. These
// helpers are shared by all flow functions and are not part of the public API.

#let _re-han = regex("^\p{script=Han}$")


#let _lead-punct = "（【《〈「『〔［｛“‘"
#let _trail-punct = "），、。；：？！》】〉」』〕］｝”’…—"

#let _is-han(c) = c != "" and c.matches(_re-han).len() > 0

#let _is-lead(c) = c != "" and _lead-punct.contains(c)

#let _is-trail(c) = c != "" and _trail-punct.contains(c)

#let _is-space(c) = c in (" ", "　", "\t", "\u{00A0}")

#let _space = [ ]

#let _all-ascii-space(s) = s != "" and s.clusters().all(c => c == " ")

// Elements that are transparently unwrapped when splitting styled text.
#let _transparent = (emph, strong, underline, overline, strike, highlight, smallcaps, sub, super, link, align)

#let _is-styled-text(cont) = cont.has("child") and cont.has("styles")

// Extract the plain text of a unit, or `none` when the unit is not simple
// styled text. Used to detect all-lead/all-trail units for punctuation gluing.
#let _unit-text(u) = {
  if type(u) == str { return u }
  if type(u) != content { return none }
  if u.has("text") {
    let t = u.text
    if type(t) == str { return t }
    return _unit-text(t)
  }
  if _is-styled-text(u) { return _unit-text(u.child) }
  if u.func() in _transparent and u.has("body") { return _unit-text(u.body) }
  if repr(u.func()) == "sequence" {
    let s = ""
    for child in u.children {
      let cs = _unit-text(child)
      if cs == none { return none }
      s += cs
    }
    return s
  }
  none
}

#let _all-lead(u) = {
  let s = _unit-text(u)
  s != none and s != "" and s.clusters().all(_is-lead)
}

#let _all-trail(u) = {
  let s = _unit-text(u)
  s != none and s != "" and s.clusters().all(_is-trail)
}

// Merge leading/trailing punctuation into neighbouring units so that a unit is
// never split between a punctuation mark and the character it belongs to.
#let _glue(units) = {
  let out = ()
  let pending = none
  for u in units {
    if pending != none {
      u = pending + u
      pending = none
    }
    if _all-lead(u) {
      pending = u
    } else if _all-trail(u) and out.len() > 0 {
      let i = out.len() - 1
      let merged = out.at(i) + u
      out = out.slice(0, i)
      out.push(merged)
    } else {
      out.push(u)
    }
  }
  if pending != none {
    out.push(pending)
  }
  out
}

#let _split-string(s) = {
  let tokens = ()
  let current = ""
  for c in s.clusters() {
    if _is-han(c) or _is-lead(c) or _is-trail(c) {
      if current != "" {
        tokens.push(current)
        current = ""
      }
      tokens.push(c)
    } else if _is-space(c) {
      if current != "" {
        tokens.push(current)
        current = ""
      }
      if tokens.len() == 0 or not _all-ascii-space(tokens.last()) {
        tokens.push(c)
      }
    } else {
      current += c
    }
  }
  if current != "" {
    tokens.push(current)
  }
  _glue(tokens).map(t => {
    if type(t) != str {
      t
    } else if _all-ascii-space(t) {
      _space
    } else {
      text(t)
    }
  })
}

// Rebuild a styled element from its split body. Labels are not constructor
// arguments and are moved to the rebuilt element.
#let _rebuild-body(func, fields, inner) = {
  let lbl = if "label" in fields { fields.remove("label") } else { none }
  let out = if func == link {
    let dest = fields.remove("dest")
    func(dest, inner, ..fields)
  } else if func == align {
    let alignment = fields.remove("alignment")
    func(alignment, inner, ..fields)
  } else {
    func(inner, ..fields)
  }
  if lbl == none { out } else { [#out#label(str(lbl))] }
}

#let _split-text-element(cont, split) = {
  let func = cont.func()
  let fields = cont.fields()
  let lbl = if "label" in fields { fields.remove("label") } else { none }
  let pieces = if cont.has("text") {
    let inner = fields.remove("text")
    let pieces = if type(inner) == str { _split-string(inner) } else { split(inner) }
    if fields.len() == 0 { pieces } else { pieces.map(p => func(..fields, p)) }
  } else {
    let inner = fields.remove("child")
    let styles = fields.remove("styles")
    let pieces = if type(inner) == str { _split-string(inner) } else { split(inner) }
    pieces.map(p => func(p, styles, ..fields))
  }
  // Keep the label on the last piece so its position is preserved.
  if lbl == none or pieces.len() == 0 { pieces } else {
    pieces.slice(0, pieces.len() - 1) + ([#pieces.last()#label(str(lbl))],)
  }
}

#let _split-wrapper(cont, split) = {
  let func = cont.func()
  let fields = cont.fields()
  let inner = fields.remove("body")
  let lbl = if "label" in fields { fields.remove("label") } else { none }
  let pieces = split(inner).map(p => _rebuild-body(func, fields, p))
  if lbl == none or pieces.len() == 0 { pieces } else {
    pieces.slice(0, pieces.len() - 1) + ([#pieces.last()#label(str(lbl))],)
  }
}

#let _split-units(cont) = {
  if type(cont) == str {
    return _split-string(cont)
  }
  if type(cont) != content {
    return (cont,)
  }
  let func = cont.func()
  if repr(func) == "sequence" {
    return _glue(cont.children.map(_split-units).flatten())
  }
  if func == text or (_is-styled-text(cont) and _unit-text(cont) != none) {
    return _split-text-element(cont, _split-units)
  }
  if func in _transparent and cont.has("body") {
    return _split-wrapper(cont, _split-units)
  }
  (cont,)
}

/// Split content into reflowable units. The unit boundaries are the CJK
/// characters, punctuation and whitespace runs that the flow functions need in
/// order to break content at the right places.
///
/// -> array
#let split-content(cont) = {
  _split-units(cont)
}

#let _join(units) = if units.len() == 0 { [] } else { units.join() }
