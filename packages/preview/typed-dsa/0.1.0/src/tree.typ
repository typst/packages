// Binary search trees, AVL trees, hand-composed trees, and operation transitions.
//
// A node is a plain dict. Generated trees (`bst`, `avl`) hold `(key, left,
// right, height)`; hand-composed trees use `node(label, left:, right:)` and
// `subtree(label)` leaves drawn as triangles. Layout assigns the in-order
// column index to x and depth to y — the standard textbook BST drawing, which
// never overlaps, so no contour-merging layout pass is needed. Positions are
// written onto the nodes, so labels can be any content.

#import "@preview/cetz:0.5.2"
#import "style.typ": theme, resolve, scaled, mark-style, edge-mark, edge-stroke, edge-wave, wavy-parts
#import cetz.draw: line, circle, rect, content, bezier-through

// ── Model: generated BST/AVL ─────────────────────────────────────────────────

#let _node(key) = (kind: "node", key: key, left: none, right: none, height: 1)

#let _h(n) = if n == none { 0 } else { n.height }
#let _bf(n) = _h(n.left) - _h(n.right)
#let _fix-height(n) = {
  n.height = calc.max(_h(n.left), _h(n.right)) + 1
  n
}

#let _rot-left(x) = {
  let y = x.right
  x.right = y.left
  y.left = _fix-height(x)
  _fix-height(y)
}

#let _rot-right(y) = {
  let x = y.left
  y.left = x.right
  x.right = _fix-height(y)
  _fix-height(x)
}

// Plain BST insert. Duplicate keys are ignored.
#let _bst-insert(n, key) = {
  if n == none { return _node(key) }
  if key < n.key { n.left = _bst-insert(n.left, key) }
  else if key > n.key { n.right = _bst-insert(n.right, key) }
  n
}

#let _node-key(n) = if n == none { none } else { n.key }

// One rotation's worth of schematic parts. For a right rotation, `pivot` is
// x, `new-top` is y, and `subs` are T_A, T_B, T_C from left to right. For a
// left rotation, `pivot` is y, `new-top` is x, and `subs` are T_A, T_B, T_C
// from left to right in the mirror schematic.
#let _rot-event(dir, pivot, new-top, ta, tb, tc) = (
  dir: dir,
  pivot: pivot.key,
  new-top: new-top.key,
  subs: (_node-key(ta), _node-key(tb), _node-key(tc)).filter(k => k != none),
)

// AVL insert. Returns `(node, rot, mid)`:
// - `rot`: the rotation event(s) performed — one for a single (LL/RR)
//   rotation, two (inner then outer) for a double (LR/RL) rotation — so a
//   transition can highlight every node that changed parent, not just the
//   pivot.
// - `mid`: for a double rotation only, the tree with just the inner rotation
//   applied, before the outer one — lets a transition show that step on its
//   own. `none` otherwise; a single insert only ever rotates once, so no
//   ancestor above the rotation point needs to carry a `mid` of its own.
#let _avl-insert(n, key) = {
  if n == none { return (_node(key), (), none) }
  let rot = ()
  let mid = none
  if key < n.key {
    let (c, r, m) = _avl-insert(n.left, key)
    if m != none {
      let n2 = n
      n2.left = m
      mid = n2
    }
    n.left = c
    rot += r
  } else if key > n.key {
    let (c, r, m) = _avl-insert(n.right, key)
    if m != none {
      let n2 = n
      n2.right = m
      mid = n2
    }
    n.right = c
    rot += r
  } else {
    return (n, (), none)
  }
  n = _fix-height(n)
  let b = _bf(n)
  if b > 1 and key < n.left.key {
    let event = _rot-event("right", n, n.left, n.left.left, n.left.right, n.right)
    return (_rot-right(n), rot + (event,), mid)
  }
  if b < -1 and key > n.right.key {
    let event = _rot-event("left", n, n.right, n.left, n.right.left, n.right.right)
    return (_rot-left(n), rot + (event,), mid)
  }
  if b > 1 and key > n.left.key {
    // LR: inner left-rotation at n.left, then outer right-rotation at n. `n`
    // with only the inner rotation applied (n.left updated, n itself not yet
    // rotated) is exactly the "after-inner" snapshot.
    let inner = _rot-event("left", n.left, n.left.right, n.left.left, n.left.right.left, n.left.right.right)
    n.left = _rot-left(n.left)
    mid = n
    let outer = _rot-event("right", n, n.left, n.left.left, n.left.right, n.right)
    return (_rot-right(n), rot + (inner, outer), mid)
  }
  if b < -1 and key < n.right.key {
    let inner = _rot-event("right", n.right, n.right.left, n.right.left.left, n.right.left.right, n.right.right)
    n.right = _rot-right(n.right)
    mid = n
    let outer = _rot-event("left", n, n.right, n.left, n.right.left, n.right.right)
    return (_rot-left(n), rot + (inner, outer), mid)
  }
  (n, rot, mid)
}

