// Linear structures: linked lists, stacks, and queues.
//
// These are laid out by counting cells, so no layout pass is needed: a linked
// list and queue are a row of boxes, a stack is a column. Each builder takes a
// `style:` dict merged over the defaults and returns an object that is both
// the drawing (`diagram`) and the thing you operate on: operation fields
// return a step `(label, before, after, diagram, result)`, like the trees.
// `marks` maps `str(index)` to a highlight kind ("new"/"remove"), resolved
// against `th`'s `<kind>-style` at draw time — so a per-call
// `style:` override actually reaches the mark, not just the theme default.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled, resolve-mark-style
#import "tree.typ": trans-view
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, rect, content

#let _ann(pos, body, th) = {
  let text-style = th.pointer-text
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(pos, text(..text-style)[#body], angle: rotation)
}

#let _node-content(pos, body, th) = {
  let text-style = th.value-text
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(pos, text(..text-style)[#body], angle: rotation)
}

// Shared terminator for linked structures and chained hash buckets.
#let _null = $nothing$

// A cell with its lower-left corner at `(x, y)`. `w` and `fill` default to
// the theme's box width and fill; `mark`, when set, overrides fill/stroke via
// `mark-style` and takes priority over a plain `fill:`.
#let _cell(x, y, body, th, fill: auto, mark: none, w: auto) = {
  let ww = if w == auto { th.box-w } else { w }
  let base-fill = if fill == auto { th.box-fill } else { fill }
  let m = if mark != none { resolve-mark-style(th, mark, base-fill: base-fill) } else { none }
  let f = if m != none { m.fill } else { base-fill }
  let s = if m != none { m.stroke } else { th.box-stroke }
  let text-style = if m != none { m.text } else { th.value-text }
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let radius = if th.box-shape == "rounded" { 20% } else if th.box-shape == "capsule" { 50% } else { 0% }
  rect((x, y), (x + ww, y + th.box-h), radius: radius, stroke: s, fill: f)
  content((x + ww / 2, y + th.box-h / 2), text(..text-style)[#body], angle: rotation)
}

#let _mark(marks, i) = marks.at(str(i), default: none)

#let _insert-at(vs, index, value) = vs.slice(0, index) + (value,) + vs.slice(index)
#let _delete-at(vs, index) = vs.slice(0, index) + vs.slice(index + 1)
#let _addresses-insert(addresses, index) = if addresses == none { none } else { _insert-at(addresses, calc.min(index, addresses.len()), none) }
#let _addresses-delete(addresses, index) = if addresses == none or index >= addresses.len() { addresses } else { _delete-at(addresses, index) }
#let _path-marks(length) = {
  let marks = (:)
  for i in range(length) { marks.insert(str(i), "path") }
  marks
}

#let _head-arrow(th, x-right, cat) = {
  let mid = th.box-h / 2
  _ann((-th.box-gap - 1.0, mid), msg(cat, "list.head"), th)
  line((-th.box-gap - 0.55, mid), (x-right, mid), mark: (end: ">"), stroke: th.box-stroke)
}

// Assemble an operation step from the rendered states and the next object.
#let _step(label, before, after, result, style: (:)) = (
  label: label,
  before: before,
  after: after,
  diagram: trans-view(before, label, after, style: style),
  result: result,
)

// ── Linked list ──────────────────────────────────────────────────────────────

#let _linked-simple(vs, th, head, marks, cat) = {
  let step = th.box-w + th.box-gap
  cetz.canvas({
    for (i, v) in vs.enumerate() {
      _cell(i * step, 0, v, th, mark: _mark(marks, i))
      line(
        (i * step + th.box-w, th.box-h / 2),
        ((i + 1) * step, th.box-h / 2),
        mark: (end: ">"),
        stroke: th.box-stroke,
      )
    }
    _ann((vs.len() * step + 0.18, th.box-h / 2), _null, th)
    if head and vs.len() > 0 { _head-arrow(th, -0.05, cat) }
  })
}

