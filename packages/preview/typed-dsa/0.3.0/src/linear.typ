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

#let _head-arrow(th, x-right) = {
  let mid = th.box-h / 2
  _ann((-th.box-gap - 1.0, mid), [Head], th)
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

#let _linked-simple(vs, th, head, marks) = {
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
    if head and vs.len() > 0 { _head-arrow(th, -0.05) }
  })
}

// Each node is a data cell plus a tinted next-pointer cell. Optional per-node
// `addresses` are drawn underneath.
#let _linked-pointer(vs, th, addresses, head, marks) = {
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
    if head and vs.len() > 0 { _head-arrow(th, -0.05) }
  })
}

#let _linked-render(vs, th, pointer, addresses, head, marks) = scaled(th,
  if pointer { _linked-pointer(vs, th, addresses, head, marks) } else { _linked-simple(vs, th, head, marks) }
)

// `insert` appends by default or inserts at `index`; `delete` removes the first
// matching value. `prepend`, `delete-at`, and `search` cover the other common
// teaching operations without changing the original call shapes.
#let _linked-obj(vs, style, pointer, addresses, head) = {
  let th = resolve(style)
  let draw(vals, marks) = _linked-render(vals, th, pointer, addresses, head, marks)
  (
    diagram: draw(vs, (:)),
    insert: (v, index: none, step-label: none) => {
      let i = if index == none { vs.len() } else { index }
      assert(type(i) == int and i >= 0 and i <= vs.len(), message: "linked-list insert index must be between 0 and the list length")
      let after = _insert-at(vs, i, v)
      let next-addresses = _addresses-insert(addresses, i)
      _step(
      if step-label == none { if index == none { [insert #v] } else { [insert #v at #i] } } else { step-label },
      draw(vs, (:)),
      _linked-render(after, th, pointer, next-addresses, head, (str(i): "new")),
      _linked-obj(after, style, pointer, next-addresses, head),
      style: style,
    )
    },
    prepend: (v, step-label: none) => {
      let after = (v,) + vs
      let next-addresses = _addresses-insert(addresses, 0)
      _step(if step-label == none { [prepend #v] } else { step-label }, draw(vs, (:)),
        _linked-render(after, th, pointer, next-addresses, head, ("0": "new")),
        _linked-obj(after, style, pointer, next-addresses, head), style: style)
    },
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      let next-addresses = if i == none { addresses } else { _addresses-delete(addresses, i) }
      _step(if step-label == none { [delete #v] } else { step-label }, draw(vs, mb),
        _linked-render(rest, th, pointer, next-addresses, head, (:)),
        _linked-obj(rest, style, pointer, next-addresses, head), style: style)
    },
    delete-at: (index, step-label: none) => {
      assert(type(index) == int and index >= 0 and index < vs.len(), message: "linked-list delete-at index must identify an existing node")
      let after = _delete-at(vs, index)
      let next-addresses = _addresses-delete(addresses, index)
      _step(if step-label == none { [delete index #index] } else { step-label }, draw(vs, (str(index): "remove")),
        _linked-render(after, th, pointer, next-addresses, head, (:)),
        _linked-obj(after, style, pointer, next-addresses, head), style: style)
    },
    search: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let count = if i == none { vs.len() } else { i + 1 }
      _step(if step-label == none { [search #v] } else { step-label }, draw(vs, (:)), draw(vs, _path-marks(count)),
        _linked-obj(vs, style, pointer, addresses, head), style: style) + (found: i != none, index: i)
    },
  )
}

#let linked-list(style: (:), pointer: false, addresses: none, head: false, ..vals) = {
  _linked-obj(vals.pos(), style, pointer, addresses, head)
}

// ── Doubly linked list ───────────────────────────────────────────────────────

#let _double-arrows(a, b, th) = {
  let y1 = th.box-h * 0.68
  let y2 = th.box-h * 0.32
  line((a, y1), (b, y1), mark: (end: ">"), stroke: th.box-stroke)
  line((b, y2), (a, y2), mark: (end: ">"), stroke: th.box-stroke)
}

#let _doubly-simple(vs, th, head, marks) = {
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
      if head { _head-arrow(th, -0.05) }
    } else {
      _ann((th.box-w / 2, th.box-h / 2), _null, th)
    }
  })
}

#let _doubly-pointer(vs, th, addresses, head, marks) = {
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
    if head and vs.len() > 0 { _head-arrow(th, -0.05) }
  })
}