#let _bst-min(n) = {
  while n.left != none { n = n.left }
  n.key
}

// Standard BST delete using the in-order successor for two-child nodes.
#let _bst-delete(n, key) = {
  if n == none { return none }
  if key < n.key { n.left = _bst-delete(n.left, key) }
  else if key > n.key { n.right = _bst-delete(n.right, key) }
  else {
    if n.left == none { return n.right }
    if n.right == none { return n.left }
    let succ = _bst-min(n.right)
    n.key = succ
    n.right = _bst-delete(n.right, succ)
  }
  n
}

#let _avl-rebalance(n, rot) = {
  n = _fix-height(n)
  let b = _bf(n)
  if b > 1 {
    if _bf(n.left) < 0 {
      let inner = _rot-event("left", n.left, n.left.right, n.left.left, n.left.right.left, n.left.right.right)
      n.left = _rot-left(n.left)
      let outer = _rot-event("right", n, n.left, n.left.left, n.left.right, n.right)
      return (_rot-right(n), rot + (inner, outer))
    }
    let event = _rot-event("right", n, n.left, n.left.left, n.left.right, n.right)
    return (_rot-right(n), rot + (event,))
  }
  if b < -1 {
    if _bf(n.right) > 0 {
      let inner = _rot-event("right", n.right, n.right.left, n.right.left.left, n.right.left.right, n.right.right)
      n.right = _rot-right(n.right)
      let outer = _rot-event("left", n, n.right, n.left, n.right.left, n.right.right)
      return (_rot-left(n), rot + (inner, outer))
    }
    let event = _rot-event("left", n, n.right, n.left, n.right.left, n.right.right)
    return (_rot-left(n), rot + (event,))
  }
  (n, rot)
}

#let _avl-delete(n, key) = {
  if n == none { return (none, ()) }
  let rot = ()
  if key < n.key {
    let (c, r) = _avl-delete(n.left, key)
    n.left = c
    rot += r
  } else if key > n.key {
    let (c, r) = _avl-delete(n.right, key)
    n.right = c
    rot += r
  } else {
    if n.left == none { return (n.right, ()) }
    if n.right == none { return (n.left, ()) }
    let succ = _bst-min(n.right)
    n.key = succ
    let (c, r) = _avl-delete(n.right, succ)
    n.right = c
    rot += r
  }
  _avl-rebalance(n, rot)
}

// Keys visited from the root while searching for `key`, in order.
#let _search-path(n, key) = {
  if n == none { return () }
  if key == n.key { return (n.key,) }
  if key < n.key { return (n.key,) + _search-path(n.left, key) }
  (n.key,) + _search-path(n.right, key)
}

#let _build(variant, keys) = {
  let root = none
  for k in keys {
    if variant == "avl" {
      let (r, _, _) = _avl-insert(root, k)
      root = r
    } else {
      root = _bst-insert(root, k)
    }
  }
  root
}

// ── Model: hand-composed trees ────────────────────────────────────────────────

// A node with an arbitrary content `label`, optional children, and an optional fill tint.
#let node(label, left: none, right: none, children: none, fill: none) = (
  kind: "node", label: label, left: left, right: right,
  children: children,
  fill: fill,
  height: 1,
)