// Each node is a data cell plus a tinted next-pointer cell. Optional per-node
// `addresses` are drawn underneath.
#let _linked-pointer(vs, th, addresses, head, marks, cat) = {
  let dw = th.box-w
  let nw = th.box-w * 0.85
  let nodew = dw + nw
  let step = nodew + th.box-gap
  cetz.canvas({
    for (i, v) in vs.enumerate() {
      let x = i * step
      _cell(x, 0, v, th, mark: _mark(marks, i))
      _cell(x + dw, 0, if i == vs.len() - 1 { text(size: 0.72em)[NULL] } else { [] }, th, fill: th.ptr-fill, w: nw)
      if i < vs.len() - 1 {
        line((x + nodew, th.box-h / 2), (x + step, th.box-h / 2), mark: (end: ">"), stroke: th.box-stroke)
      }
      if addresses != none and i < addresses.len() {
        _ann((x + nodew / 2, -0.32), addresses.at(i), th)
      }
    }
    if head and vs.len() > 0 { _head-arrow(th, -0.05, cat) }
  })
}

#let _linked-render(vs, th, pointer, addresses, head, marks, cat: default-catalog) = scaled(th,
  if pointer { _linked-pointer(vs, th, addresses, head, marks, cat) } else { _linked-simple(vs, th, head, marks, cat) }
)

// `insert` appends by default or inserts at `index`; `delete` removes the first
// matching value. `prepend`, `delete-at`, and `search` cover the other common
// teaching operations without changing the original call shapes.
#let _linked-obj(vs, style, pointer, addresses, head, cat) = {
  let th = resolve(style)
  let draw(vals, marks) = _linked-render(vals, th, pointer, addresses, head, marks, cat: cat)
  (
    diagram: draw(vs, (:)),
    insert: (v, index: none, step-label: none) => {
      let i = if index == none { vs.len() } else { index }
      assert(type(i) == int and i >= 0 and i <= vs.len(), message: "linked-list insert index must be between 0 and the list length")
      let after = _insert-at(vs, i, v)
      let next-addresses = _addresses-insert(addresses, i)
      _step(
      if step-label == none { if index == none { msg(cat, "list.insert", v) } else { msg(cat, "list.insert-at", v, i) } } else { step-label },
      draw(vs, (:)),
      _linked-render(after, th, pointer, next-addresses, head, (str(i): "new"), cat: cat),
      _linked-obj(after, style, pointer, next-addresses, head, cat),
      style: style,
    )
    },
    prepend: (v, step-label: none) => {
      let after = (v,) + vs
      let next-addresses = _addresses-insert(addresses, 0)
      _step(if step-label == none { msg(cat, "list.prepend", v) } else { step-label }, draw(vs, (:)),
        _linked-render(after, th, pointer, next-addresses, head, ("0": "new"), cat: cat),
        _linked-obj(after, style, pointer, next-addresses, head, cat), style: style)
    },
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      let next-addresses = if i == none { addresses } else { _addresses-delete(addresses, i) }
      _step(if step-label == none { msg(cat, "list.delete", v) } else { step-label }, draw(vs, mb),
        _linked-render(rest, th, pointer, next-addresses, head, (:), cat: cat),
        _linked-obj(rest, style, pointer, next-addresses, head, cat), style: style)
    },
    delete-at: (index, step-label: none) => {
      assert(type(index) == int and index >= 0 and index < vs.len(), message: "linked-list delete-at index must identify an existing node")
      let after = _delete-at(vs, index)
      let next-addresses = _addresses-delete(addresses, index)
      _step(if step-label == none { msg(cat, "list.delete-at", index) } else { step-label }, draw(vs, (str(index): "remove")),
        _linked-render(after, th, pointer, next-addresses, head, (:), cat: cat),
        _linked-obj(after, style, pointer, next-addresses, head, cat), style: style)
    },
    search: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let count = if i == none { vs.len() } else { i + 1 }
      _step(if step-label == none { msg(cat, "list.search", v) } else { step-label }, draw(vs, (:)), draw(vs, _path-marks(count)),
        _linked-obj(vs, style, pointer, addresses, head, cat), style: style) + (found: i != none, index: i)
    },
  )
}

