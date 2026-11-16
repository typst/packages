// Layout: every subtree is measured and its children are placed by
// contour, in two axes -- the main axis m along which the tree grows and
// the cross axis u along which siblings stand. Horizontal layouts (both,
// right, left, star) have m = x and u pointing down; vertical ones (down,
// up) have m = y and u = x pointing right. `dir` is the sign of the
// direction of growth on m.

#import "input.typ": _norm
#import "node.typ": _measure-node, _nodebox, _spec

// --- Layout ----------------------------------------------------------------
//
// All layouts work in two axes: the main axis m, along which the tree
// grows, and the cross axis u, along which siblings stand side by side.
// Horizontal layouts (both, right, left, radial) have m = x and u pointing
// down; vertical ones (down, up) have m = y and u = x pointing right.
// `dir` is the sign of the direction of growth on m.

// Size of a box on the two axes.
#let _sizes(m, vertical) = if vertical { (m: m.h, u: m.w) } else { (m: m.w, u: m.h) }

// Annotates a subtree with sizes and places its children. Result:
//   w, h, width   size of the node's own box
//   size-m/-u     the same on the axes
//   kids          the children, each with `du`: offset on u from the centre
//   contour       per depth below this node (lo, hi): how far the subtree
//                 reaches on u before and behind the centre on that level
//                 (lo negative)
//   lo, hi        the same over all levels; size = hi - lo
//   extent        extent of the subtree on m, from its own box on
//
// Siblings are not stacked as blocks but by contour: the next child moves
// up as far as it collides with the previous one on no level. So a leaf
// without children stays close to its neighbour, even if that one has a
// deep subtree.
#let _measure-tree(node, depth, base, opts, vertical, force: none) = {
  // `shade` steps the branch colour per level: positive lightens towards
  // the leaves, negative darkens.
  let color = if opts.shade == 0% or depth <= 1 { base }
    else if opts.shade > 0% { base.lighten(opts.shade * (depth - 1)) }
    else { base.darken(-opts.shade * (depth - 1)) }
  let m = _measure-node(node, depth, color, opts)
  // `force` sets the box to a given size: a sibling asked for equal sizes.
  // Width and height of a box are its outer size in Typst, so they go in
  // as they are; a shaped box needs both, or it would grow with every
  // measurement.
  let height = auto
  if force != none {
    let shaped = _spec(depth, opts.theme).shape != "rect"
    let w = if force.w != none { force.w } else if shaped and force.h != none { m.w } else { m.width }
    let h = if force.h != none { force.h } else if shaped and force.w != none { m.h } else { auto }
    let mm = measure(_nodebox(node, depth, color, opts, width: w, height: h))
    m = (w: mm.width, h: mm.height, width: w)
    height = h
  }
  let sz = _sizes(m, vertical)
  let kids = node.kids.map(k => _measure-tree(_norm(k), depth + 1, base, opts, vertical))
  // Equal children: measure them once more, each at the largest size.
  if node.equal != false and kids.len() > 1 {
    let maxw = kids.map(k => k.w).fold(0pt, calc.max)
    let maxh = kids.map(k => k.h).fold(0pt, calc.max)
    let f = (
      w: if node.equal in (true, "width") { maxw } else { none },
      h: if node.equal in (true, "height") { maxh } else { none },
    )
    kids = node.kids.map(k => _measure-tree(_norm(k), depth + 1, base, opts, vertical, force: f))
  }

  let placed = ()
  let merged = ()   // contour of the children placed so far, absolute on u
  for k in kids {
    let u = 0pt
    if placed.len() > 0 {
      u = -1e9 * 1pt
      let d = 0
      while d < merged.len() and d < k.contour.len() {
        let limit = merged.at(d).hi + opts.sibling-gap - k.contour.at(d).lo
        if limit > u { u = limit }
        d += 1
      }
    }
    placed.push(k + (du: u))
    let d = 0
    while d < k.contour.len() {
      let c = (lo: u + k.contour.at(d).lo, hi: u + k.contour.at(d).hi)
      if d < merged.len() {
        merged.at(d) = (lo: calc.min(merged.at(d).lo, c.lo), hi: calc.max(merged.at(d).hi, c.hi))
      } else {
        merged.push(c)
      }
      d += 1
    }
  }

  // Parent centred between first and last child.
  let shift = if placed.len() > 0 { (placed.first().du + placed.last().du) / 2 } else { 0pt }
  placed = placed.map(k => k + (du: k.du - shift))
  merged = merged.map(c => (lo: c.lo - shift, hi: c.hi - shift))

  let contour = ((lo: -sz.u / 2, hi: sz.u / 2),) + merged
  let extent = sz.m + if kids.len() > 0 { opts.level-gap + kids.map(k => k.extent).fold(0pt, calc.max) } else { 0pt }
  // A summary brace sits beyond the children and needs its own room along
  // m: gap, brace, gap, label.
  let summary = none
  if node.summary != none and kids.len() > 0 {
    let lm = measure(text(size: 0.9em, node.summary))
    summary = (w: lm.width, h: lm.height)
    extent += opts.summary-gap * 2 + opts.brace-size + if vertical { lm.height } else { lm.width }
  }
  // A cloud pads the subtree on every side.
  let pad = if node.cloud != none { opts.cloud-pad } else { 0pt }
  let contour = contour.map(c => (lo: c.lo - pad, hi: c.hi + pad))
  let extent = extent + pad
  let lo = contour.map(c => c.lo).fold(0pt, calc.min)
  let hi = contour.map(c => c.hi).fold(0pt, calc.max)
  (
    node: node, depth: depth, color: color, kids: placed,
    w: m.w, h: m.h, width: m.width, height: height, size-m: sz.m, size-u: sz.u,
    contour: contour, lo: lo, hi: hi, size: hi - lo, extent: extent,
    summary: summary, pad: pad,
  )
}

