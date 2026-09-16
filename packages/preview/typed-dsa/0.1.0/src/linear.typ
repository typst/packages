// Linear structures: linked lists, stacks, and queues.
//
// These are laid out by counting cells, so no layout pass is needed: a linked
// list and queue are a row of boxes, a stack is a column. Each builder takes a
// `style:` dict merged over the defaults and returns an object that is both
// the drawing (`diagram`) and the thing you operate on: operation fields
// return a step `(label, before, after, diagram, result)`, like the trees.
// `marks` maps `str(index)` to a highlight kind ("new"/"remove"), resolved
// against `th`'s `<kind>-style` via `mark-style` at draw time — so a per-call
// `style:` override actually reaches the mark, not just the theme default.

#import "@preview/cetz:0.5.2"
#import "style.typ": resolve, scaled, mark-style
#import "tree.typ": trans-view
#import cetz.draw: line, rect, content

#let _ann(pos, body, th) = {
  content(pos, text(..th.label-text)[#body])
}

#let _node-content(pos, body, th) = {
  let text-style = th.node-text
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(pos, text(..text-style)[#body], angle: rotation)
}

// A cell with its lower-left corner at `(x, y)`. `w` and `fill` default to
// the theme's box width and fill; `mark`, when set, overrides fill/stroke via
// `mark-style` and takes priority over a plain `fill:`.
#let _cell(x, y, body, th, fill: auto, mark: none, w: auto) = {
  let ww = if w == auto { th.box-w } else { w }
  let base-fill = if fill == auto { th.box-fill } else { fill }
  let m = if mark != none { mark-style(th, mark, base-fill: base-fill) } else { none }
  let f = if m != none { m.fill } else { base-fill }
  let s = if m != none { m.stroke } else { th.box-stroke }
  let text-style = if m != none { m.text } else { th.node-text }
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  rect((x, y), (x + ww, y + th.box-h), stroke: s, fill: f)
  content((x + ww / 2, y + th.box-h / 2), text(..text-style)[#body], angle: rotation)
}

#let _mark(marks, i) = marks.at(str(i), default: none)

#let _head-arrow(th, x-right) = {
  let mid = th.box-h / 2
  _ann((-th.box-gap - 1.0, mid), [Head], th)
  line((-th.box-gap - 0.55, mid), (x-right, mid), mark: (end: ">"), stroke: th.box-stroke)
}

// Assemble an operation step from the rendered states and the next object.
#let _step(label, before, after, result) = (
  label: label,
  before: before,
  after: after,
  diagram: trans-view(before, label, after),
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
    _node-content((vs.len() * step + th.box-w / 2, th.box-h / 2), $nothing$, th)
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

// `insert` appends at the tail; `delete` removes the first matching value.
#let _linked-obj(vs, style, pointer, addresses, head) = {
  let th = resolve(style)
  let draw(vals, marks) = _linked-render(vals, th, pointer, addresses, head, marks)
  (
    diagram: draw(vs, (:)),
    insert: (v, step-label: none) => _step(
      if step-label == none { [insert #v] } else { step-label },
      draw(vs, (:)),
      draw(vs + (v,), (str(vs.len()): "new")),
      _linked-obj(vs + (v,), style, pointer, addresses, head),
    ),
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      _step(if step-label == none { [delete #v] } else { step-label }, draw(vs, mb), draw(rest, (:)),
        _linked-obj(rest, style, pointer, addresses, head))
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
      _node-content((x + step + th.box-w / 2, th.box-h / 2), $nothing$, th)
      if head { _head-arrow(th, -0.05) }
    } else {
      _node-content((th.box-w / 2, th.box-h / 2), $nothing$, th)
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
    insert: (v, step-label: none) => _step(
      if step-label == none { [insert #v] } else { step-label },
      draw(vs, (:)),
      draw(vs + (v,), (str(vs.len()): "new")),
      _doubly-obj(vs + (v,), style, pointer, addresses, head),
    ),
    delete: (v, step-label: none) => {
      let i = vs.position(x => x == v)
      let rest = if i == none { vs } else { vs.slice(0, i) + vs.slice(i + 1) }
      let mb = if i == none { (:) } else { (str(i): "remove") }
      _step(if step-label == none { [delete #v] } else { step-label }, draw(vs, mb), draw(rest, (:)),
        _doubly-obj(rest, style, pointer, addresses, head))
    },
  )
}

#let doubly-linked-list(style: (:), pointer: false, addresses: none, head: false, ..vals) = {
  _doubly-obj(vals.pos(), style, pointer, addresses, head)
}

// ── Stack ────────────────────────────────────────────────────────────────────

// First value is the top of the stack.
#let _stack-render(vs, th, marks) = {
  let step = th.box-h + th.box-gap * 0.35
  let label-gap = if th.box-gap > 0.45 { th.box-gap } else { 0.45 }
  scaled(th, cetz.canvas({
    for (i, v) in vs.enumerate() { _cell(0, -i * step, v, th, mark: _mark(marks, i)) }
    if vs.len() > 0 { _ann((th.box-w + label-gap, th.box-h / 2), [top], th) }
  }))
}

#let _stack-obj(vs, style) = {
  let th = resolve(style)
  (
    diagram: _stack-render(vs, th, (:)),
    push: (v, step-label: none) => _step(
      if step-label == none { [push #v] } else { step-label },
      _stack-render(vs, th, (:)),
      _stack-render((v,) + vs, th, ("0": "new")),
      _stack-obj((v,) + vs, style),
    ),
    pop: (step-label: none) => _step(
      if step-label == none { [pop] } else { step-label },
      _stack-render(vs, th, ("0": "remove")),
      _stack-render(vs.slice(1), th, (:)),
      _stack-obj(vs.slice(1), style),
    ),
  )
}

#let stack(style: (:), ..vals) = _stack-obj(vals.pos(), style)

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
    if n > 0 {
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
    ),
    dequeue: (step-label: none) => _step(
      if step-label == none { [dequeue] } else { step-label },
      draw(vs, ("0": "remove")),
      draw(vs.slice(1), (:)),
      _queue-obj(vs.slice(1), style, enq, deq, front-label, rear-label),
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
