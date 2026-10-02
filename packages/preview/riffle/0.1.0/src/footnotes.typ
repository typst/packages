// Footnotes are pulled out of the content and rendered manually: Typst would
// otherwise collect them in the page (root) flow and place the entries at page
// width, which does not match the reflowed content area. The rendered recipe
// mirrors Typst's `footnote.entry` defaults:
// separator 30% at 0.05em, clearance 1em, gap 0.5em, indent 1em (at 0.85em),
// entry text 0.85em with 0.5em leading.

#import "content.typ": _is-styled-text, _join, _rebuild-body, _transparent

// Elements whose body should also be searched when pulling footnotes out of the
// flow (footnotes may be nested in headings, e.g. in exercise descriptions).
#let _fn-transparent = _transparent + (heading,)

#let _fn-num(fmt, n) = numbering(fmt, n)

#let _fn-key(l) = str(l)

#let _fn-collect(cont, out) = {
  if type(cont) != content { return out }
  let func = cont.func()
  if repr(func) == "sequence" {
    for c in cont.children { out = _fn-collect(c, out) }
    return out
  }
  if func == footnote {
    let fields = cont.fields()
    let body = fields.at("body")
    if type(body) != label {
      let l = fields.at("label", default: none)
      out.push((
        numbering: fields.at("numbering", default: "1"),
        body: body,
        label: if l == none { none } else { _fn-key(l) },
      ))
    }
    return out
  }
  if _is-styled-text(cont) {
    return _fn-collect(cont.fields().at("child"), out)
  }
  if func in _fn-transparent and cont.has("body") {
    return _fn-collect(cont.fields().at("body"), out)
  }
  out
}

// Collect all footnotes in `units` (in document order) and number them starting
// at `base + 1`. Returns the notes, a label map and, for each note, the index of
// the unit it belongs to.
#let _fn-scan(units, base) = {
  let collected = ()
  let counts = ()
  for u in units {
    let before = collected.len()
    collected = _fn-collect(u, collected)
    counts.push(collected.len() - before)
  }
  let notes = ()
  let map = (:)
  for (i, note) in collected.enumerate() {
    notes.push((
      numbering: note.numbering,
      body: note.body,
      label: note.label,
      n: base + i + 1,
    ))
    if note.label != none { map.insert(note.label, i) }
  }
  let unit-of-note = ()
  for (j, c) in counts.enumerate() {
    for _ in range(c) { unit-of-note.push(j) }
  }
  (notes: notes, map: map, unit-of-note: unit-of-note)
}

#let _fn-mark(note) = {
  counter(footnote).step()
  super(_fn-num(note.numbering, note.n))
}

// Replace every footnote and footnote reference by its superscript mark so the
// notes can be rendered separately by `_fn-area`.
#let _fn-rewrite(cont, fns, cursor) = {
  if type(cont) == str { return (cont, cursor) }
  if type(cont) != content { return (cont, cursor) }
  let func = cont.func()
  if repr(func) == "sequence" {
    let out = ()
    for c in cont.children {
      let (c2, cur2) = _fn-rewrite(c, fns, cursor)
      out.push(c2)
      cursor = cur2
    }
    return (_join(out), cursor)
  }
  if func == footnote {
    let body = cont.fields().at("body")
    if type(body) == label {
      let key = _fn-key(body)
      if key in fns.map {
        let target = fns.notes.at(fns.map.at(key))
        return (super(_fn-num(target.numbering, target.n)), cursor)
      }
      return (cont, cursor)
    }
    let note = fns.notes.at(cursor)
    return (_fn-mark(note), cursor + 1)
  }
  if func == ref {
    let t = cont.fields().at("target", default: none)
    if t != none and _fn-key(t) in fns.map {
      let target = fns.notes.at(fns.map.at(_fn-key(t)))
      return (super(_fn-num(target.numbering, target.n)), cursor)
    }
    return (cont, cursor)
  }
  if _is-styled-text(cont) {
    let fields = cont.fields()
    let child = fields.remove("child")
    let styles = fields.remove("styles")
    let (c2, cur2) = _fn-rewrite(child, fns, cursor)
    return (func(c2, styles, ..fields), cur2)
  }
  if func in _fn-transparent and cont.has("body") {
    let fields = cont.fields()
    let inner = fields.remove("body")
    let (c2, cur2) = _fn-rewrite(inner, fns, cursor)
    return (_rebuild-body(func, fields, c2), cur2)
  }
  (cont, cursor)
}

#let _fn-rewrite-all(units, fns) = {
  let out = ()
  let cursor = 0
  for u in units {
    let (c, cur2) = _fn-rewrite(u, fns, cursor)
    out.push(c)
    cursor = cur2
  }
  out
}

// Render a footnote area. `entry` accepts the same keys as `footnote.entry`
// (`clearance`, `gap`, `separator`, `indent`, `size`, `leading`, `style`).
#let _fn-area(notes, entry: (:)) = {
  let opt(key, default) = entry.at(key, default: default)
  let clearance = opt("clearance", auto)
  let gap = opt("gap", auto)
  let separator = opt("separator", auto)
  let indent = opt("indent", auto)
  let size = opt("size", auto)
  let leading = opt("leading", auto)
  let style = opt("style", none)
  let out = []
  out += v(if clearance == auto { 1em } else { clearance })
  if separator == auto {
    out += line(length: 30%, stroke: 0.05em)
  } else if separator != none {
    out += separator
  }
  for note in notes {
    out += v(if gap == auto { 0.5em } else { gap })
    let inner = {
      set text(size: if size == auto { 0.85em } else { size })
      set par(leading: if leading == auto { 0.5em } else { leading })
      h(if indent == auto { 1em } else { indent })
      super(_fn-num(note.numbering, note.n))
      h(0.05em, weak: true)
      note.body
    }
    out += block(
      width: 100%,
      above: 0pt,
      below: 0pt,
      inset: 0pt,
      outset: 0pt,
      if style == none { inner } else { style(inner) },
    )
  }
  out
}