// A triangle leaf standing in for an elided subtree. `height` is an optional
// content label drawn as a side bracket; `scale` resizes the triangle; `fill`
// tints the outline and labels.
#let subtree(label, fill: none, height: none, scale: 1) = (
  kind: "subtree", label: label,
  fill: fill,
  h-label: height, tscale: scale,
)

// ── Layout ───────────────────────────────────────────────────────────────────

// Writes `_col` and `_depth` onto each node; returns `(node, next-col)`.
// Leaves consume a column left to right; a node is centered over its children so
// the two child edges stay symmetric regardless of how lopsided the subtrees
// are. A missing child still reserves a phantom column, so a lone child keeps its
// left/right slant and siblings can never overlap. Subtree triangles claim two
// columns so neighbours stay clear.
//
// ponytail: leaf-sequential centering, not a full Reingold–Tilford contour
// layout. Distinct subtrees are guaranteed >= 1 column apart, which is enough
// for the trees this package draws; revisit if very wide siblings need tighter
// packing.
#let _place(n, depth, col) = {
  if n == none { return (none, col) }
  n._depth = depth
  if n.kind == "subtree" {
    n._col = col
    return (n, col + 2)
  }
  let cs = n.at("children", default: none)
  if cs != none {
    if cs.len() == 0 {
      n._col = col
      return (n, col + 1)
    }
    let placed = ()
    let c = col
    for child in cs {
      let (p, next) = _place(child, depth + 1, c)
      placed.push(p)
      c = next
    }
    n.children = placed
    n._col = (placed.first()._col + placed.last()._col) / 2
    return (n, c)
  }
  let has-l = n.left != none
  let has-r = n.right != none
  if not has-l and not has-r {
    n._col = col
    return (n, col + 1)
  }
  if has-l and has-r {
    let (l, c1) = _place(n.left, depth + 1, col)
    n.left = l
    let (r, c2) = _place(n.right, depth + 1, c1)
    n.right = r
    n._col = (l._col + r._col) / 2
    (n, c2)
  } else if has-l {
    // Phantom right child occupies the next column.
    let (l, c1) = _place(n.left, depth + 1, col)
    n.left = l
    n._col = (l._col + c1) / 2
    (n, c1 + 1)
  } else {
    // Phantom left child occupies this column; the real right child follows.
    let (r, c2) = _place(n.right, depth + 1, col + 1)
    n.right = r
    n._col = (col + r._col) / 2
    (n, c2)
  }
}

// ── Render ───────────────────────────────────────────────────────────────────

#let _xy(n, th) = (n._col * th.x-gap, -n._depth * th.y-gap)

#let _edge-id(n) = n.at("key", default: n.at("label", default: none))

#let _explicit-children(n) = n.at("children", default: none)

#let _multi-children(n) = {
  let cs = _explicit-children(n)
  if cs == none { return none }
  cs
}

#let _visible-children(n) = {
  let cs = _multi-children(n)
  if cs != none { return cs.filter(c => c != none) }
  (n.left, n.right).filter(c => c != none)
}

#let _edge-custom(customizations, from, to) = {
  for (a, b, opts) in customizations {
    if a == from and b == to { return opts }
  }
  none
}

#let _node-custom(customizations, id) = {
  for (key, opts) in customizations {
    if key == id { return opts }
  }
  none
}

#let _text-style(style) = {
  let res = style
  if "color" in res {
    res.fill = res.color
    let _ = res.remove("color")
  }
  res
}

#let _lookup-key(items, id) = {
  if type(items) == dictionary {
    if type(id) == str or type(id) == int or type(id) == float {
      return items.at(str(id), default: none)
    }
    return none
  }
  for (key, value) in items {
    if key == id { return value }
  }
  none
}

#let _shape-radius(th, mark: none, custom: none) = {
  if custom != none and "node-radius" in custom { return custom.node-radius }
  if mark != none { return mark.node-radius }
  th.node-radius
}

#let _shape-name(th, mark: none, custom: none) = {
  if custom != none and "shape" in custom { return custom.shape }
  if mark != none { return mark.shape }
  th.node-shape
}

