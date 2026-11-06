// The layouts that are not trees: star, radial and fishbone.

#import "@preview/cetz:0.5.2"
#import "draw.typ": _stroke, _path, _seg, _root-edge, _draw-tree, _draw-node, _edge-label, _edge-label-beside, _mid, _bez, _ghost
#import "layout.typ": _leaves, _weight, _sectors, _level-sizes

// Star: every branch gets an angle, its box sits on a circle around the
// root, its subtree grows horizontally outward. The radius starts at
// `root-gap` and grows until no two subtrees overlap.
#let _draw-star(trees, rm, start, opts) = {
  let n = trees.len()
  if n == 0 { return }
  let angles = range(n).map(i => start - i * 360deg / n)
  let dirs = angles.map(a => if calc.cos(a) >= 0 { 1 } else { -1 })
  // Inner edge of the branch box: to the sides it sits on the circle point;
  // the closer the branch is to vertical, the further the box moves over
  // the point, until it is centred directly above or below it.
  let inner(i, r) = {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let f = 1 - calc.min(1, calc.abs(calc.cos(a)) / 0.4)
    (px: r * calc.cos(a) - d * t.w / 2 * f, py: r * calc.sin(a))
  }
  // Rectangle of a subtree at radius r: (x0, x1, y0, y1)
  let rect(i, r) = {
    let (d, t) = (dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    (x0: calc.min(px, px + d * t.extent), x1: calc.max(px, px + d * t.extent),
     y0: py - t.hi, y1: py - t.lo)
  }
  let overlaps(r) = {
    let gap = opts.branch-gap
    let rects = range(n).map(i => rect(i, r))
    // keep the root clear as well
    rects.push((x0: -rm.w / 2 - opts.root-gap / 2, x1: rm.w / 2 + opts.root-gap / 2,
                y0: -rm.h / 2 - gap, y1: rm.h / 2 + gap))
    for i in range(rects.len()) {
      for j in range(i + 1, rects.len()) {
        let (a, b) = (rects.at(i), rects.at(j))
        if a.x0 < b.x1 + gap and b.x0 < a.x1 + gap and a.y0 < b.y1 + gap and b.y0 < a.y1 + gap {
          return true
        }
      }
    }
    false
  }
  let r = calc.max(rm.w, rm.h) / 2 + opts.root-gap
  let steps = 0
  while overlaps(r) and steps < 400 { r += 4pt; steps += 1 }

  for i in range(n) {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    if t.at("hidden", default: false) { _ghost(t, px, -py, d, opts, false); continue }
    let st = _stroke(0, t.color, opts)
    if calc.abs(calc.cos(a)) < 0.2 and opts.theme.edge == "curve" {
      // Branch almost straight above or below the root: the edge arrives at
      // the centre of the box from above or below instead of hooking in
      // from the side.
      let cx = px + d * t.w / 2
      let ty = if py < 0pt { py + t.h / 2 } else { py - t.h / 2 }
      _path((0pt, 0pt), (0pt, ty / 2), (cx, ty / 2), (cx, ty), st, opts)
      _edge-label-beside((0pt, 0pt), (0pt, ty / 2), (cx, ty / 2), (cx, ty), (1, 0), t.node.edge-label, opts)
    } else {
      let ay = if opts.theme.underline { py - t.size-u / 2 } else { py }
      _root-edge((px, ay), px - d * opts.root-gap / 2, st, opts, false, label: t.node.edge-label, du: -py)
    }
    _draw-tree(t, px, -py, d, opts, false)
  }
}

