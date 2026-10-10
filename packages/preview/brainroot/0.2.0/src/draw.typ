// Drawing: edges, nodes, braces, clouds and cross-links, in the tree
// layouts.

#import "@preview/cetz:0.5.2"
#import "util.typ": _pt
#import "hand.typ": _wobble, _seed, _flatten-bezier, _rounded-rect, _hand-line
#import "node.typ": _nodebox, _framed, _hand-shape
#import "layout.typ": _deepest

// --- Drawing ---------------------------------------------------------------

#let _stroke(depth, color, opts) = (
  paint: color,
  thickness: opts.thickness.at(calc.min(depth, opts.thickness.len() - 1)),
  cap: "round",
  join: "round",
  dash: opts.theme.dash,
)

// A tapered edge: a filled ribbon along the curve, `taper.at(0)` times the
// level's thickness at the parent, `taper.at(1)` times at the child.
#let _taper(p0, c0, c1, p1, st, opts) = {
  import cetz.draw: line
  let n(p) = (_pt(p.at(0)), _pt(p.at(1)))
  let pts = _flatten-bezier(n(p0), n(c0), n(c1), n(p1), n: 32)
  let w = _pt(st.thickness)
  let (w0, w1) = (w * opts.theme.taper.at(0), w * opts.theme.taper.at(1))
  let left = ()
  let right = ()
  for (i, p) in pts.enumerate() {
    let (a, b) = if i == 0 { (pts.at(0), pts.at(1)) } else { (pts.at(i - 1), p) }
    let (dx, dy) = (b.at(0) - a.at(0), b.at(1) - a.at(1))
    let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
    let (nx, ny) = (-dy / len, dx / len)
    let t = i / (pts.len() - 1)
    let h = (w0 + (w1 - w0) * t) / 2
    left.push((p.at(0) + nx * h, p.at(1) + ny * h))
    right.push((p.at(0) - nx * h, p.at(1) - ny * h))
  }
  let hand = opts.theme.hand
  if hand != none {
    left = _wobble(left, hand, _seed(..pts.first(), ..pts.last()))
    right = _wobble(right, hand, _seed(..pts.last(), ..pts.first()))
  }
  line(..left, ..right.rev(), close: true, fill: st.paint, stroke: none)
}

// From axis coordinates (m, u) to (x, y).
#let _xy(m, u, vertical) = if vertical { (u, m) } else { (m, -u) }

// Draws the edge with the control points in the theme's routing; hand-drawn
// it is first flattened to a polyline and then wobbled.
#let _path(p0, c0, c1, p1, st, opts) = {
  import cetz.draw: bezier, line
  let edge = opts.theme.edge
  if edge == "taper" { return _taper(p0, c0, c1, p1, st, opts) }
  let hand = opts.theme.hand
  if hand == none {
    if edge == "curve" {
      bezier(p0, p1, c0, c1, stroke: st)
    } else if edge in ("elbow", "comb") {
      line(p0, c0, c1, p1, stroke: st)
    } else {
      line(p0, p1, stroke: st)
    }
  } else {
    let n(p) = (_pt(p.at(0)), _pt(p.at(1)))
    let pts = if edge == "curve" {
      _flatten-bezier(n(p0), n(c0), n(c1), n(p1))
    } else if edge in ("elbow", "comb") {
      (n(p0), n(c0), n(c1), n(p1))
    } else {
      (n(p0), n(p1))
    }
    _hand-line(pts, st, hand, _seed(..n(p0), ..n(p1)))
  }
}

// A plain line segment, hand-drawn if the theme is.
#let _seg(a, b, st, opts) = {
  import cetz.draw: line
  if opts.theme.hand == none { line(a, b, stroke: st) }
  else { _hand-line(((_pt(a.at(0)), _pt(a.at(1))), (_pt(b.at(0)), _pt(b.at(1)))), st, opts.theme.hand, _seed(_pt(a.at(0)), _pt(a.at(1)), _pt(b.at(0)))) }
}

// An edge from p0 to p1 in the theme's routing; the curve runs parallel to
// the main axis at both ends.
// (`st` instead of `stroke`: cetz.draw exports a function of that name.)
#let _controls(p0, p1, vertical) = {
  let (x0, y0) = p0
  let (x1, y1) = p1
  if vertical {
    let mid = (y0 + y1) / 2
    ((x0, mid), (x1, mid))
  } else {
    let mid = (x0 + x1) / 2
    ((mid, y0), (mid, y1))
  }
}

#let _edge(p0, p1, st, opts, vertical) = {
  let (c0, c1) = _controls(p0, p1, vertical)
  _path(p0, c0, c1, p1, st, opts)
}