#let _boundary-radius(shape, r, ux, uy) = {
  if shape == "square" {
    return r / calc.max(calc.abs(ux), calc.abs(uy))
  }
  if shape == "diamond" {
    return r / (calc.abs(ux) + calc.abs(uy))
  }
  r
}

#let _trim-shape(a, b, shape, r) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return a }
  let ux = dx / len
  let uy = dy / len
  let d = _boundary-radius(shape, r, ux, uy)
  (a.at(0) + ux * d, a.at(1) + uy * d)
}

#let _draw-tree-edge(p, q, r1, r2, th, custom) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let mark = edge-mark(if custom != none and "arrow" in custom { custom.arrow } else { th.edge-arrow })
  let stroke = edge-stroke(th, custom: custom)
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  if bend != false and bend != none {
    let bp = _bend-point(p, q, bend, custom.at("angle", default: 25deg))
    let a = _trim-shape(p, bp, r1.at(0), r1.at(1))
    let b = _trim-shape(q, bp, r2.at(0), r2.at(1))
    bezier-through(a, bp, b, stroke: stroke, mark: mark)
  } else {
    let ux = dx / len
    let uy = dy / len
    let a = _trim-shape(p, q, r1.at(0), r1.at(1))
    let b = _trim-shape(q, p, r2.at(0), r2.at(1))
    if edge-wave(th, custom: custom) {
    let start-tip = mark != none and "start" in mark
    let end-tip = mark != none and "end" in mark
    let parts = wavy-parts(a, b, th, start-tip: start-tip, end-tip: end-tip)
    line(..parts.points, stroke: stroke)
    let fill = if mark == none { none } else { mark.at("fill", default: none) }
    if start-tip { line(a, parts.start-cap, stroke: stroke, mark: (start: ">", fill: fill)) }
    if end-tip { line(parts.end-cap, b, stroke: stroke, mark: (end: ">", fill: fill)) }
    } else {
      line(a, b, stroke: stroke, mark: mark)
    }
  }
}

#let _bend-point(p, q, bend, angle) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  let mx = (p.at(0) + q.at(0)) / 2
  let my = (p.at(1) + q.at(1)) / 2
  if len == 0 { return (mx, my) }
  let ux = dx / len
  let uy = dy / len
  let (px, py) = if bend == "left" { (-uy, ux) } else { (uy, -ux) }
  let sagitta = (len / 2) * calc.tan(angle)
  (mx + px * sagitta, my + py * sagitta)
}

#let _trim-toward(a, b, r) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return a }
  (a.at(0) + dx / len * r, a.at(1) + dy / len * r)
}

#let _tree-label-style(th, custom) = {
  let style = th.label-text
  let body = none
  if custom != none and "label" in custom {
    let lbl = custom.label
    if type(lbl) == dictionary {
      body = lbl.at("content", default: lbl.at("body", default: none))
      let d = lbl
      let _ = d.remove("content", default: none)
      let _ = d.remove("body", default: none)
      if "color" in d {
        d.fill = d.color
        let _ = d.remove("color")
      }
      style = style + d
    } else {
      body = lbl
    }
  }
  (body: body, style: style)
}

#let _label-vector(pos) = {
  if pos == "right" { return (1, 0) }
  if pos == "left" { return (-1, 0) }
  if pos == "top" { return (0, 1) }
  if pos == "bottom" { return (0, -1) }
  if type(pos) == angle { return (calc.cos(pos), calc.sin(pos)) }
  (1, 0)
}