#let linked-list(style: (:), pointer: false, addresses: none, head: false, language: "en", messages: (:), ..vals) = {
  _linked-obj(vals.pos(), style, pointer, addresses, head, resolve-catalog(language: language, messages: messages))
}

// ── Doubly linked list ───────────────────────────────────────────────────────

#let _double-arrows(a, b, th) = {
  let y1 = th.box-h * 0.68
  let y2 = th.box-h * 0.32
  line((a, y1), (b, y1), mark: (end: ">"), stroke: th.box-stroke)
  line((b, y2), (a, y2), mark: (end: ">"), stroke: th.box-stroke)
}

#let _doubly-simple(vs, th, head, marks, cat) = {
  let step = th.box-w + th.box-gap
  cetz.canvas({
    for (i, v) in vs.enumerate() {
      let x = i * step
      _cell(x, 0, v, th, mark: _mark(marks, i))
      if i < vs.len() - 1 {
        _double-arrows(x + th.box-w, (i + 1) * step, th)
      }
    }
    if vs.len() > 0 {
      let x = (vs.len() - 1) * step
      line((x + th.box-w, th.box-h * 0.68), (x + step, th.box-h * 0.68), mark: (end: ">"), stroke: th.box-stroke)
      _ann((x + step + 0.18, th.box-h / 2), _null, th)
      if head { _head-arrow(th, -0.05, cat) }
    } else {
      _ann((th.box-w / 2, th.box-h / 2), _null, th)
    }
  })
}

#let _doubly-pointer(vs, th, addresses, head, marks, cat) = {
  let pw = th.box-w * 0.72
  let dw = th.box-w
  let nodew = pw + dw + pw
  let step = nodew + th.box-gap
  cetz.canvas({
    for (i, v) in vs.enumerate() {
      let x = i * step
      _cell(x, 0, if i == 0 { text(size: 0.62em)[NULL] } else { [] }, th, fill: th.prev-ptr-fill, w: pw)
      _cell(x + pw, 0, v, th, mark: _mark(marks, i), w: dw)
      _cell(x + pw + dw, 0, if i == vs.len() - 1 { text(size: 0.62em)[NULL] } else { [] }, th, fill: th.next-ptr-fill, w: pw)
      if i < vs.len() - 1 {
        _double-arrows(x + nodew, (i + 1) * step, th)
      }
      if addresses != none and i < addresses.len() {
        _ann((x + nodew / 2, -0.32), addresses.at(i), th)
      }
    }
    if head and vs.len() > 0 { _head-arrow(th, -0.05, cat) }
  })
}

#let _doubly-render(vs, th, pointer, addresses, head, marks, cat: default-catalog) = scaled(th,
  if pointer { _doubly-pointer(vs, th, addresses, head, marks, cat) } else { _doubly-simple(vs, th, head, marks, cat) }
)