#let _draw-radial(trees, rm, start, opts) = {
  let n = trees.len()
  if n == 0 { return }
  // Ring radii per depth, a tight first guess: the rings are spread out
  // below until nothing overlaps.
  let sizes = _level-sizes((depth: 0, w: rm.w, h: rm.h, kids: trees), ())
  let radii = (0pt,)
  for d in range(1, sizes.len()) {
    let gap = if d == 1 { opts.root-gap } else { opts.level-gap }
    radii.push(radii.at(d - 1) + sizes.at(d - 1).h / 2 + gap + sizes.at(d).h / 2)
  }
  // Sectors of the first level, clockwise from `start`, by leaf count.
  let total = trees.map(_weight).sum()
  let a = start
  let placed = ()
  for t in trees {
    let w = 360deg * _weight(t) / total
    placed.push(_sectors(t, a - w / 2, w, radii, opts.sibling-gap))
    a -= w
  }
  // Positions for a spreading factor f; then all boxes as rectangles.
  let pos(t, f) = (radii.at(t.depth) * f * calc.cos(t.angle), radii.at(t.depth) * f * calc.sin(t.angle))
  let rects(t, f, acc) = {
    let (x, y) = pos(t, f)
    acc.push((x0: x - t.w / 2, x1: x + t.w / 2, y0: y - t.h / 2, y1: y + t.h / 2))
    for k in t.kids { acc = rects(k, f, acc) }
    acc
  }
  let overlaps(f) = {
    let gap = opts.sibling-gap
    let rs = ((x0: -rm.w / 2, x1: rm.w / 2, y0: -rm.h / 2, y1: rm.h / 2),)
    for t in placed { rs = rects(t, f, rs) }
    for i in range(rs.len()) {
      for j in range(i + 1, rs.len()) {
        let (p, q) = (rs.at(i), rs.at(j))
        if p.x0 < q.x1 + gap and q.x0 < p.x1 + gap and p.y0 < q.y1 + gap and q.y0 < p.y1 + gap {
          return true
        }
      }
    }
    false
  }
  let f = 1.0
  let steps = 0
  while overlaps(f) and steps < 60 { f *= 1.05; steps += 1 }

  // Edges first, boxes after, so the boxes cover the line ends.
  let draw(t, parent, pa) = {
    let p = pos(t, f)
    let st = _stroke(t.depth - 1, t.color, opts)
    let (c0, c1) = if opts.theme.edge == "curve" {
      // Leaves the parent along its own ray and arrives along the child's:
      // a gentle bend that keeps the fan readable.
      let (dx, dy) = (p.at(0) - parent.at(0), p.at(1) - parent.at(1))
      let d = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt)) * 1pt * 0.4
      ((parent.at(0) + d * calc.cos(pa), parent.at(1) + d * calc.sin(pa)),
       (p.at(0) - d * calc.cos(t.angle), p.at(1) - d * calc.sin(t.angle)))
    } else { (parent, p) }
    _path(parent, c0, c1, p, st, opts)
    // Beside the edge, on the side that faces up.
    _edge-label-beside(parent, c0, c1, p, (0, 1), t.node.edge-label, opts, t: 0.6)
    for k in t.kids { draw(k, p, t.angle) }
  }
  let shown = placed.filter(t => not t.at("hidden", default: false))
  for t in shown { draw(t, (0pt, 0pt), t.angle) }
  // Hidden branches keep their room, as in the other layouts.
  let ghosts(t) = {
    let (x, y) = pos(t, f)
    cetz.draw.rect((x - t.w / 2, y - t.h / 2), (x + t.w / 2, y + t.h / 2), stroke: none, fill: none)
    for k in t.kids { ghosts(k) }
  }
  for t in placed.filter(t => t.at("hidden", default: false)) { ghosts(t) }
  let boxes(t) = {
    let (x, y) = pos(t, f)
    _draw-node(t, x, y, opts)
    for k in t.kids { boxes(k) }
  }
  for t in shown { boxes(t) }
}

// Fishbone (Ishikawa): the root is the head at the right end of a spine,
// the branches are ribs leaning towards it, alternating above and below,
// their children hang off the rib as leaves with a short tick. Two levels
// below the root; deeper nodes are not drawn.
#let _draw-fishbone(trees, rm, opts) = {
  import cetz.draw: *
  let n = trees.len()
  if n == 0 { return }
  let tick = opts.level-gap * 0.4
  let step = opts.sibling-gap
  let lean = 60deg
  // Pairs of ribs share a spine point; a pair's column is as wide as the
  // wider of the two needs.
  let pairs = range(calc.ceil(n / 2)).map(j => trees.slice(2 * j, calc.min(2 * j + 2, n)))
  // What a rib needs: its length, how far the rib and its leaves reach to
  // the left of the spine point, and how far the branch box may stick out
  // to the right of it.
  let need(t) = {
    let leaves = t.kids.map(k => k.w + tick).fold(0pt, calc.max)
    let l = (t.kids.len() + 1) * (t.kids.map(k => k.h).fold(0pt, calc.max) + step)
    let l = calc.max(l, 3 * opts.level-gap)
    let run = l * calc.cos(lean)
    (len: l, left: calc.max(run + t.w / 2, run + leaves), right: calc.max(0pt, t.w / 2 - run))
  }
  let cols = pairs.map(p => p.map(need))
  // The spine points, from the head leftwards: a pair's point sits at the
  // right edge of what its ribs need, so no room is left over.
  let x = -(rm.w / 2 + opts.level-gap)
  let xs = ()
  for (j, p) in pairs.enumerate() {
    x -= cols.at(j).map(c => c.right).fold(0pt, calc.max)
    xs.push(x)
    x -= cols.at(j).map(c => c.left).fold(0pt, calc.max) + opts.branch-gap
  }
  let x-end = x + opts.branch-gap
  // Spine from the tail to the head.
  _seg((x-end, 0pt), (-rm.w / 2, 0pt), _stroke(0, opts.ink-dark, opts), opts)
  for (j, p) in pairs.enumerate() {
    for (i, t) in p.enumerate() {
      let side = if i == 0 { 1 } else { -1 }
      let l = cols.at(j).at(i).len
      let sx = xs.at(j)
      let tip = (sx - l * calc.cos(lean), side * l * calc.sin(lean))
      if t.at("hidden", default: false) {
        // Room kept, nothing drawn.
        cetz.draw.rect((sx - cols.at(j).at(i).left, 0pt), (sx, tip.at(1) + side * t.h), stroke: none, fill: none)
        continue
      }
      _seg((sx, 0pt), tip, _stroke(0, t.color, opts), opts)
      // Leaves along the rib, a tick to the left of it.
      for (k, kid) in t.kids.enumerate() {
        let f = (k + 1) / (t.kids.len() + 1)
        let at = (sx - l * f * calc.cos(lean), side * l * f * calc.sin(lean))
        let end = (at.at(0) - tick, at.at(1))
        _seg(at, end, _stroke(kid.depth - 1, kid.color, opts), opts)
        _edge-label-beside(at, at, end, end, (0, side), kid.node.edge-label, opts, t: 0.5)
        _draw-node(kid, end.at(0) - kid.w / 2, end.at(1), opts)
      }
      _draw-node(t, tip.at(0), tip.at(1) + side * t.h / 2, opts)
    }
  }
}
