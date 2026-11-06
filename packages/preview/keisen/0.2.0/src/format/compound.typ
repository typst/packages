///! Alignment inside a combined cell.
///!
///! A combine pattern is a closure that returns content, so what it builds
///! cannot be read back directly. The pattern is called once more with a
///! marker in place of each source value, and the content it returns is split
///! at the markers: the markers are the values, everything between them is
///! glue. Each value then lines up down the column on its own separator, and
///! each piece of glue lines up with the glue at the same place in other rows.

#import "align.typ": align-slots, column-metrics

// A private-use character fences each marker, so no text a pattern writes is
// mistaken for one.
#let _FENCE = "\u{F8FF}"
#let _marker-text(index) = _FENCE + str(index) + _FENCE

// A marker for the source at `index`, counted from 0 in `from` order. It is
// text, like the formatted content a pattern otherwise receives, so a pattern
// that reads `.text` from its values runs on it too.
#let value-marker(index) = text(_marker-text(index))

#let _marker-index(body) = {
  if type(body) != content or body.func() != text { return none }
  let found = body.text.match(regex("^" + _FENCE + "(\\d+)" + _FENCE + "$"))
  if found == none { none } else { int(found.captures.first()) }
}

// The children of a content tree, with nested sequences expanded in place and
// empty sequences and empty text dropped. `+` flattens a sequence it joins and
// markup nests it, so two calls that build the same text can differ only in
// nesting; this is the form they are compared in. A serialised template
// writes an empty text node before a leading value, which is no glue.
#let flatten(body) = {
  if type(body) != content { return (body,) }
  if body.func() == [].func() { return body.children.map(flatten).join(default: ()) }
  if body.func() == text and body.text == "" { return () }
  (body,)
}

// The marker an element wraps, when the marker is its only content: `strong`,
// `emph` and `highlight` hold it as `body`. A `text(..)` call with settings
// returns a styled element instead, whose settings cannot be compared with
// another row's, so a pattern that picks them from its values would go
// unnoticed; it is not a wrapper, and the cell does not split.
#let _wrapped-index(element) = {
  let fields = element.fields()
  if "body" in fields { _marker-index(fields.body) } else { none }
}

// Whether a marker sits anywhere inside an element, however deep, including
// inside a longer string a pattern built from one.
#let _holds-marker(element) = {
  if type(element) != content { return false }
  if element.func() == text { return element.text.contains(_FENCE) }
  if element.func() == [].func() { return element.children.any(_holds-marker) }
  element.fields().values().any(field => (
    (type(field) == content and _holds-marker(field))
      or (type(field) == array and field.any(_holds-marker))
  ))
}

// The pieces of a pattern's output, in order: `(kind: "value", index,
// wrapper)` or `(kind: "glue", body)`. `wrapper` is the element around the
// marker, or `none` for a bare one. Returns `none` when the output cannot be
// split: a marker nested deeper than one wrapper, a source written twice or
// left out.
#let split-pattern(output, count) = {
  let pieces = ()
  let glue = ()
  let seen = ()
  for child in flatten(output) {
    let index = _marker-index(child)
    let wrapper = none
    if index == none and type(child) == content {
      index = _wrapped-index(child)
      if index != none { wrapper = child }
    }
    if index == none {
      // A run of boxes is one line, so glue that breaks it does not split.
      if _holds-marker(child) or child.func() in (linebreak, parbreak) { return none }
      glue.push(child)
      continue
    }
    if index in seen { return none }
    seen.push(index)
    if glue.len() > 0 { pieces.push((kind: "glue", body: glue.join())) }
    glue = ()
    pieces.push((kind: "value", index: index, wrapper: wrapper))
  }
  if glue.len() > 0 { pieces.push((kind: "glue", body: glue.join())) }
  if seen.sorted() != range(count) { return none }
  pieces
}

// Whether the split of `marker-output` describes `real-output`, the pattern's
// output for `values`. The marker call cannot see a pattern that branches on
// its values, such as one that drops a missing error, so the split is kept
// only when putting each value back where its marker was gives exactly the
// real output. Both sides are compared flattened, since `+` and markup nest
// the same value differently.
//
// A wrapper is compared field by field around its value.
#let split-matches(marker-output, real-output, values) = {
  let real = flatten(real-output)
  let at = 0
  for child in flatten(marker-output) {
    let index = _marker-index(child)
    if index != none {
      let expected = flatten(values.at(index))
      if real.slice(at, calc.min(at + expected.len(), real.len())) != expected { return false }
      at += expected.len()
      continue
    }
    if at >= real.len() { return false }
    let found = real.at(at)
    at += 1
    let wrapped = if type(child) == content { _wrapped-index(child) } else { none }
    if wrapped == none {
      if found != child { return false }
      continue
    }
    if type(found) != content or found.func() != child.func() { return false }
    let mine = child.fields()
    let theirs = found.fields()
    if mine.keys().sorted() != theirs.keys().sorted() { return false }
    for (name, field) in mine {
      if name == "body" {
        if flatten(theirs.at(name)) != flatten(values.at(wrapped)) { return false }
      } else if theirs.at(name) != field {
        return false
      }
    }
  }
  at == real.len()
}