#let _doubly-obj(vs, style, pointer, addresses, head, cat) = {
  let th = resolve(style)
  let draw(vals, marks) = _doubly-render(vals, th, pointer, addresses, head, marks, cat: cat)
  (
    diagram: draw(vs, (:)),
    insert: (v, index: none, step-label: none) => {
      let i = if index == none { vs.len() } else { index }
      assert(type(i) == int and i >= 0 and i <= vs.len(), message: "doubly-linked-list insert index must be between 0 and the list length")
      let after = _insert-at(vs, i, v)
      let next-addresses = _addresses-insert(addresses, i)
      _step(
      if step-label == none { if index == none { msg(cat, "list.insert", v) } else { msg(cat, "list.insert-at", v, i) } } else { step-label },
      draw(vs, (:)),
      _doubly-render(after, th, pointer, next-addresses, head, (str(i): "new"), cat: cat),
      _doubly-obj(after, style, pointer, next-addresses, head, cat),
      style: style,
    )
    },
    prepend: (v, step-label: none) => {
      let after = (v,) + vs
      let next-addresses = _addresses-insert(addresses, 0)
      _step(if step-label == none { msg(cat, "list.prepend", v) } else { step-label }, draw(vs, (:)),
        _doubly-render(after, th, pointer, next-addresses, head, ("0": "new"), cat: cat),
        _doubly-obj(after, style, pointer, next-addresses, head, cat), style: style)
    },
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      let next-addresses = if i == none { addresses } else { _addresses-delete(addresses, i) }
      _step(if step-label == none { msg(cat, "list.delete", v) } else { step-label }, draw(vs, mb),
        _doubly-render(rest, th, pointer, next-addresses, head, (:), cat: cat),
        _doubly-obj(rest, style, pointer, next-addresses, head, cat), style: style)
    },
    delete-at: (index, step-label: none) => {
      assert(type(index) == int and index >= 0 and index < vs.len(), message: "doubly-linked-list delete-at index must identify an existing node")
      let after = _delete-at(vs, index)
      let next-addresses = _addresses-delete(addresses, index)
      _step(if step-label == none { msg(cat, "list.delete-at", index) } else { step-label }, draw(vs, (str(index): "remove")),
        _doubly-render(after, th, pointer, next-addresses, head, (:), cat: cat),
        _doubly-obj(after, style, pointer, next-addresses, head, cat), style: style)
    },
    search: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let count = if i == none { vs.len() } else { i + 1 }
      _step(if step-label == none { msg(cat, "list.search", v) } else { step-label }, draw(vs, (:)), draw(vs, _path-marks(count)),
        _doubly-obj(vs, style, pointer, addresses, head, cat), style: style) + (found: i != none, index: i)
    },
  )
}

#let doubly-linked-list(style: (:), pointer: false, addresses: none, head: false, language: "en", messages: (:), ..vals) = {
  _doubly-obj(vals.pos(), style, pointer, addresses, head, resolve-catalog(language: language, messages: messages))
}

// ── Stack ────────────────────────────────────────────────────────────────────

// First value is the top of the stack.
#let _stack-render(vs, th, marks, top-label) = {
  let step = th.box-h + th.box-gap * 0.35
  let label-gap = if th.box-gap > 0.45 { th.box-gap } else { 0.45 }
  scaled(th, cetz.canvas({
    for (i, v) in vs.enumerate() { _cell(0, -i * step, v, th, mark: _mark(marks, i)) }
    if vs.len() > 0 { _ann((th.box-w + label-gap, th.box-h / 2), top-label, th) }
  }))
}

#let _stack-obj(vs, style, top-label, cat) = {
  let th = resolve((box-gap: 0) + style)
  (
    diagram: _stack-render(vs, th, (:), top-label),
    push: (v, step-label: none) => _step(
      if step-label == none { msg(cat, "stack.push", v) } else { step-label },
      _stack-render(vs, th, (:), top-label),
      _stack-render((v,) + vs, th, ("0": "new"), top-label),
      _stack-obj((v,) + vs, style, top-label, cat),
      style: style,
    ),
    pop: (step-label: none) => _step(
      if step-label == none { msg(cat, "stack.pop") } else { step-label },
      _stack-render(vs, th, ("0": "remove"), top-label),
      _stack-render(vs.slice(1), th, (:), top-label),
      _stack-obj(vs.slice(1), style, top-label, cat),
      style: style,
    ),
  )
}

// `top-label: auto` uses the localized default; pass any content to override it.
#let stack(style: (:), top-label: auto, language: "en", messages: (:), ..vals) = {
  let cat = resolve-catalog(language: language, messages: messages)
  let label = if top-label == auto { msg(cat, "stack.top") } else { top-label }
  _stack-obj(vals.pos(), style, label, cat)
}

// ── Queue ────────────────────────────────────────────────────────────────────