// Distributes the first-level branches to right and left. Explicitly set
// sides stay; the others fill the right side first until it holds at least
// half the total height, the rest goes left. The order (top to bottom) is
// kept on both sides.
#let _split(trees, gap, layout) = {
  if layout == "right" { return (right: trees, left: ()) }
  if layout == "left" { return (right: (), left: trees) }
  let total = trees.map(t => t.size).sum(default: 0pt) + gap * calc.max(trees.len() - 1, 0)
  let right = ()
  let left = ()
  let right-h = 0pt
  let fixed-right = trees.filter(t => t.node.side == right).map(t => t.size).sum(default: 0pt)
  for t in trees {
    if t.node.side == right {
      right.push(t)
    } else if t.node.side == left {
      left.push(t)
    } else if right-h + fixed-right + t.size / 2 <= total / 2 {
      right.push(t)
      right-h += t.size + gap
    } else {
      left.push(t)
    }
  }
  (right: right, left: left)
}

// The largest box extent on each depth: (max w, max h) per level.
#let _level-sizes(t, acc) = {
  while acc.len() <= t.depth { acc.push((w: 0pt, h: 0pt)) }
  acc.at(t.depth) = (w: calc.max(acc.at(t.depth).w, t.w), h: calc.max(acc.at(t.depth).h, t.h))
  for k in t.kids { acc = _level-sizes(k, acc) }
  acc
}

// The deepest level in a subtree.
#let _deepest(t) = if t.kids.len() == 0 { t.depth } else { t.kids.map(_deepest).fold(t.depth, calc.max) }

// Radial: the whole tree fans out from the root. Every subtree owns an
// angular sector, proportional to its number of leaves, nested inside its
// parent's sector; a node sits on the ring of its depth at the middle of
// its sector. The rings start at `root-gap` and are spread out together
// until no two boxes overlap. Text stays horizontal.

// Number of leaves below a node, at least 1.
#let _leaves(t) = if t.kids.len() == 0 { 1 } else { t.kids.map(_leaves).sum() }