// A value's content inside the element the pattern wrapped it in. The marker
// the wrapper holds is replaced by a show rule, which keeps every setting the
// wrapper carries without rebuilding it.
#let _dressed(body, piece) = {
  if piece.wrapper == none { return body }
  show _marker-text(piece.index): _ => body
  piece.wrapper
}

// Glue as it renders in its box. A space at the edge of a box is dropped, so
// each space becomes a non-breaking one, which is kept and measures the same.
#let _glue(body) = flatten(body).map(child => if child.func() == [ ].func() { [#sym.space.nobreak] } else { child }).join(default: [])

#let _is-number(value) = type(value) == dictionary and value.at("kind", default: none) == "number"
#let _is-compound(value) = type(value) == dictionary and value.at("kind", default: none) == "compound"
#let _opaque(value) = if type(value) == content { value } else { [#value] }

// The widest rendering of each piece of a combined column, measured in each
// cell's text style. A value position holds the decimal metrics of the numbers
// in it, and a width that also covers the widest value that is not a number,
// such as a substituted gap. Returns `none` when no cell in the column split.
#let compound-metrics(cells, styles) = {
  let rows = cells.zip(styles).filter(((cell, style)) => _is-compound(cell))
  if rows.len() == 0 { return none }
  let in-style(body, style) = measure(if style == none { body } else { text(..style, body) }).width
  let widest(widths) = calc.max(0pt, ..widths)

  let pieces = rows.first().first().pieces.enumerate().map(((position, piece)) => {
    let entries = rows.map(((cell, style)) => (piece: cell.pieces.at(position), style: style))
    if piece.kind == "glue" {
      return (kind: "glue", width: widest(entries.map(entry => in-style(_glue(entry.piece.body), entry.style))))
    }
    let number = column-metrics(
      entries.map(entry => entry.piece.value),
      styles: entries.map(entry => entry.style),
      dress: body => _dressed(body, piece),
    )
    let numbers = if number == none { 0pt } else { number.values().sum() }
    let opaque = entries
      .filter(entry => not _is-number(entry.piece.value))
      .map(entry => in-style(_dressed(_opaque(entry.piece.value), entry.piece), entry.style))
    (kind: "value", number: number, width: calc.max(numbers, widest(opaque)))
  })
  (kind: "compound", pieces: pieces)
}

// Each piece of a compound cell as it renders inside its box: a number padded
// to its position's decimal metrics, anything else as it is, both inside the
// pattern's wrapper.
#let compound-pieces(cell, metric) = cell.pieces.enumerate().map(((position, piece)) => {
  if piece.kind == "glue" { return _glue(piece.body) }
  let measures = metric.pieces.at(position)
  let body = if _is-number(piece.value) and measures.number != none {
    align-slots(piece.value, measures.number)
  } else {
    _opaque(piece.value)
  }
  _dressed(body, piece)
})

// A compound cell laid out as a run of boxes, one per piece, each as wide as
// its position is down the column. Values sit against the end of their box, as
// a number does in its column, and glue against the start of its box, so a
// comma stays beside the value before it when a bold row widens the box. The run is pinned left to right like
// a single number, which reads left to right in every script. Overhang is off:
// it lets a value's last full stop hang past its box, where the glue that
// follows covers it, and `n.e.` reads as `n.e`.
//
// A run of boxes cannot wrap, so in a column narrower than the run the cell
// falls back to the pattern's own content, which can.
#let align-compound(cell, metric) = layout(size => {
  if metric.pieces.map(piece => piece.width).sum() > size.width { return cell.real }
  text(dir: ltr, overhang: false, {
    for (position, body) in compound-pieces(cell, metric).enumerate() {
      let measures = metric.pieces.at(position)
      let placement = if measures.kind == "glue" { left } else { right }
      box(width: measures.width, align(placement, body))
    }
  })
})