// Cells are contiguous (array view). The `enqueue`/`dequeue` builder arguments
// draw an external element entering at the rear or leaving the front in a
// single frame; the object's operations render a before → after step instead.
#let _queue-render(vs, th, marks, enq, deq, front-label, rear-label, cat) = {
  let bw = th.box-w
  let n = vs.len()
  let w = n * bw
  let op-fill = rgb("#DCE5FB")
  scaled(th, cetz.canvas({
    for (i, v) in vs.enumerate() { _cell(i * bw, 0, v, th, mark: _mark(marks, i)) }
    if n == 1 {
      _ann((bw / 2, th.box-h + 0.38), [#front-label, #rear-label], th)
    } else if n > 1 {
      _ann((bw / 2, th.box-h + 0.38), front-label, th)
      _ann((w - bw / 2, th.box-h + 0.38), rear-label, th)
    }
    let mid = th.box-h / 2
    if enq != none {
      // External element to the right, entering the rear with a horizontal arrow.
      let ex = w + 0.95
      _cell(ex, 0, enq, th, fill: op-fill)
      line((ex, mid), (w, mid), mark: (end: ">"), stroke: th.box-stroke)
      _ann((ex + bw / 2, -0.42), msg(cat, "queue.enqueue-label"), th)
    }
    if deq != none {
      // Front element leaving to the left with a horizontal arrow.
      let dx = -0.95 - bw
      _cell(dx, 0, deq, th, fill: op-fill)
      line((0, mid), (dx + bw, mid), mark: (end: ">"), stroke: th.box-stroke)
      _ann((dx + bw / 2, -0.42), msg(cat, "queue.dequeue-label"), th)
    }
  }))
}

#let _queue-obj(vs, style, enq, deq, front-label, rear-label, cat) = {
  let th = resolve(style)
  let draw(vals, marks) = _queue-render(vals, th, marks, none, none, front-label, rear-label, cat)
  (
    diagram: _queue-render(vs, th, (:), enq, deq, front-label, rear-label, cat),
    enqueue: (v, step-label: none) => _step(
      if step-label == none { msg(cat, "queue.enqueue", v) } else { step-label },
      draw(vs, (:)),
      draw(vs + (v,), (str(vs.len()): "new")),
      _queue-obj(vs + (v,), style, enq, deq, front-label, rear-label, cat),
      style: style,
    ),
    dequeue: (step-label: none) => _step(
      if step-label == none { msg(cat, "queue.dequeue") } else { step-label },
      draw(vs, ("0": "remove")),
      draw(vs.slice(1), (:)),
      _queue-obj(vs.slice(1), style, enq, deq, front-label, rear-label, cat),
      style: style,
    ),
  )
}

// `front-label`/`rear-label: auto` use the localized defaults; pass any content
// to override either one.
#let queue(
  style: (:),
  enqueue: none,
  dequeue: none,
  front-label: auto,
  rear-label: auto,
  language: "en",
  messages: (:),
  ..vals,
) = {
  let cat = resolve-catalog(language: language, messages: messages)
  let front = if front-label == auto { msg(cat, "queue.front") } else { front-label }
  let rear = if rear-label == auto { msg(cat, "queue.rear") } else { rear-label }
  _queue-obj(vals.pos(), style, enqueue, dequeue, front, rear, cat)
}

// `marks` is an array of `(level, index, kind)` triples, so one physical
// node can carry the same highlight kind across every level it appears at.
#let _skip-list-mark-at(marks, level, i) = {
  for m in marks {
    if m.at(0) == level and m.at(1) == i { return m.at(2) }
  }
  none
}

#let _skip-list-row(vs, marks, th, level-filter, level, level-spacing) = {
  let step = th.box-w + th.box-gap
  let level-offset = level-spacing * level

  for (i, v) in vs.enumerate() {
    if not level-filter.at(i) {
      continue
    }
    _cell(i * step, level-offset, v, th, mark: _skip-list-mark-at(marks, level, i))

    // line to item directly below
    if level != 0 {
      line(
        (i * step + th.box-w / 2, level-offset),
        (i * step + th.box-w / 2, th.box-h + (level-offset - level-spacing)),
        mark: (end: ">"),
        stroke: th.box-stroke,
      )
    }

    // line to next node (left to right)
    let next-visible-i = level-filter.enumerate().position(n => n.at(0) > i and n.at(1))
    if next-visible-i == none {
      next-visible-i = vs.len() // nothing element
    }
    line(
      (i * step + th.box-w, th.box-h / 2 + level-offset),
      (next-visible-i * step, th.box-h / 2 + level-offset),
      mark: (end: ">"),
      stroke: th.box-stroke,
    )
  }
  _node-content((vs.len() * step + th.box-w / 2, th.box-h / 2 + level-offset), $nothing$, th)
}