#let _resolve-node-label(th, node-labels, id) = {
  let raw = _lookup-key(node-labels, id)
  if raw == none { return none }
  let body = raw
  let style = th.label-text
  let defaults = th.at("node-labels", default: (:))
  let position = defaults.at("position", default: "right")
  let offset = defaults.at("offset", default: (0, 0))
  let gap = defaults.at("gap", default: 0.22)
  let d0 = defaults
  for key in ("position", "offset", "gap", "enabled") {
    if key in d0 { let _ = d0.remove(key) }
  }
  if "color" in d0 {
    d0.fill = d0.color
    let _ = d0.remove("color")
  }
  style = style + d0
  if type(raw) == dictionary {
    body = raw.at("content", default: raw.at("body", default: none))
    let d = raw
    let _ = d.remove("content", default: none)
    let _ = d.remove("body", default: none)
    if "position" in d {
      position = d.position
      let _ = d.remove("position")
    }
    if "offset" in d {
      offset = d.offset
      let _ = d.remove("offset")
    }
    if "gap" in d {
      gap = d.gap
      let _ = d.remove("gap")
    }
    if "color" in d {
      d.fill = d.color
      let _ = d.remove("color")
    }
    style = style + d
  }
  if body == none { return none }
  (body: body, style: style, position: position, offset: offset, gap: gap)
}

#let _draw-node-label(p, boundary, th, label) = {
  if label == none { return }
  let dir = _label-vector(label.position)
  let ox = label.offset.at(0)
  let oy = label.offset.at(1)
  let gap = label.gap
  let r = _boundary-radius(boundary.at(0), boundary.at(1), dir.at(0), dir.at(1))
  let pt = (p.at(0) + dir.at(0) * (r + gap) + ox, p.at(1) + dir.at(1) * (r + gap) + oy)
  let text-style = label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(pt, text(..text-style, label.body), angle: rotation)
}

#let _draw-tree-edge-label(p, q, r1, r2, th, custom) = {
  let lbl = _tree-label-style(th, custom)
  if lbl.body == none { return }
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let ux = dx / len
  let uy = dy / len
  let a = _trim-shape(p, q, r1.at(0), r1.at(1))
  let b = _trim-shape(q, p, r2.at(0), r2.at(1))
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  let base = if bend == false or bend == none {
    ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  } else {
    _bend-point(p, q, bend, if custom != none { custom.at("angle", default: 25deg) } else { 25deg })
  }
  let (ox, oy) = if bend == "right" {
    (uy, -ux)
  } else if bend == "left" {
    (-uy, ux)
  } else if dx < 0 {
    (uy, -ux)
  } else {
    (-uy, ux)
  }
  let shift = 0.16
  let text-style = lbl.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  if rotation == "edge" {
    rotation = calc.atan2(dx, dy)
    if dx < 0 { rotation += 180deg }
  }
  content((base.at(0) + ox * shift, base.at(1) + oy * shift), text(..text-style, lbl.body), angle: rotation)
}

#let _draw-edges(n, th, edge-customizations, node-customizations) = {
  if n == none or n.kind == "subtree" { return }
  let p = _xy(n, th)
  for c in _visible-children(n) {
    if c != none {
      // Stop the edge at each node's boundary so arrowheads stay visible
      // instead of hiding under the node. Subtree leaves connect at the apex.
      let q = _xy(c, th)
      let p-custom = _node-custom(node-customizations, _edge-id(n))
      let c-custom = _node-custom(node-customizations, _edge-id(c))
      let rp = (_shape-name(th, custom: p-custom), _shape-radius(th, custom: p-custom))
      let rc = if c.kind == "subtree" { ("circle", 0) } else { (_shape-name(th, custom: c-custom), _shape-radius(th, custom: c-custom)) }
      let custom = _edge-custom(edge-customizations, _edge-id(n), _edge-id(c))
      _draw-tree-edge(p, q, rp, rc, th, custom)
      _draw-tree-edge-label(p, q, rp, rc, th, custom)
      _draw-edges(c, th, edge-customizations, node-customizations)
    }
  }
}

