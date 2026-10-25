#import "style.typ": inset-top, node-body, node-paint, node-spec

// Neutral colors for the measuring pass: the geometry is the drawing's, and
// geometry is all that matters here.
#let _neutral-ink = (strong: black, soft: black, faint: black)

/// What a node shows besides its label, decided ONCE here and carried on the
/// measured node to the drawing pass, so both passes agree.
#let dressing(n, depth, index, opts) = {
  let role = n.at("emphasis", default: none)
  (
    emphasized: role != none and opts.markers == "none",
    surfaced: opts.surface == "all" or (opts.surface == "branches" and depth == 1),
    number: if depth == 1 { (if index < 9 { "0" } else { "" }) + str(index + 1) } else { none },
    tag: if opts.markers == "role" and role != none and depth >= 2 {
      opts.emphasis-labels.at(role, default: none)
    } else { none },
  )
}

/// Measures one node. Returns `(w, h, a)` in points: `a` is where an edge
/// lands, measured from the node's top — on the rule, in the middle of a
/// frame, or on the middle of the first line. MUST be called inside `context`.
#let measure-node(content, depth, opts, dress) = {
  let spec = node-spec(opts.style, depth, emphasized: dress.emphasized, surfaced: dress.surfaced)
  let paint = node-paint(spec, depth, black, _neutral-ink, none,
    role: if dress.tag != none { black } else { none }, neutral: true)
  let body(width) = node-body(content, spec, paint, opts.font, opts.text-size,
    width: width, number: dress.number, tag: dress.tag, mono-font: opts.mono-font)
  let max-w = if depth == 0 { opts.root-max-width } else { opts.node-max-width }
  let natural = measure(body(auto))
  let (w, h) = if natural.width <= max-w { (natural.width, natural.height) } else {
    // The width goes INTO the node's own box, so the label wraps inside the inset.
    (max-w, measure(body(max-w)).height)
  }
  let cap = measure(text(font: opts.font, size: opts.text-size * spec.scale, weight: spec.weight)[X]).height
  let a = if spec.rule != none { h - spec.rule / 2 }
    else if spec.frame in ("box", "filled", "surface") or spec.capsule { h / 2 }
    else { inset-top(spec.inset) + cap / 2 }
  (w: w.pt(), h: h.pt(), a: a.pt())
}

/// Annotates every node with `w`, `h`, `a` and its dressing. MUST be called
/// inside `context`. `index` is the node's position among its siblings.
#let measure-tree(n, opts, depth: 0, index: 0) = {
  let dress = dressing(n, depth, index, opts)
  let m = measure-node(n.content, depth, opts, dress)
  (
    ..n,
    ..dress,
    children: n.children.enumerate().map(((i, c)) => measure-tree(c, opts, depth: depth + 1, index: i)),
    w: m.w,
    h: m.h,
    a: m.a,
  )
}

// Pós-ordem: anota cada nó com `ext` (faixa vertical da subárvore, pt).
#let _assign-extent(n, v-gap) = {
  if n.children.len() == 0 {
    return (..n, ext: n.h)
  }
  let kids = n.children.map(c => _assign-extent(c, v-gap))
  let kids-ext = kids.fold(0.0, (a, c) => a + c.ext) + v-gap * (kids.len() - 1)
  (..n, children: kids, ext: calc.max(n.h, kids-ext))
}

// Max width per relative depth (1 = branch) of a group of subtrees.
#let _widths(n, depth, acc) = {
  let acc = acc
  while acc.len() < depth { acc.push(0.0) }
  acc.at(depth - 1) = calc.max(acc.at(depth - 1), n.w)
  for c in n.children { acc = _widths(c, depth + 1, acc) }
  acc
}

// Pre-order: x/y/side/branch-index. `dist` is the distance from the root's
// left edge to this node's near edge (right side), mirrored on the left.
// `branch` is the palette index inherited from above; an explicit `branch`
// (1..n) on this node replaces it for the node and its whole subtree.
#let _place(n, side, top, depth, dist, ctx, branch) = {
  let branch = if n.at("branch", default: none) != none { n.branch - 1 } else { branch }
  let d = if ctx.starts != none { ctx.starts.at(depth - 1) } else { dist }
  let y = top + n.ext / 2
  let x = if side > 0 { d } else { -(d - ctx.root-w) - n.w }
  let kids-span = if n.children.len() == 0 { 0.0 } else {
    n.children.fold(0.0, (a, c) => a + c.ext) + ctx.vg * (n.children.len() - 1)
  }
  let cursor = top + (n.ext - kids-span) / 2
  let kids = ()
  for c in n.children {
    kids.push(_place(c, side, cursor, depth + 1, d + n.w + ctx.hg, ctx, branch))
    cursor = cursor + c.ext + ctx.vg
  }
  (..n, children: kids, x: x, y: y, side: side, branch-index: branch)
}

#let _span(group, vg) = if group.len() == 0 { 0.0 } else {
  group.fold(0.0, (a, c) => a + c.ext) + vg * (group.len() - 1)
}

// One side: its branches stacked and centered on the root's center.
#let _place-group(group, side, root, hg, vg, align) = {
  if group.len() == 0 { return () }
  let starts = if align {
    let widths = group.fold((), (acc, c) => _widths(c, 1, acc))
    let s = (root.w + hg,)
    for i in range(1, widths.len()) { s.push(s.at(i - 1) + widths.at(i - 1) + hg) }
    s
  } else { none }
  let ctx = (root-w: root.w, hg: hg, vg: vg, starts: starts)
  let cursor = root.center - _span(group, vg) / 2
  let out = ()
  for c in group {
    out.push(_place(c, side, cursor, 1, root.w + hg, ctx, c.position))
    cursor = cursor + c.ext + vg
  }
  out
}

// Where to cut the branches for "both": the first ones go right, keeping
// order, and the cut balances the two sides by subtree size.
#let _split(kids, vg) = {
  if kids.len() < 2 { return (kids, ()) }
  let total = kids.fold(0.0, (a, c) => a + c.ext)
  let acc = 0.0
  let best = 1
  let best-diff = calc.inf
  for i in range(kids.len() - 1) {
    acc = acc + kids.at(i).ext
    let diff = calc.abs(acc - total / 2)
    if diff < best-diff { best-diff = diff; best = i + 1 }
  }
  (kids.slice(0, best), kids.slice(best))
}

/// Annotates the measured tree with `x`/`y`/`side`/`branch-index`/`ext`.
/// The root sits at `x = 0` with `side: 0` and `branch-index: -1`; `y` grows
/// downwards. `direction`: "right", "left" or "both". `align-levels`: every
/// depth starts at one column per side, instead of right after its parent.
#let layout-tree(n, h-gap, v-gap, direction: "right", align-levels: false) = {
  let hg = if type(h-gap) == length { h-gap.pt() } else { h-gap }
  let vg = if type(v-gap) == length { v-gap.pt() } else { v-gap }
  let e = _assign-extent(n, vg)
  let kids = e.children.enumerate().map(((i, c)) => (..c, position: i))
  let (right, left) = if direction == "both" { _split(kids, vg) }
    else if direction == "left" { ((), kids) } else { (kids, ()) }
  let height = calc.max(e.h, _span(right, vg), _span(left, vg))
  let root = (w: e.w, center: height / 2)
  (
    ..e,
    children: _place-group(right, 1, root, hg, vg, align-levels) + _place-group(left, -1, root, hg, vg, align-levels),
    x: 0.0,
    y: height / 2,
    side: 0,
    branch-index: -1,
  )
}