// A point on an edge: the Bézier point at t. For an elbow t = 1/2 lands on
// the vertical segment, for a straight line at the midpoint.
#let _bez(p0, c0, c1, p1, t) = {
  let u = 1 - t
  let (a, b, c, d) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
  (a * p0.at(0) + b * c0.at(0) + c * c1.at(0) + d * p1.at(0),
   a * p0.at(1) + b * c0.at(1) + c * c1.at(1) + d * p1.at(1))
}
#let _mid(p0, c0, c1, p1) = _bez(p0, c0, c1, p1, 0.5)

// The tangent of an edge at t.
#let _tangent(p0, c0, c1, p1, t) = {
  let u = 1 - t
  let (a, b, c) = (3 * u * u, 6 * u * t, 3 * t * t)
  (a * (c0.at(0) - p0.at(0)) + b * (c1.at(0) - c0.at(0)) + c * (p1.at(0) - c1.at(0)),
   a * (c0.at(1) - p0.at(1)) + b * (c1.at(1) - c0.at(1)) + c * (p1.at(1) - c1.at(1)))
}

// The label box of an edge.
#let _label-box(label, opts) = box(fill: opts.edge-label-fill, inset: 0.25em, radius: 0.2em,
  text(size: 0.85em, fill: opts.ink-dark, top-edge: "bounds", bottom-edge: "bounds", label))

// A label beside an edge: well past the middle, near the child, where the
// edges of siblings have fanned apart, and moved off the edge along its normal by half the
// label's extent in that direction plus a gap, so it neither covers nor
// touches the line. Of the two normals the one closer to `prefer` is
// taken -- away from the parent's axis, so neighbouring labels part.
#let _edge-label-beside(p0, c0, c1, p1, prefer, label, opts, t: 0.8) = {
  import cetz.draw: content
  if label == none { return }
  let bx = _label-box(label, opts)
  let m = measure(bx)
  let p = _bez(p0, c0, c1, p1, t)
  let (dx, dy) = _tangent(p0, c0, c1, p1, t).map(_pt)
  let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
  let (nx, ny) = (-dy / len, dx / len)
  if nx * prefer.at(0) + ny * prefer.at(1) < 0 { (nx, ny) = (-nx, -ny) }
  let d = calc.abs(nx) * m.width / 2 + calc.abs(ny) * m.height / 2 + opts.label-offset
  content((p.at(0) + nx * d, p.at(1) + ny * d), bx)
}

// A small label sitting on an edge, at a given point.
#let _edge-label(at, label, opts) = {
  import cetz.draw: content
  if label == none { return }
  content(at, _label-box(label, opts))
}

// The side of an edge a label prefers: across the direction of growth,
// away from the parent's axis. `du` is the child's offset on the cross
// axis (positive downwards in horizontal layouts).
#let _prefer(du, vertical) = {
  let away = if du < 0pt { -1 } else { 1 }
  if vertical { (away, 0) } else { (0, -away) }
}

// Draws one node's box centred at (cx, cy), with its underline if the theme
// has one.
#let _draw-node(t, cx, cy, opts) = {
  import cetz.draw: *
  if opts.theme.hand != none { _hand-shape(cx, cy, t, t.depth, t.color, opts) }
  let id = if t.depth == 0 { "root" } else { t.node.id }
  content((cx, cy), _framed(t, _nodebox(t.node, t.depth, t.color, opts, width: t.width, height: t.at("height", default: auto))),
    name: if id == none { none } else { "n-" + id })
  if opts.show-points and t.node.points != none {
    // A badge at the top right corner of the box.
    content((cx + t.w / 2, cy + t.h / 2), anchor: "center",
      std.circle(radius: 0.55em, fill: opts.ink-dark, stroke: 0.1em + white,
        align(center + horizon, text(size: 0.6em, fill: white, weight: "bold", str(t.node.points)))))
  }
  if opts.theme.underline and t.depth > 0 {
    // The underline is a line of its own in the width of the edge flowing
    // into it; as a box border it would have a different width and sit
    // offset by half its thickness.
    let st = _stroke(t.depth - 1, t.color, opts) + (cap: "butt")
    let (a, b) = ((cx - t.w / 2, cy - t.h / 2), (cx + t.w / 2, cy - t.h / 2))
    if opts.theme.hand == none { line(a, b, stroke: st) }
    else { _hand-line(((_pt(a.at(0)), _pt(a.at(1))), (_pt(b.at(0)), _pt(b.at(1)))), st, opts.theme.hand, _seed(_pt(a.at(0)), _pt(a.at(1)))) }
  }
}