#let _simple-skip-list(vs, marks, th, level-filters, level-spacing) = {
  scaled(th, cetz.canvas({
    for (level, level-filter) in level-filters.enumerate() {
      _skip-list-row(vs, marks, th, level-filter, int(level), level-spacing)
    }
  }))
}

// Which node indices are present at each level, level 0 first. A node is
// present at every level up to its own assigned height.
// The tallest element is conventionally a sentinel head that spans every
// level on its own, not a promoted data value (see the skip list article's
// "Implementation details"). This library has no separate head box, so the
// first real value stands in for it and is always drawn at every level,
// regardless of what its own height would otherwise be.
#let _skip-list-top(nodes) = calc.max(0, ..nodes.map(n => n.level))

#let _skip-list-height(nodes, i) = if i == 0 { _skip-list-top(nodes) } else { nodes.at(i).level }

#let _skip-list-level-filters(nodes) = {
  let top = _skip-list-top(nodes)
  range(top + 1).map(level => nodes.enumerate().map(((i, n)) => i == 0 or n.level >= level))
}

// A cheap, deterministic stand-in for a coin flip: Typst has no RNG, and
// diagrams need to stay reproducible across recompiles, so the same value
// always hashes the same way regardless of how many other nodes exist.
#let _skip-list-hash(value, salt) = {
  let h = 0
  for b in bytes(str(value) + "#" + str(salt)) {
    h = calc.rem(h * 31 + b, 1000000007)
  }
  h
}

// Default `decision-fn`: promotes `value` to `level` about half the time.
// It depends only on the value and the level being tested, never on the
// value's position or how many other nodes exist, so a node's height stays
// fixed once assigned — inserting or deleting elsewhere never reshuffles it.
#let default-decision-fn(level, value) = calc.rem(_skip-list-hash(value, level), 2) == 0

// The height for one node: keeps promoting while `decision-fn` says yes,
// capped at `max-level`.
#let _skip-list-node-level(value, decision-fn, max-level) = {
  let level = 0
  while level < max-level {
    let promote = decision-fn(level + 1, value)
    assert(type(promote) == bool, message: "skip-list decision-fn must return a boolean")
    if not promote { break }
    level += 1
  }
  level
}

#let _skip-list-is-number(value) = type(value) == int or type(value) == float
#let _skip-list-is-value(value) = _skip-list-is-number(value) or type(value) == str
#let _skip-list-compatible(a, b) = (_skip-list-is-number(a) and _skip-list-is-number(b)) or (type(a) == str and type(b) == str)

#let _validate-skip-list-values(vs) = {
  for value in vs {
    assert(_skip-list-is-value(value), message: "skip-list values must be int, float, or str")
  }
  let i = 1
  while i < vs.len() {
    let previous = vs.at(i - 1)
    let value = vs.at(i)
    assert(_skip-list-compatible(previous, value), message: "skip-list values must all be numbers or all be strings")
    assert(previous < value, message: "skip-list values must be strictly ascending with no duplicates")
    i += 1
  }
}

#let _validate-skip-list-insert(nodes, value, level) = {
  assert(_skip-list-is-value(value), message: "skip-list values must be int, float, or str")
  if nodes.len() > 0 {
    assert(_skip-list-compatible(nodes.first().value, value), message: "skip-list values must all be numbers or all be strings")
  }
  assert(not (value in nodes.map(n => n.value)), message: "skip-list insert value must not already be present")
  if level != auto {
    assert(type(level) == int and level >= 0, message: "skip-list insert level must be a non-negative integer")
  }
}

#let _validate-skip-list-key(nodes, key) = {
  assert(_skip-list-is-value(key), message: "skip-list keys must be int, float, or str")
  if nodes.len() > 0 {
    assert(_skip-list-compatible(nodes.first().value, key), message: "skip-list keys must be compatible with the list values")
  }
}