// `mark` is `none` (use `th`'s node defaults and `fill`) or a resolved dict
// from `mark-style`, overriding the shape/stroke/radius/text of this node.
#let _draw-shape(p, label, th, fill, mark: none, custom: none) = {
  let shape = _shape-name(th, mark: mark, custom: custom)
  let r = _shape-radius(th, mark: mark, custom: custom)
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else if mark != none { mark.stroke } else { th.node-stroke }
  let f = if custom != none and "fill" in custom { custom.fill } else if mark != none { mark.fill } else { fill }
  let text-style = if mark != none { mark.text } else { th.node-text }
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let polygon = pts => line(..pts, close: true, fill: f, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: f, stroke: stroke)
  } else if shape == "diamond" {
    polygon(((p.at(0), p.at(1) + r), (p.at(0) + r, p.at(1)), (p.at(0), p.at(1) - r), (p.at(0) - r, p.at(1))))
  } else if shape == "hexagon" {
    let k = 0.86 * r
    polygon((
      (p.at(0) - r, p.at(1)),
      (p.at(0) - r / 2, p.at(1) + k),
      (p.at(0) + r / 2, p.at(1) + k),
      (p.at(0) + r, p.at(1)),
      (p.at(0) + r / 2, p.at(1) - k),
      (p.at(0) - r / 2, p.at(1) - k),
    ))
  } else {
    circle(p, radius: r, fill: f, stroke: stroke)
  }
  content(p, text(..text-style)[#label], angle: rotation)
}

#let _draw-triangle(n, th) = {
  let p = _xy(n, th)
  let s = n.tscale
  let hw = th.tri-w / 2 * s
  let hh = th.tri-h * s
  let tint = n.fill
  let stroke = if tint == none { th.node-stroke } else { 1pt + tint }
  let ink = if tint == none { black } else { tint }
  let text-style = th.node-text + (fill: ink)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  line(p, (p.at(0) - hw, p.at(1) - hh), (p.at(0) + hw, p.at(1) - hh), close: true, stroke: stroke)
  content((p.at(0), p.at(1) - hh * 0.62), text(..text-style, n.label), angle: rotation)
  if n.h-label != none {
    let bx = p.at(0) - hw - 0.32
    line((bx, p.at(1)), (bx, p.at(1) - hh), stroke: stroke, mark: (start: ">", end: ">"))
    content((bx - 0.3, p.at(1) - hh / 2), text(..text-style, n.h-label), angle: rotation)
  }
}

#let _draw-nodes(n, th, marks, node-customizations, node-labels) = {
  if n == none { return }
  if n.kind == "subtree" {
    _draw-triangle(n, th)
    return
  }
  for c in _visible-children(n) { _draw-nodes(c, th, marks, node-customizations, node-labels) }
  let key = n.at("key", default: none)
  let tint = n.at("fill", default: none)
  let label = n.at("label", default: none)
  if label == none { label = str(key) }
  let id = _edge-id(n)
  let custom = _node-custom(node-customizations, id)
  // A hand-composed node(fill:) tint takes priority over an operation
  // highlight; generated bst/avl nodes never set `.fill`, so the two never
  // actually collide.
  if tint != none {
    _draw-shape(_xy(n, th), label, th, tint, custom: custom)
  } else {
    let kind = if key == none { none } else { marks.at(str(key), default: none) }
    let mark = if kind != none { mark-style(th, kind, base-fill: th.node-fill) } else { none }
    _draw-shape(_xy(n, th), label, th, th.node-fill, mark: mark, custom: custom)
  }
  let boundary = (_shape-name(th, custom: custom), _shape-radius(th, custom: custom))
  _draw-node-label(_xy(n, th), boundary, th, _resolve-node-label(th, node-labels, id))
}

// `marks` maps `str(key)` to a highlight kind ("new"/"path"/"remove"/"rotate"),
// resolved against `th`'s `<kind>-style` via `mark-style` at draw time — so a
// per-call `style:` override actually reaches the mark, not just the theme
// default.
#let _render(root, marks: (:), th: theme, edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  if root == none { return scaled(th, cetz.canvas({ circle((0, 0), radius: 0.01, stroke: none) })) }
  let (placed, _) = _place(root, 0, 0)
  scaled(th, cetz.canvas({
    _draw-edges(placed, th, edge-customizations, node-customizations)
    _draw-nodes(placed, th, marks, node-customizations, node-labels)
  }))
}

// ── Public structure builders ────────────────────────────────────────────────

// Render a hand-composed tree built from `node(...)` and `subtree(...)`.
#let tree(root, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = _render(root, th: resolve(style), edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)