// Draws a subtree whose box has its inner edge at m and is centred at u.
// With `underline` in a horizontal layout the edges sit on the baseline of
// the text, otherwise at the centre of the box.
// A soft rounded shape behind a subtree.
#let _cloud(t, m, u, dir, opts, vertical) = {
  import cetz.draw: *
  let fill = if t.node.cloud == true { t.color.lighten(85%) } else { t.node.cloud }
  let st = (paint: t.color, thickness: 0.06em, dash: "dashed")
  let a = _xy(m - dir * t.pad, u + t.lo, vertical)
  let b = _xy(m + dir * t.extent, u + t.hi, vertical)
  if opts.theme.hand == none {
    rect(a, b, fill: fill, stroke: st, radius: 0.8em)
  } else {
    let (cx, cy) = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
    let (w, h) = (calc.abs(_pt(b.at(0)) - _pt(a.at(0))), calc.abs(_pt(b.at(1)) - _pt(a.at(1))))
    _hand-line(_rounded-rect(_pt(cx), _pt(cy), w, h, _pt(0.8em.to-absolute())), st, opts.theme.hand,
      _seed(_pt(cx), _pt(cy), w, h), closed: true, fill: fill)
  }
}

// A brace beyond the children of a node, spanning them, with its label.
#let _summary(t, m1, u, dir, opts, vertical) = {
  import cetz.draw: *
  let inner = if opts.levels == none { t.kids.map(k => k.extent).fold(0pt, calc.max) }
    else { t.extent - t.pad - (opts.levels.at(t.depth + 1) - opts.levels.at(t.depth)) - opts.summary-gap * 2 - opts.brace-size - (if t.summary == none { 0pt } else if vertical { t.summary.h } else { t.summary.w }) }
  let mb = m1 + dir * (inner + opts.summary-gap)
  let lo = t.kids.map(k => k.du + k.lo).fold(0pt, calc.min)
  let hi = t.kids.map(k => k.du + k.hi).fold(0pt, calc.max)
  // The brace's tip points to the left of its direction: run it so the tip
  // faces away from the tree.
  let (p, q) = if dir > 0 { (_xy(mb, u + lo, vertical), _xy(mb, u + hi, vertical)) }
    else { (_xy(mb, u + hi, vertical), _xy(mb, u + lo, vertical)) }
  // A CeTZ brace is a tapered, filled shape: colour the fill, no stroke.
  let amp = _pt(opts.brace-size.to-absolute())
  cetz.decorations.brace(p, q, amplitude: amp, fill: t.color, stroke: none,
    outer-inset: amp * 0.6, inner-outset: amp * 0.3, thickness: amp * 0.14)
  let ml = mb + dir * (opts.brace-size + opts.summary-gap)
  let anchor = if vertical { if dir > 0 { "south" } else { "north" } } else { if dir > 0 { "west" } else { "east" } }
  content(_xy(ml, u + (lo + hi) / 2, vertical), anchor: anchor,
    text(size: 0.9em, fill: t.color.darken(20%), t.node.summary))
}

#let _draw-tree(t, m, u, dir, opts, vertical) = {
  import cetz.draw: *
  if t.at("hidden", default: false) { return }
  let ul = opts.theme.underline and not vertical
  let anchor(tree, cu) = if ul { cu + tree.size-u / 2 } else { cu }
  let m0 = m + dir * t.size-m
  // `levels` (align-levels) puts every level on one line across all
  // branches; otherwise a child follows its parent at `level-gap`.
  let m1 = if opts.levels == none { m0 + dir * opts.level-gap } else { dir * opts.levels.at(t.depth + 1, default: 0pt) }
  let t = if opts.levels == none { t } else {
    // With aligned levels the subtree reaches to the end of its deepest
    // level, not to the sum of its own boxes.
    let d = _deepest(t)
    t + (extent: opts.levels.at(d) + opts.level-sizes.at(d) - opts.levels.at(t.depth) + t.pad)
  }
  if t.node.cloud != none { _cloud(t, m, u, dir, opts, vertical) }
  if t.summary != none { _summary(t, m1, u, dir, opts, vertical) }
  if opts.theme.edge == "comb" and t.kids.len() > 0 {
    // Comb: one stem out of the parent, a spine across the children, a
    // twig into each of them.
    let st = _stroke(t.kids.first().depth - 1, t.color, opts)
    let ms = m0 + dir * opts.level-gap * 0.55
    let us = t.kids.map(k => anchor(k, u + k.du))
    _seg(_xy(m0, anchor(t, u), vertical), _xy(ms, anchor(t, u), vertical), st, opts)
    _seg(_xy(ms, calc.min(anchor(t, u), ..us), vertical), _xy(ms, calc.max(anchor(t, u), ..us), vertical), st, opts)
    for k in t.kids {
      let ku = u + k.du
      let p0 = _xy(ms, anchor(k, ku), vertical)
      let p1 = _xy(m1, anchor(k, ku), vertical)
      _seg(p0, p1, _stroke(k.depth - 1, k.color, opts), opts)
      _edge-label-beside(p0, p0, p1, p1, _prefer(k.du, vertical), k.node.edge-label, opts, t: 0.5)
      _draw-tree(k, m1, ku, dir, opts, vertical)
    }
  } else {
    for k in t.kids {
      let ku = u + k.du
      let p0 = _xy(m0, anchor(t, u), vertical)
      let p1 = _xy(m1, anchor(k, ku), vertical)
      let (c0, c1) = _controls(p0, p1, vertical)
      _path(p0, c0, c1, p1, _stroke(k.depth - 1, k.color, opts), opts)
      _edge-label-beside(p0, c0, c1, p1, _prefer(k.du, vertical), k.node.edge-label, opts)
      _draw-tree(k, m1, ku, dir, opts, vertical)
    }
  }
  // The box after the edges, so it covers their ends.
  let (cx, cy) = _xy(m + dir * t.size-m / 2, u, vertical)
  _draw-node(t, cx, cy, opts)
}

