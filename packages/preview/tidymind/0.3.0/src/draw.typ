#import "@preview/cetz:0.5.2"
#import "style.typ": edge-width, node-body, node-paint, node-spec

// Branch color: a lookup of the `branch-index` the layout resolved (the
// position, or the nearest explicit `branch` up the tree). The root, which
// belongs to no branch, takes its own `branch` or the first palette color.
#let _branch-color(n, palette) = {
  let idx = if n.branch-index >= 0 { n.branch-index }
    else if n.at("branch", default: none) != none { n.branch - 1 } else { 0 }
  palette.at(calc.rem(idx, palette.len()))
}

#let _role-color(n, opts) = {
  let role = n.at("emphasis", default: none)
  if role == none { none } else { opts.emphasis-colors.at(role, default: none) }
}

#let _top(n) = n.y - n.h / 2

/// Where edges meet this node, in layout coordinates (y grows downwards).
#let anchor-y(n) = _top(n) + n.a

#let _side(n) = if n.at("side", default: 1) < 0 { -1 } else { 1 }

#let _spec(n, depth, opts) = node-spec(opts.style, depth, emphasized: n.emphasized, surfaced: n.surfaced)

/// Control points of the curved edge (the same ones 0.2.0 used).
#let edge-curve(a, b) = {
  let mid = (a.at(0) + b.at(0)) / 2
  (a, (mid, a.at(1)), (mid, b.at(1)), b)
}

/// Outline of a tapered edge: a filled ribbon along `edge-curve`, `w1` wide at
/// `a` and `w2` at `b` (points). Width eases from one to the other.
#let ribbon(a, b, w1, w2, steps: 24) = {
  let (p0, p1, p2, p3) = edge-curve(a, b)
  let at(t) = {
    let u = 1 - t
    let f(i) = u * u * u * p0.at(i) + 3 * u * u * t * p1.at(i) + 3 * u * t * t * p2.at(i) + t * t * t * p3.at(i)
    (f(0), f(1))
  }
  let tangent(t) = {
    let u = 1 - t
    let f(i) = 3 * u * u * (p1.at(i) - p0.at(i)) + 6 * u * t * (p2.at(i) - p1.at(i)) + 3 * t * t * (p3.at(i) - p2.at(i))
    (f(0), f(1))
  }
  let left = ()
  let right = ()
  for i in range(steps + 1) {
    let t = i / steps
    let q = at(t)
    let d = tangent(t)
    let len = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
    let len = if len == 0 { 1 } else { len }
    let nx = -d.at(1) / len
    let ny = d.at(0) / len
    let e = t * t * (3 - 2 * t)
    let hw = (w1 + (w2 - w1) * e) / 2
    left.push((q.at(0) + nx * hw, q.at(1) + ny * hw))
    right.push((q.at(0) - nx * hw, q.at(1) - ny * hw))
  }
  left + right.rev()
}

/// Edge color by the depth of the child it reaches: the branch's own color at
/// the first level, lighter below. Opaque on purpose: transparency would show
/// a seam where two edges overlap. "boxed" keeps one flat color.
#let edge-color(color, depth, style) = {
  if style == "boxed" or depth <= 1 { color } else if depth == 2 { color.lighten(38%) } else { color.lighten(55%) }
}

// Parent→child edges, from the parent's anchor to the child's. Recursive.
#let _draw-edges(n, palette, opts, depth) = {
  import cetz.draw: *
  for c in n.children {
    let s = _side(c)
    let a = (if s > 0 { n.x + n.w } else { n.x }, -anchor-y(n))
    let b = (if s > 0 { c.x } else { c.x + c.w }, -anchor-y(c))
    let col = edge-color(_branch-color(c, palette), depth + 1, opts.style)
    let child-spec = _spec(c, depth + 1, opts)
    // An edge that arrives at a rule arrives with the rule's thickness: that
    // is what makes the two read as one line.
    let w2 = if child-spec.rule != none { child-spec.rule } else { edge-width(opts.style, depth) }
    if opts.edge == "straight" {
      line(a, b, stroke: (paint: col, thickness: w2, cap: "round"))
    } else if opts.edge == "tapered" {
      // Born with the parent's rule thickness (a clean join), thinning to the child's.
      let parent-spec = _spec(n, depth, opts)
      let w1 = if parent-spec.rule != none { parent-spec.rule } else { w2 * 1.4 }
      // A rule ends in a round cap centered half its thickness inside the
      // node. The ribbon starts at the parent cap's center, so the cap (drawn
      // later, with the nodes) covers its flat start: no wedge beside the cap.
      let a = if parent-spec.rule != none { (a.at(0) - s * w1.pt() / 2, a.at(1)) } else { a }
      line(..ribbon(a, b, w1.pt(), w2.pt()), close: true, fill: col, stroke: none)
      circle(b, radius: w2.pt() / 2, fill: col, stroke: none)
      // At the child, a ribbon that stops at the node's edge leaves a waist
      // before the cap. Run it on to the cap's center, under the rule.
      if child-spec.rule != none {
        line(b, (b.at(0) + s * w2.pt() / 2, b.at(1)), stroke: (paint: col, thickness: w2, cap: "butt"))
      }
    } else {
      let (p0, p1, p2, p3) = edge-curve(a, b)
      bezier(p0, p3, p1, p2, stroke: (paint: col, thickness: w2, cap: "round"))
    }
  }
  for c in n.children { _draw-edges(c, palette, opts, depth + 1) }
}

// Nodes, with their rule and capsule. Recursive. The body is the one measured.
#let _draw-nodes(n, palette, opts, depth) = {
  import cetz.draw: *
  let color = _branch-color(n, palette)
  let role = _role-color(n, opts)
  let spec = _spec(n, depth, opts)
  let paint = node-paint(spec, depth, color, opts.ink, if n.emphasized { role } else { none },
    role: if n.tag != none { role } else { none })
  let top = _top(n)
  // The rule is a STROKE drawn here, not a border of the box: the edge that
  // arrives at it is the same kind of line, so the join has no step.
  if spec.rule != none {
    let r = spec.rule.pt() / 2
    let y = -(top + n.h - r)
    line((n.x + r, y), (n.x + n.w - r, y), stroke: (paint: paint.rule, thickness: spec.rule, cap: "round"))
  }
  content((n.x, -top), anchor: "north-west", node-body(n.content, spec, paint, opts.font, opts.text-size,
    width: n.w * 1pt, number: n.number, tag: n.tag, mono-font: opts.mono-font, side: _side(n)))
  // The capsule: 60% of the node's height, centered, fully rounded.
  if spec.capsule {
    let x = n.x + (if spec.frame == "surface" { 4 } else { 1.2 })
    let cy = -(top + n.h / 2)
    line((x, cy + n.h * 0.3), (x, cy - n.h * 0.3), stroke: (paint: paint.capsule, thickness: 2pt, cap: "round"))
  }
  for c in n.children { _draw-nodes(c, palette, opts, depth + 1) }
}

/// Draws the already positioned mind map (the output of `layout-tree`).
#let draw-mindmap(n, palette, opts) = {
  _draw-edges(n, palette, opts, 0)
  _draw-nodes(n, palette, opts, 0)
}