// ── Operations ───────────────────────────────────────────────────────────────
//
// An operation is a closure `(variant, root) -> (after, mark-before,
// mark-after, label, mids)`. `transition` builds the before-tree, applies the
// operation, and renders before → arrow → ... → after with the marks it
// returns. `mids` is an array (possibly empty) of `(tree:, marks:, label:)`
// panels between before and after (see `insert`'s `rebalance`); `label` is
// the label for the arrow leading *out of* the previous panel *into* this
// one.

// `kind` is a highlight kind string ("new"/"path"/"remove"/"rotate"),
// resolved against the caller's `style:` at draw time by `mark-style` —
// keeping the kind here instead of a resolved color is what lets a per-call
// style override actually reach the mark.
#let _marks(keys, kind) = {
  let m = (:)
  for k in keys { m.insert(str(k), kind) }
  m
}

// Every visible schematic part in a rotation: the pivot, the child promoted
// above it, and the roots of T_A/T_B/T_C when those subtrees exist.
#let _event-keys(event) = {
  let keys = (event.pivot, event.new-top)
  keys += event.subs
  keys
}
#let _rotated-keys(rot) = {
  let keys = ()
  for e in rot { keys += _event-keys(e) }
  keys
}

#let _rot-label(event) = "rotate " + event.dir + " at " + str(event.pivot)

// `rebalance: (enabled: false, all-steps: false)` — `enabled: true` adds a
// panel for the tree right after the plain BST placement, before any
// rotation straightens it out, when the AVL fixup actually rotates. A BST
// insert, or an AVL insert that never unbalances the tree, ignores it and
// stays 2-panel. `all-steps: true` additionally splits a *double* rotation
// (left-right / right-left) into its own inner-then-outer steps instead of
// collapsing straight from the unrotated tree to the final one; it has no
// effect on a single rotation, since there's only one step to show either way.
//
// ponytail: `enabled`, not `show` — `show` is a reserved word in Typst
// (show rules), so it can't be a bare dict key.
#let tree-insert(key, rebalance: (:), step-label: none) = (variant, root) => {
  let default-label = "insert " + str(key)
  let final-step-label = if step-label == none { default-label } else { step-label }
  if variant == "avl" {
    let cfg = (enabled: false, all-steps: false) + rebalance
    let (after, rot, mid-snapshot) = _avl-insert(root, key)
    let mids = ()
    if cfg.enabled and rot.len() > 0 {
      let broken = _bst-insert(root, key)
      let new-mark = _marks((key,), "new")
      mids.push((tree: broken, marks: new-mark, label: default-label))
      if cfg.all-steps and rot.len() == 2 and mid-snapshot != none {
        let inner-mark = new-mark + _marks(_event-keys(rot.at(0)), "rotate")
        mids.push((tree: mid-snapshot, marks: inner-mark, label: _rot-label(rot.at(0))))
      }
    }
    let ma = if cfg.enabled and cfg.all-steps and rot.len() == 2 and mid-snapshot != none {
      _marks(_event-keys(rot.at(1)), "rotate")
    } else {
      _marks((key,), "new") + _marks(_rotated-keys(rot), "rotate")
    }
    let final-label = if mids.len() == 2 {
      _rot-label(rot.at(1))
    } else {
      rot.map(_rot-label).join(", ")
    }
    (after, (:), ma, if step-label != none { step-label } else if rot.len() > 0 { final-label } else { default-label }, mids)
  } else {
    let mb = _marks(_search-path(root, key), "path")
    (_bst-insert(root, key), mb, _marks((key,), "new"), final-step-label, ())
  }
}

#let tree-delete(key, step-label: none) = (variant, root) => {
  let label = if step-label == none { "delete " + str(key) } else { step-label }
  let mb = _marks(_search-path(root, key), "path") + _marks((key,), "remove")
  if variant == "avl" {
    let (after, rot) = _avl-delete(root, key)
    return (after, mb, _marks(_rotated-keys(rot), "rotate"), label, ())
  }
  (_bst-delete(root, key), mb, (:), label, ())
}