// Edge from the root to a branch: leaves the root towards the branch and
// arrives parallel to the main axis.
#let _root-controls(p1, m-inner, opts, vertical) = {
  if opts.theme.edge == "comb" {
    // Straight from the root, as the twigs are straight too.
    ((0pt, 0pt), p1)
  } else if opts.theme.edge not in ("curve", "taper") or vertical {
    // The bend halfway between the root's border and the branch -- not
    // halfway from the root's centre, which on a wide root would put it
    // right at the border. Vertically the S-curve with its inflection
    // there is calmest too.
    let (x1, y1) = p1
    if vertical {
      let mid = (m-inner + y1) / 2
      ((0pt, mid), (x1, mid))
    } else {
      let mid = (m-inner + x1) / 2
      ((mid, 0pt), (mid, y1))
    }
  } else {
    let (x1, y1) = p1
    ((x1 * 0.9, 0pt), (m-inner, y1))
  }
}

#let _root-edge(p1, m-inner, st, opts, vertical, label: none, du: 0pt) = {
  let (c0, c1) = _root-controls(p1, m-inner, opts, vertical)
  _path((0pt, 0pt), c0, c1, p1, st, opts)
  _edge-label-beside((0pt, 0pt), c0, c1, p1, _prefer(du, vertical), label, opts)
}

// A hidden subtree (`reveal`) still claims its room: an invisible rectangle
// over its extent keeps the canvas, and with it the map, the same size.
#let _ghost(t, m, u, dir, opts, vertical) = {
  import cetz.draw: rect
  rect(_xy(m, u + t.lo, vertical), _xy(m + dir * t.extent, u + t.hi, vertical), stroke: none, fill: none)
}

// Stacks branches on u, centred around 0, and draws them with their root edge.
#let _draw-stack(side, dir, m-inner, m1, opts, vertical) = {
  let total = side.map(t => t.size).sum(default: 0pt) + opts.branch-gap * calc.max(side.len() - 1, 0)
  let cu = -total / 2
  for t in side {
    let tu = cu - t.lo
    let au = if opts.theme.underline and not vertical { tu + t.size-u / 2 } else { tu }
    if t.at("hidden", default: false) {
      _ghost(t, m1, tu, dir, opts, vertical)
    } else {
      _root-edge(_xy(m1, au, vertical), dir * m-inner, _stroke(0, t.color, opts), opts, vertical,
        label: t.node.edge-label, du: tu)
      _draw-tree(t, m1, tu, dir, opts, vertical)
    }
    cu += t.size + opts.branch-gap
  }
}

// The box sizes of every node with an id, for the cross-links.
#let _sizes-by-id(t, acc) = {
  if t.node.id != none { acc.insert(t.node.id, (w: t.w, h: t.h)) }
  for k in t.kids { acc = _sizes-by-id(k, acc) }
  acc
}

// Where a line from the centre of a box towards `to` leaves the box.
#let _border(c, to, size) = {
  let (dx, dy) = (to.at(0) - c.at(0), to.at(1) - c.at(1))
  let (hw, hh) = (_pt(size.w) / 2, _pt(size.h) / 2)
  let t = calc.min(if calc.abs(dx) < 1e-6 { 1e9 } else { hw / calc.abs(dx) },
                   if calc.abs(dy) < 1e-6 { 1e9 } else { hh / calc.abs(dy) })
  (c.at(0) + dx * t, c.at(1) + dy * t)
}