// The weight of a node's sector: the square root of its leaf count. Plain
// leaf counts hand a wide branch most of the circle and squeeze the bare
// ones together; the root softens that without ignoring size.
#let _weight(t) = calc.sqrt(_leaves(t))

// Assigns angles: every node gets `angle` (centre of its sector) and
// `span` (width of its sector). The children share the parent's sector by
// leaf count, but never more of it than they need: on their ring, the arc
// they take up is their boxes plus gaps, so a branch with two leaves keeps
// them close instead of spreading them over a third of the circle.
// `radii` are the ring radii per depth. Returns the tree with these fields.
#let _sectors(t, angle, span, radii, gap) = {
  let total = t.kids.map(_weight).sum(default: 1)
  let kids = ()
  if t.kids.len() > 0 {
    // Extent of a box across the ray: on a horizontal ray the boxes stack
    // by height, on a vertical one by width.
    let r = radii.at(t.depth + 1)
    let across(k) = calc.abs(k.w * calc.sin(angle)) + calc.abs(k.h * calc.cos(angle))
    let arc = t.kids.map(k => across(k) + gap).sum()
    let needed = 1rad * (arc / r) * 1.15
    let span = calc.min(span, needed)
    let a = angle + span / 2
    for k in t.kids {
      let w = span * _weight(k) / total
      kids.push(_sectors(k, a - w / 2, w, radii, gap))
      a -= w
    }
  }
  t + (angle: angle, span: span, kids: kids)
}


// --- Arranging for cross-links ----------------------------------------------
//
// With `arrange: "links"` the first-level branches are ordered, and the
// children of each branch possibly reversed, so that the nodes joined by
// cross-links end up close together. The measured subtrees are enough for
// that: an order only moves subtrees along the cross axis, so the
// positions of every node can be worked out without measuring again.

// Positions (m, u) of every node with an id in a subtree whose box has its
// inner edge at m and its centre at u.
#let _positions(t, m, u, dir, gap, acc) = {
  if t.node.id != none { acc.insert(t.node.id, (m: m + dir * t.size-m / 2, u: u)) }
  let m1 = m + dir * t.size-m + dir * gap
  for k in t.kids { acc = _positions(k, m1, u + k.du, dir, gap, acc) }
  acc
}

// The positions of a whole arrangement: `sides` is (right, left) for the
// horizontal layouts, one side for the vertical ones.
#let _arrangement-positions(sides, root-m, opts) = {
  let acc = (root: (m: 0pt, u: 0pt))
  for (dir, side) in sides {
    let total = side.map(t => t.size).sum(default: 0pt) + opts.branch-gap * calc.max(side.len() - 1, 0)
    let cu = -total / 2
    for t in side {
      acc = _positions(t, dir * (root-m + opts.root-gap), cu - t.lo, dir, opts.level-gap, acc)
      cu += t.size + opts.branch-gap
    }
  }
  acc
}

// The cost of an arrangement: the summed distance of the cross-links.
#let _link-cost(links, pos) = {
  let cost = 0pt
  for l in links {
    if l.from in pos and l.to in pos {
      let (a, b) = (pos.at(l.from), pos.at(l.to))
      let (dm, du) = ((a.m - b.m) / 1pt, (a.u - b.u) / 1pt)
      cost += calc.sqrt(dm * dm + du * du) * 1pt
    }
  }
  cost
}

// All orderings of an array (for a handful of branches).
#let _permutations(xs) = {
  if xs.len() <= 1 { return (xs,) }
  let out = ()
  for (i, x) in xs.enumerate() {
    let rest = xs.slice(0, i) + xs.slice(i + 1)
    for p in _permutations(rest) { out.push((x,) + p) }
  }
  out
}

// Reverses the children of a subtree, keeping the contour: the offsets
// mirror around the centre.
#let _reversed(t) = {
  if t.kids.len() == 0 { return t }
  t + (kids: t.kids.rev().map(k => k + (du: -k.du)),
       contour: t.contour.map(c => (lo: -c.hi, hi: -c.lo)), lo: -t.hi, hi: -t.lo)
}