#let tree-search(key, step-label: none) = (variant, root) => {
  let m = _marks(_search-path(root, key), "path")
  (root, (:), m, if step-label == none { "search " + str(key) } else { step-label }, ())
}

// ── Composable operation views ───────────────────────────────────────────────

#let op-arrow(label, symbol: $arrow.r$) = align(horizon)[
  #set align(center)
  #if label != none [
    #text(size: 8pt, label) \
  ]
  #text(size: 1.3em, symbol)
]

// Before → arrow → after row shared by `transition` and operation steps.
#let trans-view(before, label, after) = stack(
  dir: ltr,
  spacing: 1.2em,
  align(horizon, before),
  op-arrow(label),
  align(horizon, after),
)

// Before → arrow → ... → after, for a step with zero or more extra panels in
// between (an AVL insert with `rebalance: (enabled: true)` that actually
// rotated). `mids` holds the in-between panels as already-rendered content;
// `labels` holds one more entry than `mids` — the arrow leading into each
// mid panel, then the arrow leading into `after`.
#let trans-view-n(before, mids, labels, after) = {
  let parts = (align(horizon, before),)
  for (i, m) in mids.enumerate() {
    parts.push(op-arrow(labels.at(i)))
    parts.push(align(horizon, m))
  }
  parts.push(op-arrow(labels.last()))
  parts.push(align(horizon, after))
  stack(dir: ltr, spacing: 1.2em, ..parts)
}

// Renders an operation's step diagram, expanding to extra panels when the op
// returns non-empty `mids`.
#let _op-diagram(before, mb, after, ma, label, mids, th, edge-customizations, node-customizations, node-labels) = {
  let b = _render(before, marks: mb, th: th, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
  let a = _render(after, marks: ma, th: th, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
  if mids.len() == 0 {
    (before: b, after: a, diagram: trans-view(b, label, a))
  } else {
    let rendered = mids.map(m => _render(m.tree, marks: m.marks, th: th, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels))
    let labels = mids.map(m => m.label) + (label,)
    (before: b, after: a, diagram: trans-view-n(b, rendered, labels, a))
  }
}

// A tree value is both the drawing and the object you operate on: `diagram`
// holds the rendering, and each operation field returns a step `(label,
// before, after, diagram, result)` where `result` is the tree after the
// operation. Typst calls functions stored in dictionaries as `(obj.field)(...)`,
// so examples use that shape instead of `obj.field(...)`.
//
// ponytail: dictionary-backed object, not a custom type. Switch if Typst gains
// user-defined types with method dispatch.
#let _tree-obj(variant, root, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  let apply = op => {
    let (after, mb, ma, label, mids) = op(variant, root)
    let v = _op-diagram(root, mb, after, ma, label, mids, resolve(style), edge-customizations, node-customizations, node-labels)
    (
      label: label,
      before: v.before,
      after: v.after,
      diagram: v.diagram,
      result: _tree-obj(variant, after, style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels),
    )
  }
  (
    diagram: _render(root, th: resolve(style), edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels),
    insert: (key, rebalance: (:), step-label: none) => apply(tree-insert(key, rebalance: rebalance, step-label: step-label)),
    delete: (key, step-label: none) => apply(tree-delete(key, step-label: step-label)),
    search: (key, step-label: none) => apply(tree-search(key, step-label: step-label)),
  )
}

#let bst(style: (:), edge-customizations: (), node-customizations: (), node-labels: (:), ..keys) = _tree-obj("bst", _build("bst", keys.pos()), style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)
#let avl(style: (:), edge-customizations: (), node-customizations: (), node-labels: (:), ..keys) = _tree-obj("avl", _build("avl", keys.pos()), style: style, edge-customizations: edge-customizations, node-customizations: node-customizations, node-labels: node-labels)

// ── Transition ───────────────────────────────────────────────────────────────

#let transition(variant, keys, op, style: (:), edge-customizations: (), node-customizations: (), node-labels: (:)) = {
  let before = _build(variant, keys)
  let (after, mb, ma, label, mids) = op(variant, before)
  _op-diagram(before, mb, after, ma, label, mids, resolve(style), edge-customizations, node-customizations, node-labels).diagram
}