// A point on the line from `p` towards `towards`, `d` pt away from `p`.
#let _shorten(p, towards, d) = {
  let (dx, dy) = (_pt(towards.at(0)) - _pt(p.at(0)), _pt(towards.at(1)) - _pt(p.at(1)))
  let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
  (_pt(p.at(0)) + dx / len * d, _pt(p.at(1)) + dy / len * d)
}

// A stealth arrowhead with its tip at `tip`, pointing away from `from`.
#let _head(tip, from, size, color) = {
  import cetz.draw: line
  let (tx, ty) = (_pt(tip.at(0)), _pt(tip.at(1)))
  let (dx, dy) = (tx - _pt(from.at(0)), ty - _pt(from.at(1)))
  let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
  let (ux, uy) = (dx / len, dy / len)
  let (nx, ny) = (-uy, ux)
  let base = (tx - ux * size, ty - uy * size)
  let notch = (tx - ux * size * 0.7, ty - uy * size * 0.7)
  line((tx, ty), (base.at(0) + nx * size * 0.4, base.at(1) + ny * size * 0.4), notch,
    (base.at(0) - nx * size * 0.4, base.at(1) - ny * size * 0.4), close: true, fill: color, stroke: none)
}

// Cross-links, drawn last, over everything: the nodes are addressed by the
// CeTZ names `_draw-node` gave them.
#let _draw-links(links, sizes, opts) = {
  import cetz.draw: *
  for l in links {
    assert(l.from in sizes and l.to in sizes,
      message: "brainroot: connect(" + repr(l.from) + ", " + repr(l.to) + "): no node with that id")
    get-ctx(ctx => {
      let (_, a, b) = cetz.coordinate.resolve(ctx, "n-" + l.from + ".center", "n-" + l.to + ".center")
      let p0 = _border(a, b, sizes.at(l.from))
      let p1 = _border(b, a, sizes.at(l.to))
      let (dx, dy) = (p1.at(0) - p0.at(0), p1.at(1) - p0.at(1))
      let mid = ((p0.at(0) + p1.at(0)) / 2, (p0.at(1) + p1.at(1)) / 2)
      // `bend: auto` bows the curve away from the root, out of the map's
      // busy middle; a given ratio bows to the left of the direction of
      // travel, negative to the right.
      let bend = if l.bend == auto {
        let side = mid.at(0) * (-dy) + mid.at(1) * dx
        if side >= 0 { 35% } else { -35% }
      } else { l.bend }
      let c = (mid.at(0) - dy * bend / 100%, mid.at(1) + dx * bend / 100%)
      // The curve leaves and arrives along the line from the control point
      // to the box centre, so that is where it meets the border -- not
      // where the straight line between the centres would.
      let p0 = _border(a, c, sizes.at(l.from))
      let p1 = _border(b, c, sizes.at(l.to))
      let color = if l.color == auto { rgb("#555555") } else { l.color }
      let st = (paint: color, thickness: l.thickness, dash: l.dash, cap: "round")
      // The heads are drawn here, along the exact tangent of the curve at
      // its ends; CeTZ takes the direction from the last sampled piece,
      // which points elsewhere on a curve that bends hard at the end.
      // The curve stops short by the head's length so the dashes do not
      // poke through it.
      let size = _pt(l.thickness.to-absolute()) * 6
      let at-end = l.arrow in (true, "both")
      let at-start = l.arrow == "both"
      let (q0, q1) = (p0, p1)
      if at-end { q1 = _shorten(p1, c, size * 0.8) }
      if at-start { q0 = _shorten(p0, c, size * 0.8) }
      if opts.theme.hand == none {
        bezier(q0, q1, c, stroke: st)
      } else {
        let pts = _flatten-bezier(q0, c, c, q1)
        let q = _wobble(pts, opts.theme.hand, _seed(..p0, ..p1))
        line(..q, stroke: st)
      }
      if at-end { _head(p1, c, size, color) }
      if at-start { _head(p0, c, size, color) }
      if l.label != none {
        let mid = (0.25 * p0.at(0) + 0.5 * c.at(0) + 0.25 * p1.at(0), 0.25 * p0.at(1) + 0.5 * c.at(1) + 0.25 * p1.at(1))
        content(mid, box(fill: opts.edge-label-fill, inset: 0.25em, radius: 0.2em,
          text(size: 0.85em, fill: color, top-edge: "bounds", bottom-edge: "bounds", l.label)))
      }
    })
  }
}