#let _doubly-render(vs, th, pointer, addresses, head, marks) = scaled(th,
  if pointer { _doubly-pointer(vs, th, addresses, head, marks) } else { _doubly-simple(vs, th, head, marks) }
)

#let _doubly-obj(vs, style, pointer, addresses, head) = {
  let th = resolve(style)
  let draw(vals, marks) = _doubly-render(vals, th, pointer, addresses, head, marks)
  (
    diagram: draw(vs, (:)),
    insert: (v, index: none, step-label: none) => {
      let i = if index == none { vs.len() } else { index }
      assert(type(i) == int and i >= 0 and i <= vs.len(), message: "doubly-linked-list insert index must be between 0 and the list length")
      let after = _insert-at(vs, i, v)
      let next-addresses = _addresses-insert(addresses, i)
      _step(
      if step-label == none { if index == none { [insert #v] } else { [insert #v at #i] } } else { step-label },
      draw(vs, (:)),
      _doubly-render(after, th, pointer, next-addresses, head, (str(i): "new")),
      _doubly-obj(after, style, pointer, next-addresses, head),
      style: style,
    )
    },
    prepend: (v, step-label: none) => {
      let after = (v,) + vs
      let next-addresses = _addresses-insert(addresses, 0)
      _step(if step-label == none { [prepend #v] } else { step-label }, draw(vs, (:)),
        _doubly-render(after, th, pointer, next-addresses, head, ("0": "new")),
        _doubly-obj(after, style, pointer, next-addresses, head), style: style)
    },
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      let next-addresses = if i == none { addresses } else { _addresses-delete(addresses, i) }
      _step(if step-label == none { [delete #v] } else { step-label }, draw(vs, mb),
        _doubly-render(rest, th, pointer, next-addresses, head, (:)),
        _doubly-obj(rest, style, pointer, next-addresses, head), style: style)
    },
    delete-at: (index, step-label: none) => {
      assert(type(index) == int and index >= 0 and index < vs.len(), message: "doubly-linked-list delete-at index must identify an existing node")
      let after = _delete-at(vs, index)
      let next-addresses = _addresses-delete(addresses, index)
      _step(if step-label == none { [delete index #index] } else { step-label }, draw(vs, (str(index): "remove")),
        _doubly-render(after, th, pointer, next-addresses, head, (:)),
        _doubly-obj(after, style, pointer, next-addresses, head), style: style)
    },
    search: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let count = if i == none { vs.len() } else { i + 1 }
      _step(if step-label == none { [search #v] } else { step-label }, draw(vs, (:)), draw(vs, _path-marks(count)),
        _doubly-obj(vs, style, pointer, addresses, head), style: style) + (found: i != none, index: i)
    },
  )
}

#let doubly-linked-list(style: (:), pointer: false, addresses: none, head: false, ..vals) = {
  _doubly-obj(vals.pos(), style, pointer, addresses, head)
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

#let _stack-obj(vs, style, top-label) = {
  let th = resolve((box-gap: 0) + style)
  (
    diagram: _stack-render(vs, th, (:), top-label),
    push: (v, step-label: none) => _step(
      if step-label == none { [push #v] } else { step-label },
      _stack-render(vs, th, (:), top-label),
      _stack-render((v,) + vs, th, ("0": "new"), top-label),
      _stack-obj((v,) + vs, style, top-label),
      style: style,
    ),
    pop: (step-label: none) => _step(
      if step-label == none { [pop] } else { step-label },
      _stack-render(vs, th, ("0": "remove"), top-label),
      _stack-render(vs.slice(1), th, (:), top-label),
      _stack-obj(vs.slice(1), style, top-label),
      style: style,
    ),
  )
}

#let stack(style: (:), top-label: [top], ..vals) = _stack-obj(vals.pos(), style, top-label)

// ── Queue ────────────────────────────────────────────────────────────────────

// Cells are contiguous (array view). The `enqueue`/`dequeue` builder arguments
// draw an external element entering at the rear or leaving the front in a
// single frame; the object's operations render a before → after step instead.
#let _queue-render(vs, th, marks, enq, deq, front-label, rear-label) = {
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
      _ann((ex + bw / 2, -0.42), [Enqueue], th)
    }
    if deq != none {
      // Front element leaving to the left with a horizontal arrow.
      let dx = -0.95 - bw
      _cell(dx, 0, deq, th, fill: op-fill)
      line((0, mid), (dx + bw, mid), mark: (end: ">"), stroke: th.box-stroke)
      _ann((dx + bw / 2, -0.42), [Dequeue], th)
    }
  }))
}

#let _queue-obj(vs, style, enq, deq, front-label, rear-label) = {
  let th = resolve(style)
  let draw(vals, marks) = _queue-render(vals, th, marks, none, none, front-label, rear-label)
  (
    diagram: _queue-render(vs, th, (:), enq, deq, front-label, rear-label),
    enqueue: (v, step-label: none) => _step(
      if step-label == none { [enqueue #v] } else { step-label },
      draw(vs, (:)),
      draw(vs + (v,), (str(vs.len()): "new")),
      _queue-obj(vs + (v,), style, enq, deq, front-label, rear-label),
      style: style,
    ),
    dequeue: (step-label: none) => _step(
      if step-label == none { [dequeue] } else { step-label },
      draw(vs, ("0": "remove")),
      draw(vs.slice(1), (:)),
      _queue-obj(vs.slice(1), style, enq, deq, front-label, rear-label),
      style: style,
    ),
  )
}

#let queue(
  style: (:),
  enqueue: none,
  dequeue: none,
  front-label: [Front],
  rear-label: [Rear],
  ..vals,
) = _queue-obj(vals.pos(), style, enqueue, dequeue, front-label, rear-label)

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
#let _skip-list-level-filters(nodes) = {
  let top = calc.max(0, ..nodes.map(n => n.level))
  range(top + 1).map(level => nodes.map(n => n.level >= level))
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
  while level < max-level and decision-fn(level + 1, value) {
    level += 1
  }
  level
}

// Returns the list of `(level, column-index, "path")` marks tracing the
// search path down to `key`.
#let _skip-list-search-marks(vs, level-filters, key) = {
  assert(key in vs, message: "search key is not part of skip list")
  let key-index = vs.position(k => k == key)

  let marks = ()

  let current-column = 0
  for (current-level, level-filter) in level-filters.enumerate().rev() {
    let next-entry-indices = level-filter.enumerate().filter(l => l.at(0) >= current-column and l.at(1)).map(l => l.at(0))
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
#let _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level) = {
  let th = resolve(style)
  let draw(ns, marks) = _simple-skip-list(ns.map(n => n.value), marks, th, _skip-list-level-filters(ns), level-spacing)

  (
    diagram: draw(nodes, ()),
    search: (key, step-label: none) => _step(
      if step-label == none { [search #key] } else { step-label },
      draw(nodes, ()),
      draw(nodes, _skip-list-search-marks(nodes.map(n => n.value), _skip-list-level-filters(nodes), key)),
      _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level),
      style: style,
    ),
    // `level: auto` assigns the new value's height with `decision-fn`;
    // pass an explicit level to force a specific tower height instead.
    insert: (value, level: auto, step-label: none) => {
      let assigned = if level == auto { _skip-list-node-level(value, decision-fn, max-level) } else { level }
      let i = 0
      while i < nodes.len() and nodes.at(i).value < value { i += 1 }
      let new-nodes = nodes.slice(0, i) + ((value: value, level: assigned),) + nodes.slice(i)
      let marks = range(assigned + 1).map(l => (l, i, "new"))
      _step(
        if step-label == none { [insert #value] } else { step-label },
        draw(nodes, ()),
        draw(new-nodes, marks),
        _skip-list-obj(new-nodes, style, decision-fn, level-spacing, max-level),
        style: style,
      )
    },
    delete: (value, step-label: none) => {
      let i = nodes.position(n => n.value == value)
      assert(i != none, message: "delete key is not part of skip list")
      let marks = range(nodes.at(i).level + 1).map(l => (l, i, "remove"))
      let rest = nodes.slice(0, i) + nodes.slice(i + 1)
      _step(
        if step-label == none { [delete #value] } else { step-label },
        draw(nodes, marks),
        draw(rest, ()),
        _skip-list-obj(rest, style, decision-fn, level-spacing, max-level),
        style: style,
      )
    },
  )
}

#let skip-list(style: (:), decision-fn: default-decision-fn, level-spacing: 1.4, max-level: 4, ..vals) = {
  let nodes = vals.pos().map(v => (value: v, level: _skip-list-node-level(v, decision-fn, max-level)))
  _skip-list-obj(nodes, style, decision-fn, level-spacing, max-level)
}