// Returns the list of `(level, column-index, "path")` marks tracing the
// search path down to `key`, or to its predecessor when it is absent.
#let _skip-list-search-marks(vs, level-filters, key) = {
  let key-index = 0
  for (i, value) in vs.enumerate() {
    if value <= key { key-index = i } else { break }
  }

  let marks = ()

  let current-column = 0
  for (current-level, level-filter) in level-filters.enumerate().rev() {
    let next-entry-indices = level-filter.enumerate().filter(l => l.at(0) >= current-column and l.at(1)).map(l => l.at(0))
    if next-entry-indices.len() == 0 { continue }
    let next-entry-index = next-entry-indices.remove(0)

    while next-entry-index != none and next-entry-index <= key-index {
      marks.push((current-level, next-entry-index, "path"))
      current-column = next-entry-index

      if key-index == next-entry-index or next-entry-indices.len() == 0 {
          break
      }
      next-entry-index = next-entry-indices.remove(0)
    }
  }

  marks
}

// Skip-list state is an array of `(value:, level:)` nodes, sorted by
// value. Keeping each node's assigned level explicit (rather than
// re-deriving it from array position on every render) is what lets insert
// and delete touch only the node that actually changed.
#let _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level, cat) = {
  let th = resolve(style)
  let draw(ns, marks) = _simple-skip-list(ns.map(n => n.value), marks, th, _skip-list-level-filters(ns), level-spacing)

  (
    diagram: draw(nodes, ()),
    search: (key, step-label: none) => {
      _validate-skip-list-key(nodes, key)
      _step(
        if step-label == none { msg(cat, "skip.search", key) } else { step-label },
        draw(nodes, ()),
        draw(nodes, _skip-list-search-marks(nodes.map(n => n.value), _skip-list-level-filters(nodes), key)),
        _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level, cat),
        style: style,
      ) + (found: key in nodes.map(n => n.value), index: nodes.position(n => n.value == key))
    },
    // `level: auto` assigns the new value's height with `decision-fn`;
    // pass an explicit level to force a specific tower height instead.
    insert: (value, level: auto, step-label: none) => {
      _validate-skip-list-insert(nodes, value, level)
      let assigned = if level == auto { _skip-list-node-level(value, decision-fn, max-level) } else { level }
      let i = 0
      while i < nodes.len() and nodes.at(i).value < value { i += 1 }
      let new-nodes = nodes.slice(0, i) + ((value: value, level: assigned),) + nodes.slice(i)
      let marks = range(_skip-list-height(new-nodes, i) + 1).map(l => (l, i, "new"))
      _step(
        if step-label == none { msg(cat, "skip.insert", value) } else { step-label },
        draw(nodes, ()),
        draw(new-nodes, marks),
        _skip-list-obj(new-nodes, style, decision-fn, level-spacing, max-level, cat),
        style: style,
      )
    },
    delete: (value, step-label: none) => {
      _validate-skip-list-key(nodes, value)
      let i = nodes.position(n => n.value == value)
      assert(i != none, message: "delete key is not part of skip list")
      let marks = range(_skip-list-height(nodes, i) + 1).map(l => (l, i, "remove"))
      let rest = nodes.slice(0, i) + nodes.slice(i + 1)
      _step(
        if step-label == none { msg(cat, "skip.delete", value) } else { step-label },
        draw(nodes, marks),
        draw(rest, ()),
        _skip-list-obj(rest, style, decision-fn, level-spacing, max-level, cat),
        style: style,
      )
    },
  )
}

#let skip-list(style: (:), decision-fn: default-decision-fn, level-spacing: 1.4, max-level: 4, language: "en", messages: (:), ..vals) = {
  let values = vals.pos()
  assert(type(max-level) == int and max-level >= 0, message: "skip-list max-level must be a non-negative integer")
  assert((type(level-spacing) == int or type(level-spacing) == float) and level-spacing > 0, message: "skip-list level-spacing must be a positive number")
  _validate-skip-list-values(values)
  let nodes = values.map(v => (value: v, level: _skip-list-node-level(v, decision-fn, max-level)))
  _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level, resolve-catalog(language: language, messages: messages))
}
