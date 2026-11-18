// Flowchart: connectable building blocks for pipeline, method and decision diagrams.
// Import with:  #import "flowchart.typ": flowchart, node, edge, group
//
//   #flowchart(
//     node("in", [Input]), node("model", [Model]), node("out", [Output], shape: "pill"),
//     edge("in", "model", "out"),
//   )
//
// Nodes without a (column, row) position are laid out automatically; give every
// node a position to place it on the grid yourself.
#import "common.typ": _arrow, _canvas, _card, _dot, _head, _lens, _loop, _on, _pair, _poly, _put, _shade, _theme

#let _shapes = ("rect", "pill", "circle", "ellipse", "diamond", "loop", none)
#let _routes-known = (auto, "straight", "hv", "vh", "hvh", "vhv", "detour")
#let _sides = (auto, left, right, top, bottom)

#let node(name, ..at-body, shape: "rect", fill: auto, stroke: auto, width: auto, height: auto, inset: auto,
  caption: none, shift: (0pt, 0pt)) = {
  let pos = at-body.pos()
  if not (at-body.named().len() == 0) { assert(false, message: "node: unexpected argument `" + at-body.named().keys().join("`, `") + "`") }
  if not (pos.len() in (1, 2)) { assert(false, message: "node: expected node(name, [(column, row)], body, ..), got " + repr(at-body)) }
  if not (shape in _shapes) { assert(false, message: "node: `shape` must be one of " + _shapes.map(repr).join(", ") + ", got " + repr(shape)) }
  (kind: "node", name: str(name), at: if pos.len() == 2 { pos.first() } else { auto }, body: pos.last(), shape: shape,
    fill: fill, stroke: stroke, width: width, height: height, inset: inset, caption: caption, shift: shift)
}

#let edge(..names, label: none, label-pos: auto, marks: "->", stroke: auto, dash: none, route: auto, exit: auto,
  enter: auto, bend: 0deg, via: ()) = {
  if not (names.named().len() == 0) { assert(false, message: "edge: unexpected argument `" + names.named().keys().join("`, `") + "`") }
  if not (names.pos().len() >= 2) { assert(false, message: "edge: expected at least two ends, edge(\"a\", \"b\", ..), got " + repr(names)) }
  if not (marks in ("->", "<-", "<->", "-")) { assert(false, message: "edge: `marks` must be \"->\", \"<-\", \"<->\" or \"-\", got "
    + repr(marks)) }
  if not (route in _routes-known) { assert(false, message: "edge: `route` must be one of " + _routes-known.map(repr).join(", ") + ", got "
    + repr(route)) }
  if exit not in _sides { assert(false, message: "edge: `exit` must be auto, left, right, top or bottom, got " + repr(exit)) }
  if enter not in _sides { assert(false, message: "edge: `enter` must be auto, left, right, top or bottom, got " + repr(enter)) }
  names.pos().map(str).windows(2).map(((a, b)) => (kind: "edge", from: a, to: b, label: label, label-pos: label-pos,
    marks: marks, stroke: stroke, dash: dash, route: route, exit: exit, enter: enter, bend: bend, via: via))
}

#let group(title, ..members, name: none, fill: none, stroke: auto, title-pos: top, inside: false, stretch: auto,
  join: none) = {
  if not (members.named().len() == 0) { assert(false, message: "group: unexpected argument `" + members.named().keys().join("`, `") + "`") }
  // whatever is written inside the frame is declared before it; its nodes and named
  // groups are members, an unnamed group lends its own members
  let (inner, names, pending) = ((), (), members.pos().rev())
  while pending.len() > 0 {
    let m = pending.pop()
    if type(m) == dictionary and "kind" in m {
      inner.push(m)
      if m.kind == "node" or m.kind == "group" and m.name != none { names.push(m.name) } else if m.kind == "group" {
        names += m.names
      }
    } else if type(m) == array and not m.all(v => type(v) in (int, float)) { pending += m.rev() } else if type(m) == array {
      names.push(m)
    } else { names.push(str(m)) }
  }
  (..inner, (kind: "group", title: title, names: names, name: if name != none { str(name) }, fill: fill, stroke: stroke,
    title-pos: title-pos, inside: inside, stretch: stretch, join: if join != none { str(join) }))
}

// (layer, slot) per node: longest-path layering by Kahn's topological sort, then each
// layer ordered by the barycenter of its predecessors and snapped to free integer
// slots, so chains run straight and branches fan out (Sugiyama-style heuristic).
#let _layout(n, edges) = {
  let preds = range(n).map(_ => ())
  let succs = range(n).map(_ => ())
  for (a, b) in edges {
    preds.at(b).push(a)
    succs.at(a).push(b)
  }
  let indeg = preds.map(p => p.len())
  let layer = (0,) * n
  let done = (false,) * n
  let queue = range(n).filter(v => indeg.at(v) == 0)
  let head = 0
  while head < queue.len() {
    let u = queue.at(head)
    head += 1
    done.at(u) = true
    for v in succs.at(u) {
      layer.at(v) = calc.max(layer.at(v), layer.at(u) + 1)
      indeg.at(v) -= 1
      if indeg.at(v) == 0 { queue.push(v) }
    }
  }
  // nodes on a cycle follow their already placed predecessors
  for v in range(n).filter(v => not done.at(v)) {
    layer.at(v) = calc.max(0, ..preds.at(v).filter(p => done.at(p)).map(p => layer.at(p) + 1))
    done.at(v) = true
  }
  let slot = (0,) * n
  let by-layer = range(calc.max(0, ..layer) + 1).map(_ => ())
  for v in range(n) { by-layer.at(layer.at(v)).push(v) }
  for (l, members) in by-layer.enumerate() {
    let want = members.enumerate().map(((k, v)) => {
      let ps = preds.at(v).filter(p => layer.at(p) < l)
      if ps.len() == 0 { k } else { ps.map(p => slot.at(p)).sum() / ps.len() }
    })
    let next = 0
    for (v, w) in members.zip(want).sorted(key: p => p.at(1)) {
      slot.at(v) = calc.max(next, int(calc.round(w)))
      next = slot.at(v) + 1
    }
  }
  range(n).map(v => (layer.at(v), slot.at(v)))
}

// Closed outlines of the union of rectangles (x0, y0, x1, y1): coordinate compression
// into cells, the edges between covered and empty cells, then chained into loops
// with collinear points dropped.
#let _outline(rects) = {
  let xs = rects.map(r => (r.at(0), r.at(2))).flatten().dedup().sorted()
  let ys = rects.map(r => (r.at(1), r.at(3))).flatten().dedup().sorted()
  let covered(i, j) = i >= 0 and j >= 0 and i < xs.len() - 1 and j < ys.len() - 1 and rects.any(r =>
    r.at(0) <= xs.at(i) and xs.at(i + 1) <= r.at(2) and r.at(1) <= ys.at(j) and ys.at(j + 1) <= r.at(3))
  // clockwise boundary edges, keyed by their start point
  let next = (:)
  for i in range(xs.len() - 1) {
    for j in range(ys.len() - 1).filter(j => covered(i, j)) {
      let (a, b, c, d) = ((xs.at(i), ys.at(j)), (xs.at(i + 1), ys.at(j)), (xs.at(i + 1), ys.at(j + 1)), (xs.at(i), ys.at(j + 1)))
      for (p, q, open) in ((a, b, not covered(i, j - 1)), (b, c, not covered(i + 1, j)), (c, d, not covered(i, j + 1)),
        (d, a, not covered(i - 1, j))) {
        if open { next.insert(repr(p), (p, q)) }
      }
    }
  }
  let loops = ()
  while next.len() > 0 {
    let (start, _) = next.values().first()
    let pts = ()
    let p = start
    while repr(p) in next {
      let (_, q) = next.remove(repr(p))
      pts.push(p)
      p = q
    }
    // keep corners only
    let n = pts.len()
    loops.push(range(n).filter(k => {
      let (o, c, d) = (pts.at(k - 1), pts.at(k), pts.at(calc.rem(k + 1, n)))
      not ((o.at(0) == c.at(0) and c.at(0) == d.at(0)) or (o.at(1) == c.at(1) and c.at(1) == d.at(1)))
    }).map(k => pts.at(k)))
  }
  loops
}

// unit vector from p to q, as floats
#let _unit(p, q) = {
  let (dx, dy) = ((q.at(0) - p.at(0)) / 1pt, (q.at(1) - p.at(1)) / 1pt)
  let len = calc.max(calc.norm(dx, dy), 1e-9)
  (dx / len, dy / len)
}

// Nodes, edges and groups from the children: every node's grid cell (given, or from the
// automatic layout with layers running along `dir`) and every group's member names.  An
// edge end without a node of its own becomes a node labelled with its name.
#let _resolve(parts, dir, group-stretch) = {
  if not (dir in (ltr, ttb)) { assert(false, message: "flowchart: `dir` must be ltr or ttb, got " + repr(dir)) }
  for c in parts {
    if not (type(c) == dictionary and "kind" in c) { assert(false, message: "flowchart: expected node(..), edge(..) or group(..), got "
      + repr(c)) }
  }
  let edges = parts.filter(c => c.kind == "edge")
  // a flowchart of arrows alone makes a box of every name; once it declares nodes, an
  // unknown name is a mistake
  let nodes = parts.filter(c => c.kind == "node")
  if nodes.len() == 0 {
    let groups = parts.filter(c => c.kind == "group" and c.name != none).map(c => c.name)
    nodes = edges.map(e => (e.from, e.to)).flatten().dedup().filter(name => name not in groups).map(name => node(name, [#name]))
  }
  assert(nodes.len() > 0, message: "flowchart: needs at least one node")
  let idx = (:)
  for (i, nd) in nodes.enumerate() {
    if not (nd.name not in idx) { assert(false, message: "flowchart: two nodes are named \"" + nd.name + "\"") }
    idx.insert(nd.name, i)
  }
  let auto-cells = if nodes.any(nd => nd.at == auto) {
    let links = edges.filter(e => e.from in idx and e.to in idx).map(e => (idx.at(e.from), idx.at(e.to)))
    _layout(nodes.len(), links).map(((l, k)) => if dir == ttb { (k, l) } else { (l, k) })
  }
  // a position is a (column, row) cell, a side of the node declared before (right, left,
  // above, below) or (side, name): the cell next to that node
  let step(side) = if side == right { (1, 0) } else if side == left { (-1, 0) } else if side == top { (0, -1) } else { (0, 1) }
  let sided(v) = type(v) == alignment and v in (left, right, top, bottom)
  let cells = nodes.enumerate().map(((i, nd)) => {
    let fixed = type(nd.at) == array and nd.at.len() == 2 and nd.at.all(v => type(v) in (int, float))
    if not (nd.at == auto or fixed or sided(nd.at) or type(nd.at) == array and nd.at.len() == 2 and sided(nd.at.at(0)) and (
      type(nd.at.at(1)) == str)) { assert(false, message: "flowchart: the position of node \"" + nd.name + "\" must be (column, row), "
      + "a side (right, left, above, below) or (side, \"name\"), got " + repr(nd.at)) }
    if nd.at == auto { auto-cells.at(i) } else if fixed { nd.at }
  })
  // each pass places the nodes whose reference is placed: one pass when nodes come after
  // what they refer to, as they read
  for _ in nodes {
    let placed = cells.filter(c => c != none).len()
    for (i, nd) in nodes.enumerate().filter(((i, _)) => cells.at(i) == none) {
      let (side, name) = if type(nd.at) == array { nd.at } else { (nd.at, if i > 0 { nodes.at(i - 1).name }) }
      if not (name != none and name in idx) { assert(false, message: "flowchart: node \"" + nd.name + "\" is placed next to " + (if name == none {
        "the node before it, but it is the first"
      } else { "\"" + name + "\", which is not a node" })) }
      let base = cells.at(idx.at(name))
      if base != none { cells.at(i) = base.zip(step(side)).map(((at, by)) => at + by) }
    }
    if cells.filter(c => c != none).len() == placed { break }
  }
  let lost = nodes.zip(cells).filter(((_, c)) => c == none).map(((nd, _)) => nd.name)
  if not (lost.len() == 0) { assert(false, message: "flowchart: the positions of " + lost.map(name => "\"" + name + "\"").join(", ")
    + " refer to each other in a circle") }

  // a group given by corners takes the nodes inside them, and the earlier named groups
  // whose nodes all lie there
  let groups = ()
  let group-nodes = (:)
  for g in parts.filter(c => c.kind == "group") {
    let corners = g.names.filter(nm => type(nm) == array)
    let names = g.names.filter(nm => type(nm) == str)
    if corners.len() > 0 {
      let (cs, rs) = (corners.map(p => p.at(0)), corners.map(p => p.at(1)))
      let inside = nodes.zip(cells).filter(((_, (c, r))) => c >= calc.min(..cs) and c <= calc.max(..cs) and (
        r >= calc.min(..rs)) and r <= calc.max(..rs)).map(((nd, _)) => nd.name)
      if not (inside.len() > 0) { assert(false, message: "flowchart: no node inside the group corners " + repr(corners)) }
      names += inside + group-nodes.keys().filter(nm => group-nodes.at(nm).all(n => n in inside))
    }
    if g.name != none {
      group-nodes.insert(g.name, names.map(nm => group-nodes.at(nm, default: (nm,))).flatten())
    }
    groups.push((..g, names: names.dedup(), stretch: if g.stretch == auto { group-stretch } else { g.stretch }))
  }
  (nodes: nodes, edges: edges, groups: groups, cells: cells)
}

// One measure per node: content, shape, then the footprint with its caption below.
#let _measure(nodes, inset, caption-style, em) = nodes.map(nd => {
  let pad = if nd.inset == auto { inset } else { _lens("node", inset: nd.inset).inset }
  let min-h = if nd.height == auto { 0pt } else { _lens("node", height: nd.height).height }
  let cw = if nd.width != auto { _lens("node", width: nd.width).width - 2 * pad }
  let m = if cw == none { measure(nd.body) } else { measure(nd.body, width: cw) }
  let cw = if cw == none { m.width } else { cw }
  let (bw, bh) = (cw + 2 * pad, calc.max(m.height + 2 * pad, min-h))
  let (sw, sh) = if nd.shape == "circle" {
    let d = calc.norm(bw / 1pt, bh / 1pt) * 1pt
    (d, d)
  } else if nd.shape == "diamond" { (2 * bw, 2 * bh) } else if nd.shape in ("ellipse", "loop") {
    (bw * calc.sqrt(2), bh * calc.sqrt(2))
  } else { (bw, bh) }
  let caption = if nd.caption != none { text(..caption-style, nd.caption) }
  let cm = if caption == none { (width: 0pt, height: 0pt) } else { measure(caption) }
  // a caption hangs under the shape and keeps clear of edges leaving below: half this
  // gap on each side
  let gap = if caption == none { 0pt } else { 0.72 * em }
  // edges clip to the footprint: the shape itself, or a box around shape and caption
  (w: calc.max(sw, cm.width), h: sh + gap + cm.height, sw: sw, sh: sh, cw: cw, kind: nd.shape, caption: caption,
    caption-gap: gap, shape: if caption == none { nd.shape } else { "rect" })
})

// A fractional grid coordinate, interpolated (or extrapolated) between track centres.
#let _along(v, cs, pitch) = if cs.len() == 1 { cs.first() + v * pitch } else {
  let k = calc.min(calc.max(int(calc.floor(v)), 0), cs.len() - 2)
  cs.at(k) + (v - k) * (cs.at(k + 1) - cs.at(k))
}

// The function from a (column, row) cell, fractional allowed, to its point; rows come from
// the cell's lane: the last one starting at or before its column.  Stages take the grid
// once and call the closure per cell: Typst hashes the arguments of every call, so a
// function called per node or edge must not be passed the whole diagram.
#let _grid-point(grid) = ((c, r)) => {
  let lane = grid.lanes.filter(l => l.a <= calc.floor(c - grid.c0)).at(-1, default: grid.lanes.first())
  (_along(c - grid.c0, grid.cxs, grid.pitch-x), _along(r - grid.r0, lane.cys, lane.row-h.first() + grid.gy))
}

// Track sizes and positions: columns and rows as wide as their nodes, gaps wide enough
// for the group frames and arrows crossing them.  Returns the grid and each node's geometry.
#let _place(nodes, cells, sizes, groups, titles, edges, gx, gy, group-inset, independent-columns, em) = {
  // the tracks a node covers: one for an integer position, both neighbours for a fraction
  let tracks = cells.map(((c, r)) => (int(calc.floor(c)), int(calc.ceil(c)), int(calc.floor(r)), int(calc.ceil(r))))
  let (c0, r0) = (calc.min(..tracks.map(t => t.at(0))), calc.min(..tracks.map(t => t.at(2))))
  let (nc, nr) = (calc.max(..tracks.map(t => t.at(1))) - c0 + 1, calc.max(..tracks.map(t => t.at(3))) - r0 + 1)
  // sizes of n tracks from the nodes `ids`; lo/hi index their first/last track.  As in CSS
  // grid: single-track nodes take the largest size per track, then a node spanning tracks
  // spreads whatever it still lacks over them
  let size-tracks(n, ids, lo, hi, origin, key, gap) = {
    let out = (0pt,) * n
    for pass in (1, 2) {
      for i in ids {
        let (a, b) = (tracks.at(i).at(lo) - origin, tracks.at(i).at(hi) - origin)
        if (a == b) != (pass == 1) { continue }
        let need = sizes.at(i).at(key)
        let have = out.slice(a, b + 1).sum() + gap * (b - a)
        if a == b { out.at(a) = calc.max(have, need) } else if need > have {
          for k in range(a, b + 1) { out.at(k) += (need - have) / (b - a + 1) }
        }
      }
    }
    out
  }
  let col-w = size-tracks(nc, range(nodes.len()), 0, 1, c0, "w", gx)
  // groups as sets of nodes (a group may contain earlier groups) with the room their
  // frame and title take beyond those nodes, so the gaps between tracks can fit them
  let members = (:)
  for (i, nd) in nodes.enumerate() { members.insert(nd.name, (i,)) }
  let rooms = (:)
  let items = tracks.zip(nodes).map((((ca, cb, ra, rb), nd)) => (c0: ca - c0, c1: cb - c0, r0: ra - r0,
    r1: rb - r0, top: 0pt, bottom: 0pt, side: 0pt, name: nd.name))
  for (g, title) in groups.zip(titles) {
    let ids = g.names.map(nm => {
      if not (nm in members) { assert(false, message: "flowchart: no node or group named \"" + nm + "\"") }
      members.at(nm)
    }).flatten().dedup()
    let th = if title == none { 0pt } else { measure(title).height }
    let head = if title == none { 0pt } else if g.inside { th + 0.55 * em } else { th / 2 + 0.27 * em }
    let inner = g.names.filter(nm => nm in rooms).map(nm => rooms.at(nm))
    let ext(key) = group-inset + calc.max(0pt, ..inner.map(e => e.at(key)))
    let room = (top: ext("top") + (if g.title-pos == top { head } else { 0pt }),
      bottom: ext("bottom") + (if g.title-pos == bottom { head } else { 0pt }), side: ext("side"))
    if g.name != none {
      members.insert(g.name, ids)
      rooms.insert(g.name, room)
    }
    items.push((c0: calc.min(..ids.map(i => items.at(i).c0)), c1: calc.max(..ids.map(i => items.at(i).c1)),
      r0: calc.min(..ids.map(i => items.at(i).r0)), r1: calc.max(..ids.map(i => items.at(i).r1)), ..room,
      name: g.name))
  }
  // a gap grows until whatever faces each other across it fits, frames included, plus
  // room for an arrow when an edge joins the two sides.  Two items face each other when
  // they share a cross track (there are `m` of them), so each gap keeps the widest room
  // ahead per cross track.  `keep` narrows the items and the edges to one lane.
  let named = (:)
  for it in items { if it.name != none { named.insert(it.name, it) } }
  let framed = groups.len() > 0
  let gaps(items, n, m, gap, last, first, lo, hi, before, after, keep) = {
    let out = (gap,) * (n - 1)
    // bare nodes need no room beyond the gap itself: without frames, and with a gap that
    // already clears them, only the arrows below can widen it
    if framed or gap < 0.55 * em {
      let ahead = range(n).map(_ => (none,) * m)
      for b in items {
        let k = b.at(first) - 1
        if k < 0 { continue }
        for c in range(b.at(lo), b.at(hi) + 1) {
          let room = ahead.at(k).at(c)
          if room == none or room < b.at(after) { ahead.at(k).at(c) = b.at(after) }
        }
      }
      for a in items {
        let k = a.at(last)
        if k >= n - 1 { continue }
        for c in range(a.at(lo), a.at(hi) + 1) {
          let room = ahead.at(k).at(c)
          if room != none { out.at(k) = calc.max(out.at(k), a.at(before) + room + 0.55 * em) }
        }
      }
    }
    for e in edges {
      let (from, to) = (named.at(e.from, default: none), named.at(e.to, default: none))
      if from == none or to == none or keep != none and not (keep(from) and keep(to)) { continue }
      for (a, b) in ((from, to), (to, from)) {
        if a.at(last) + 1 == b.at(first) and b.at(lo) <= a.at(hi) and a.at(lo) <= b.at(hi) {
          out.at(a.at(last)) = calc.max(out.at(a.at(last)), a.at(before) + b.at(after) + 2.85 * em)
        }
      }
    }
    out
  }
  let starts(tracks, gaps) = {
    let (acc, out) = (0pt, ())
    for (k, t) in tracks.enumerate() {
      out.push(acc)
      acc += t + gaps.at(k, default: 0pt)
    }
    out
  }
  let xs = starts(col-w, gaps(items, nc, nr, gx, "c1", "c0", "r0", "r1", "side", "side", none))
  // lanes: blocks of columns joined by nodes that span them (interval merging).  With
  // independent-columns every lane sizes and spaces its own rows; else one lane has all.
  let spans = tracks.map(t => (t.at(0) - c0, t.at(1) - c0)).sorted()
  let bounds = if independent-columns {
    let merged = ()
    for (a, b) in spans {
      if merged.len() > 0 and a <= merged.at(-1).at(1) { merged.at(-1).at(1) = calc.max(merged.at(-1).at(1), b) } else {
        merged.push((a, b))
      }
    }
    merged
  } else { ((0, nc - 1),) }
  let lanes = bounds.map(((a, b)) => {
    // the one lane of a plain grid holds everything: nothing to pick out
    let whole = bounds.len() == 1
    let inside = it => it.c0 <= b and it.c1 >= a
    let ids = if whole { range(nodes.len()) } else { range(nodes.len()).filter(i => inside(items.at(i))) }
    let row-h = size-tracks(nr, ids, 2, 3, r0, "h", gy)
    let ys = starts(row-h, gaps(if whole { items } else { items.filter(inside) }, nr, nc, gy, "r1", "r0", "c0", "c1",
      "bottom", "top", if not whole { inside }))
    (a: a, b: b, row-h: row-h, ys: ys, cys: range(nr).map(i => ys.at(i) + row-h.at(i) / 2))
  })
  let grid = (c0: c0, r0: r0, cxs: range(nc).map(i => xs.at(i) + col-w.at(i) / 2), lanes: lanes,
    pitch-x: col-w.first() + gx, gy: gy, width: xs.last() + col-w.last(),
    height: calc.max(..lanes.map(l => l.ys.last() + l.row-h.last())))
  let point = _grid-point(grid)
  // a whole cell of a single lane is read straight off the track centres
  let (cxs, cys) = (grid.cxs, if lanes.len() == 1 { lanes.first().cys })
  let geo = cells.zip(sizes, nodes).map(((cell, sz, nd)) => {
    let (c, r) = cell
    let on-grid = type(c) == int and type(r) == int
    let (x, y) = if on-grid and cys != none { (cxs.at(c - c0), cys.at(r - r0)) } else { point(cell) }
    let moved = nd.shift != (0pt, 0pt)
    if moved {
      let (dx, dy) = _pair("node", "shift", nd.shift)
      (x, y) = (x + dx, y + dy)
    }
    // a/b: half footprint; sa/sb/sy: half size and centre of the shape above its caption;
    // cell: its place on the grid when it sits squarely on one
    (x: x, y: y, a: sz.w / 2, b: sz.h / 2, sa: sz.sw / 2, sb: sz.sh / 2, sy: y - sz.h / 2 + sz.sh / 2,
      cell: if on-grid and not moved { cell }, ..sz)
  })
  (grid: grid, geo: geo)
}

// Group frames, in declaration order, and the edge ends: nodes, then the named frames
// (a group may enclose earlier groups).
#let _frames(nodes, geo, groups, titles, group-inset, em) = {
  let anchors = (:)
  for (nd, g) in nodes.zip(geo) { anchors.insert(nd.name, g) }
  let frames = ()
  for (g, title) in groups.zip(titles) {
    let ms = g.names.map(nm => anchors.at(nm))
    let (width: tw, height: th) = if title == none { (width: 0pt, height: 0pt) } else { measure(title) }
    let room = if g.inside and title != none { th + 0.55 * em } else { 0pt }
    let (x0, x1) = (calc.min(..ms.map(m => m.x - m.a)) - group-inset, calc.max(..ms.map(m => m.x + m.a)) + group-inset)
    // a title inside the frame widens it when needed
    let widen = if g.inside { calc.max(0pt, tw + 2 * group-inset - (x1 - x0)) / 2 } else { 0pt }
    let f = (..g, title: title, th: th, x0: x0 - widen, x1: x1 + widen,
      y0: calc.min(..ms.map(m => m.y - m.b)) - group-inset - (if g.title-pos == top { room } else { 0pt }),
      y1: calc.max(..ms.map(m => m.y + m.b)) + group-inset + (if g.title-pos == bottom { room } else { 0pt }))
    // stretched edges stop at the nearest frame or node ahead of the frame's content
    // (frames declared earlier stretch first), else at the outer edge of the diagram;
    // nodes keep group-inset clear
    let sides = if g.stretch == none { () } else if type(g.stretch) == array { g.stretch } else if g.stretch.axis() == none {
      (g.stretch.x, g.stretch.y)
    } else { (g.stretch,) }
    if sides.len() > 0 {
      let boxes = frames.map(o => (o.x0, o.y0, o.x1, o.y1, 0pt)) + geo.map(m => (m.x - m.a, m.y - m.b, m.x + m.a,
        m.y + m.b, group-inset))
      let outer(k, pick, sign) = pick(..boxes.map(b => b.at(k) + sign * b.at(4)))
      let across-x = b => b.at(0) < f.x1 and b.at(2) > f.x0
      let across-y = b => b.at(1) < f.y1 and b.at(3) > f.y0
      for side in sides {
        if side == bottom {
          f.y1 = calc.min(outer(3, calc.max, 1), ..boxes.filter(b => across-x(b) and b.at(1) >= f.y1 - group-inset - 0.5pt).map(b => b.at(1) - b.at(4)))
        } else if side == top {
          f.y0 = calc.max(outer(1, calc.min, -1), ..boxes.filter(b => across-x(b) and b.at(3) <= f.y0 + group-inset + 0.5pt).map(b => b.at(3) + b.at(4)))
        } else if side == right {
          f.x1 = calc.min(outer(2, calc.max, 1), ..boxes.filter(b => across-y(b) and b.at(0) >= f.x1 - group-inset - 0.5pt).map(b => b.at(0) - b.at(4)))
        } else if side == left {
          f.x0 = calc.max(outer(0, calc.min, -1), ..boxes.filter(b => across-y(b) and b.at(2) <= f.x0 + group-inset + 0.5pt).map(b => b.at(2) + b.at(4)))
        }
      }
    }
    frames.push(f)
    if g.name != none {
      let (x, y, a, b) = ((f.x0 + f.x1) / 2, (f.y0 + f.y1) / 2, (f.x1 - f.x0) / 2, (f.y1 - f.y0) / 2)
      anchors.insert(g.name, (x: x, y: y, a: a, b: b, sa: a, sb: b, sy: y, shape: "rect"))
    }
  }
  (frames: frames, anchors: anchors)
}

// The border point of g in the direction of p.
#let _exit(g, p) = {
  let (ux, uy) = _unit((g.x, g.y), p)
  // distance from the centre to the border along the unit direction (ux, uy)
  let d = if g.shape == "circle" { g.a } else if g.shape == "diamond" {
    1pt / (calc.abs(ux) / (g.a / 1pt) + calc.abs(uy) / (g.b / 1pt))
  } else if g.shape in ("ellipse", "loop") {
    1pt / calc.norm(ux / (g.a / 1pt), uy / (g.b / 1pt))
  } else {
    calc.min(if calc.abs(ux) > 1e-9 { g.a / calc.abs(ux) } else { 1e6pt },
      if calc.abs(uy) > 1e-9 { g.b / calc.abs(uy) } else { 1e6pt })
  }
  (g.x + ux * d, g.y + uy * d)
}
// horizontal edges meet the shape at mid height; vertical ones meet the footprint
// (shape plus caption) at mid width
#let _side(g, k) = (g.x + k * g.sa, g.sy)
#let _end(g, k) = (g.x, g.y + k * g.b)
// an end waypoint p slides along the leg it shares with its neighbour q until it
// lines up with the middle of node g, so the edge meets g straight
#let _snap(g, p, q) = {
  let (px, py) = p
  if calc.abs(q.at(0) - px) < 0.5pt and calc.abs(px - g.x) > g.sa { (px, g.sy) } else if (
    calc.abs(q.at(1) - py) < 0.5pt and calc.abs(py - g.y) > g.b
  ) { (g.x, py) } else { p }
}
// where an edge from waypoint p meets g: a side when p faces it, else top or bottom
#let _attach(g, p) = {
  let (px, py) = p
  // from above an edge must meet the shape itself; from below, the caption under it
  let half = if py < g.y { g.sa } else { g.a }
  if calc.abs(px - g.x) > g.sa and py >= g.sy - g.sb and py <= g.sy + g.sb {
    (g.x + (if px > g.x { g.sa } else { -g.sa }), py)
  } else if calc.abs(px - g.x) <= half { (px, g.y + (if py > g.y { g.b } else { -g.b })) } else { _exit(g, p) }
}

// The function from a value to the nodes whose `key` lies within 0.5pt of it, found
// through buckets of one point instead of a scan.
#let _near(geo, key) = {
  let buckets = (:)
  for g in geo {
    let k = str(int(calc.floor(g.at(key) / 1pt)))
    buckets.insert(k, buckets.at(k, default: ()) + (g,))
  }
  // the nodes of the (one or two) buckets around v: a superset, which callers test exactly
  v => {
    let (a, b) = (str(int(calc.floor((v - 0.5pt) / 1pt))), str(int(calc.floor((v + 0.5pt) / 1pt))))
    buckets.at(a, default: ()) + if a != b { buckets.at(b, default: ()) }
  }
}

// `pts` without repeated points or points lying on the straight way between their neighbours.
#let _tidy(pts) = {
  let out = (pts.first(),)
  for p in pts.slice(1) {
    let o = out.last()
    if calc.abs(p.at(0) - o.at(0)) < 0.01pt and calc.abs(p.at(1) - o.at(1)) < 0.01pt { continue }
    if out.len() > 1 {
      let ((ux, uy), (vx, vy)) = (_unit(out.at(-2), o), _unit(o, p))
      if ux * vx + uy * vy > 0.9999 { let _ = out.pop() }
    }
    out.push(p)
  }
  out
}

// The path of every edge between its two anchors, then the port assignment.  A path is
// (kind, pts): a "line" through its points, or the control points of a "quad" or "loop" curve.
#let _routes(edges, anchors, geo, grid, dir, gx, gy, em, searching) = {
  let point = _grid-point(grid)
  let (in-row, in-col) = (_near(geo, "y"), _near(geo, "x"))
  // when every node sits squarely on a cell, nothing lies between two neighbouring cells
  let squared = geo.all(g => g.cell != none)
  let apart(s, t, k) = if squared { let (a, b) = (s.at("cell", default: none), t.at("cell", default: none))
    if a != none and b != none { calc.abs(a.at(k) - b.at(k)) } }
  let succ = (:)
  for e in edges { succ.insert(e.from, succ.at(e.from, default: ()) + (e.to,)) }
  // the middle of a side of g and the unit vector pointing out of it
  let port(g, side) = if side == left { (_side(g, -1), (-1, 0)) } else if side == right { (_side(g, 1), (1, 0)) } else if (
    side == top
  ) { ((g.x, g.sy - g.sb), (0, -1)) } else { (_end(g, 1), (0, 1)) }
  // the side of g that faces the centre of o
  let facing(g, o) = if calc.abs(o.x - g.x) >= calc.abs(o.y - g.y) { if o.x > g.x { right } else { left } } else if (
    o.y > g.y
  ) { bottom } else { top }
  // the usual path of edge e and, with `more`, the other shapes it could take instead
  // (none for an edge with a route of its own)
  let ways(e, more) = {
    for name in (e.from, e.to) {
      if not (name in anchors) { assert(false, message: "flowchart: no node or group named \"" + name + "\"") }
    }
    let (s, t) = (anchors.at(e.from), anchors.at(e.to))
    if e.from == e.to {
      // a loop leaves and re-enters one side: the top unless `exit` names another
      let ((cx, cy), (nx, ny)) = port(s, if e.exit == auto { top } else { e.exit })
      let (tx, ty) = (-ny, nx)
      let d = calc.min(0.9 * em, (if nx == 0 { s.sa } else { s.sb }) * 0.6)
      let (p, q) = (_exit(s, (cx - tx * d, cy - ty * d)), _exit(s, (cx + tx * d, cy + ty * d)))
      let reach(o, k) = (o.at(0) + (nx * 3.2 + k * tx * 2) * d, o.at(1) + (ny * 3.2 + k * ty * 2) * d)
      return ((kind: "loop", pts: (p, reach(p, -1), reach(q, 1), q)),)
    }
    if e.via.len() > 0 {
      let pts = e.via.map(point)
      if pts.len() > 1 {
        pts.at(0) = _snap(s, pts.at(0), pts.at(1))
        pts.at(-1) = _snap(t, pts.at(-1), pts.at(-2))
      }
      return ((kind: "line", pts: (_attach(s, pts.first()), ..pts, _attach(t, pts.last()))),)
    }
    if e.bend != 0deg {
      let k = calc.tan(e.bend) / 2
      let c = ((s.x + t.x) / 2 + (t.y - s.y) * k, (s.y + t.y) / 2 - (t.x - s.x) * k)
      return ((kind: "quad", pts: (_exit(s, c), c, _exit(t, c))),)
    }
    if e.exit != auto or e.enter != auto {
      // leave and arrive square to the chosen sides, joined by one elbow
      let ((p0, (ax, ay)), (p1, (bx, by))) = (port(s, if e.exit == auto { facing(s, t) } else { e.exit }),
        port(t, if e.enter == auto { facing(t, s) } else { e.enter }))
      let stub = calc.min(gx, gy) / 2
      let (a, b) = ((p0.at(0) + ax * stub, p0.at(1) + ay * stub), (p1.at(0) + bx * stub, p1.at(1) + by * stub))
      // the same side at both ends goes around the farther stub; else one elbow joins them
      let far(k, sign) = if sign > 0 { calc.max(a.at(k), b.at(k)) } else { calc.min(a.at(k), b.at(k)) }
      let turn = if (ax, ay) != (bx, by) { (if ay == 0 { (b.at(0), a.at(1)) } else { (a.at(0), b.at(1)) },) } else if (
        ay == 0
      ) { ((far(0, ax), a.at(1)), (far(0, ax), b.at(1))) } else { ((a.at(0), far(1, ay)), (b.at(0), far(1, ay))) }
      return ((kind: "line", pts: _tidy((p0, a, ..turn, b, p1))),)
    }
    let (dx, dy) = (t.x - s.x, t.y - s.y)
    let (hx, hy) = (if dx < 0pt { -1 } else { 1 }, if dy < 0pt { -1 } else { 1 })
    let (same-row, same-col) = (calc.abs(t.sy - s.sy) < 0.5pt, calc.abs(dx) < 0.5pt)
    // overlapping spans allow a straight edge even between different rows (or columns)
    let (lo-y, hi-y) = (calc.max(s.sy - s.sb, t.sy - t.sb), calc.min(s.sy + s.sb, t.sy + t.sb))
    let (lo-x, hi-x) = (calc.max(s.x - s.a, t.x - t.a), calc.min(s.x + s.a, t.x + t.a))
    let side-by-side = hi-y - lo-y > 0.72 * em and calc.abs(dx) > s.a + t.a
    let stacked = hi-x - lo-x > 0.72 * em and calc.abs(dy) > s.b + t.b
    // a straight edge must not run through another node or on top of its reverse edge
    let backwards = (same-row or same-col) and e.from in succ.at(e.to, default: ()) and (
      if dir == ttb { dy < 0pt or dx < 0pt } else { dx < 0pt or dy < 0pt })
    // only nodes between the facing borders block (a group's own nodes do not); the
    // candidates are the nodes of that one row or column
    let blocked = if same-row and apart(s, t, 0) == 1 or same-col and apart(s, t, 1) == 1 { false } else if same-row {
      in-row(s.y).any(g => calc.abs(g.y - s.y) < 0.5pt and (g.x - s.x - hx * s.sa) * hx > 0pt and (
        t.x - hx * t.sa - g.x) * hx > 0pt)
    } else if same-col {
      in-col(s.x).any(g => calc.abs(g.x - s.x) < 0.5pt and (g.y - s.y - hy * s.b) * hy > 0pt and (
        t.y - hy * t.b - g.y) * hy > 0pt)
    } else { false }
    let route = if e.route != auto { e.route } else if backwards or blocked { "detour" } else if same-row or same-col {
      "straight"
    } else if side-by-side { "across" } else if stacked { "down" } else if dir == ttb { "vhv" } else { "hvh" }
    // most edges are straight: they leave before any elbow is prepared
    if route == "straight" and (same-row or same-col) {
      return ((kind: "line", pts: if same-row { (_side(s, hx), _side(t, -hx)) } else { (_end(s, hy), _end(t, -hy)) }),)
    }
    // the line goes through the centre of the smaller end when it can
    let pick(lo, hi, u, v, small-first) = {
      let (p, q) = if small-first { (u, v) } else { (v, u) }
      if p >= lo and p <= hi { p } else if q >= lo and q <= hi { q } else { (lo + hi) / 2 }
    }
    // elbows: `lean` is how far along the gap the middle leg sits (0.5: half way)
    let (x0, x1, y0, y1) = (s.x + hx * s.sa, t.x - hx * t.sa, s.y + hy * s.b, t.y - hy * t.b)
    let hvh(lean) = ((x0, s.sy), (x0 + (x1 - x0) * lean, s.sy), (x0 + (x1 - x0) * lean, t.sy), (x1, t.sy))
    let vhv(lean) = ((s.x, y0), (s.x, y0 + (y1 - y0) * lean), (t.x, y0 + (y1 - y0) * lean), (t.x, y1))
    let hv() = (_side(s, hx), (t.x, s.sy), _end(t, -hy))
    let vh() = (_end(s, hy), (s.x, t.sy), _side(t, -hx))
    // detours pass beside the row or column, clear of every node on the way; k picks the side
    let around(k) = if dir == ttb {
      let (lo, hi, far) = (calc.min(s.y, t.y), calc.max(s.y, t.y), calc.max(s.x, t.x) + 0.5pt)
      let passed = geo.filter(g => g.y >= lo and g.y <= hi)
      let k = if k != auto { k } else if passed.any(g => g.x > far) { -1 } else { 1 }
      let xd = if k > 0 { calc.max(s.x + s.a, t.x + t.a, ..passed.map(g => g.x + g.a)) + gx / 2 } else {
        calc.min(s.x - s.a, t.x - t.a, ..passed.map(g => g.x - g.a)) - gx / 2
      }
      (_side(s, k), (xd, s.sy), (xd, t.sy), _side(t, k))
    } else {
      let (lo, hi, far) = (calc.min(s.x, t.x), calc.max(s.x, t.x), calc.max(s.y, t.y) + 0.5pt)
      let passed = geo.filter(g => g.x >= lo and g.x <= hi)
      let k = if k != auto { k } else if passed.any(g => g.y > far) { -1 } else { 1 }
      let yd = if k > 0 { calc.max(s.y + s.b, t.y + t.b, ..passed.map(g => g.y + g.b)) + gy / 2 } else {
        calc.min(s.y - s.b, t.y - t.b, ..passed.map(g => g.y - g.b)) - gy / 2
      }
      (_end(s, k), (s.x, yd), (t.x, yd), _end(t, k))
    }
    let usual = if route == "straight" and same-row {
      (_side(s, hx), _side(t, -hx))
    } else if route == "straight" and same-col {
      (_end(s, hy), _end(t, -hy))
    } else if route == "straight" {
      (_exit(s, (t.x, t.y)), _exit(t, (s.x, s.y)))
    } else if route == "across" {
      let y = pick(lo-y, hi-y, s.sy, t.sy, s.sb <= t.sb)
      ((s.x + hx * s.sa, y), (t.x - hx * t.sa, y))
    } else if route == "down" {
      let x = pick(lo-x, hi-x, s.x, t.x, s.a <= t.a)
      ((x, s.y + hy * s.b), (x, t.y - hy * t.b))
    } else if route == "hv" { hv() } else if route == "vh" { vh() } else if route == "hvh" { hvh(0.5) } else if route == "vhv" {
      vhv(0.5)
    } else if route == "detour" { around(auto) } else { panic("flowchart: unknown route \"" + route + "\"") }
    // an automatic elbow or detour has other shapes to fall back on when it gets in the way
    if not more { return ((kind: "line", pts: usual, choice: e.route == auto and route in ("detour", "hvh", "vhv")),) }
    let others = if e.route != auto { () } else if route == "detour" { (around(1), around(-1)) } else if route in ("hvh", "vhv") {
      let near = calc.min(0.5, gx / 2 / calc.max(calc.abs(x1 - x0), 1pt))
      let close = calc.min(0.5, gy / 2 / calc.max(calc.abs(y1 - y0), 1pt))
      (hvh(0.5), vhv(0.5), hv(), vh(), hvh(1 - near), vhv(1 - close))
    } else { () }
    (usual, ..others.filter(pts => pts != usual)).map(pts => (kind: "line", pts: pts))
  }

  // Edges take their paths in order.  With `searching` (the flowchart's avoid-crossings),
  // one whose usual path runs through a node, crosses a path already laid or lies on one
  // tries its other shapes and keeps the least bad; each try scans the nodes near the edge
  // and the legs laid so far, which is why it is the caller's choice.
  let paths = ()
  // the straight legs of a path: (horizontal, level, lo, hi)
  let legs(pts) = pts.windows(2).map(((p, q)) => if calc.abs(p.at(1) - q.at(1)) < 0.5pt {
    (true, p.at(1), calc.min(p.at(0), q.at(0)), calc.max(p.at(0), q.at(0)))
  } else if calc.abs(p.at(0) - q.at(0)) < 0.5pt {
    (false, p.at(0), calc.min(p.at(1), q.at(1)), calc.max(p.at(1), q.at(1)))
  }).filter(leg => leg != none)
  // the legs laid so far, horizontal and vertical apart, in stripes of their level: a new
  // leg is only compared with the legs of the stripes it runs through or lies in
  let stripe = calc.max(gx, gy, 1pt)
  let band(v) = int(calc.floor(v / stripe))
  let (flats, steeps) = ((:), (:))
  // every node as the rectangle a leg must stay out of
  let rects = geo.map(g => (g.x - g.a + 1pt, g.y - g.b + 1pt, g.x + g.a - 1pt, g.y + g.b - 1pt))
  // how much `path` is in the way: of the nodes `near` it, and of the legs laid before
  let cost(e, path, near, flats, steeps) = {
    let (hits, clashes) = (0, 0)
    for (flat, level, lo, hi) in legs(path.pts) {
      hits += near.filter(((l, t, r, b)) => if flat { level > t and level < b and hi > l and lo < r } else {
        level > l and level < r and hi > t and lo < b
      }).len()
      let (across, along) = if flat { (steeps, flats) } else { (flats, steeps) }
      // crossings: legs of the other direction in the stripes this leg runs through
      for k in range(band(lo), band(hi) + 1) {
        clashes += 40 * across.at(str(k), default: ()).filter(((at, from, to, ..)) => at > lo + 0.5pt and at < hi - 0.5pt and (
          level > from + 0.5pt) and level < to - 0.5pt).len()
      }
      // two edges on one line that do not start or end together
      for k in (band(level - 0.5pt), band(level + 0.5pt)).dedup() {
        clashes += 25 * along.at(str(k), default: ()).filter(((at, from, to, a, b)) => calc.abs(level - at) < 0.5pt and (
          calc.min(hi, to) - calc.max(lo, from) > 1pt) and e.from != a and e.to != b).len()
      }
    }
    1000 * hits + clashes + 3 * path.pts.len()
  }
  for e in edges {
    let best = ways(e, false).first()
    if searching and best.at("choice", default: false) {
      // every shape of this edge stays within a gap of its two ends, so the nodes that can
      // be in its way are found once
      let (s, t) = (anchors.at(e.from), anchors.at(e.to))
      let (x0, x1) = (calc.min(s.x - s.a, t.x - t.a) - gx, calc.max(s.x + s.a, t.x + t.a) + gx)
      let (y0, y1) = (calc.min(s.y - s.b, t.y - t.b) - gy, calc.max(s.y + s.b, t.y + t.b) + gy)
      let ends = ((s.x - s.a + 1pt, s.y - s.b + 1pt), (t.x - t.a + 1pt, t.y - t.b + 1pt))
      let near = rects.filter(((l, t, r, b)) => r > x0 and l < x1 and b > y0 and t < y1 and (l, t) not in ends)
      let least = cost(e, best, near, flats, steeps)
      // only a path that is in the way is worth replacing
      if least > 3 * best.pts.len() {
        for option in ways(e, true).slice(1) {
          let c = cost(e, option, near, flats, steeps)
          if c < least { (best, least) = (option, c) }
        }
      }
    }
    paths.push(best)
    if searching and best.kind == "line" {
      for (flat, level, lo, hi) in legs(best.pts) {
        let key = str(band(level))
        if flat { flats.insert(key, flats.at(key, default: ()) + ((level, lo, hi, e.from, e.to),)) } else {
          steeps.insert(key, steeps.at(key, default: ()) + ((level, lo, hi, e.from, e.to),))
        }
      }
    }
  }

  // port assignment: elbow edges arriving on the same side of a node each get a slot
  // along that side, ordered so their last legs do not cross; only that leg moves
  let ports = (:)
  for (i, (e, path)) in edges.zip(paths).enumerate() {
    if path.kind != "line" or path.pts.len() < 3 { continue }
    let ((px, py), (qx, qy)) = path.pts.slice(-2)
    let side = if calc.abs(py - qy) < 0.5pt { if px < qx { "left" } else { "right" } } else if calc.abs(px - qx) < 0.5pt {
      if py < qy { "top" } else { "bottom" }
    } else { continue }
    ports.insert(e.to + "|" + side, ports.at(e.to + "|" + side, default: ()) + (i,))
  }
  for (key, ids) in ports.pairs().filter(((_, ids)) => ids.len() > 1) {
    let across = key.ends-with("left") or key.ends-with("right")
    let g = anchors.at(key.split("|").first())
    let step = calc.min(1.3 * em, 1.6 * (if across { g.sb } else { g.sa }) / ids.len())
    // a leg from farther away takes the slot nearer the side it comes from
    let order = ids.sorted(key: i => {
      let (a, b, c) = paths.at(i).pts.slice(-3)
      let (k, d) = if across { (1, calc.abs(c.at(0) - b.at(0))) } else { (0, calc.abs(c.at(1) - b.at(1))) }
      if a.at(k) > b.at(k) { -d / 1pt } else { d / 1pt }
    })
    let k = if across { 1 } else { 0 }
    for (j, i) in order.enumerate() {
      let off = (j - (ids.len() - 1) / 2) * step
      paths.at(i).pts.at(-1).at(k) += off
      paths.at(i).pts.at(-2).at(k) += off
    }
  }
  paths
}

// Where edges that leave one node together part ways, or edges that reach one node
// together meet: the points to mark with a dot, as on a circuit diagram.
#let _junctions(edges, paths) = {
  let same(p, q) = calc.abs(p.at(0) - q.at(0)) < 0.5pt and calc.abs(p.at(1) - q.at(1)) < 0.5pt
  let dots = ()
  for (end, turned) in (("from", false), ("to", true)) {
    let shared = (:)
    for (e, path) in edges.zip(paths).filter(((_, path)) => path.kind == "line") {
      shared.insert(e.at(end), shared.at(e.at(end), default: ()) + (if turned { path.pts.rev() } else { path.pts },))
    }
    for group in shared.values().filter(group => group.len() > 1) {
      for (k, a) in group.enumerate() {
        for b in group.slice(k + 1).filter(b => same(a.first(), b.first())) {
          // walk the common start; they part at the last shared point, or along a shared
          // leg where the shorter of the two turns away
          let i = 1
          while i < calc.min(a.len(), b.len()) and same(a.at(i), b.at(i)) { i += 1 }
          if i >= calc.min(a.len(), b.len()) { continue }
          let (o, (ux, uy), (vx, vy)) = (a.at(i - 1), _unit(a.at(i - 1), a.at(i)), _unit(b.at(i - 1), b.at(i)))
          let along = ux * vx + uy * vy > 0.999
          let near = if calc.abs(a.at(i).at(0) - o.at(0)) + calc.abs(a.at(i).at(1) - o.at(1)) < (
            calc.abs(b.at(i).at(0) - o.at(0)) + calc.abs(b.at(i).at(1) - o.at(1))) { a.at(i) } else { b.at(i) }
          if along { dots.push(near) } else if i > 1 { dots.push(o) }
        }
      }
    }
  }
  dots.dedup()
}

// The point `pos` (0% to 100%) of the way along a path; auto is the middle of a curve
// and of the longest leg of a line.
#let _along-path(path, pos) = {
  let pts = path.pts
  let between(p, q, u) = (p.at(0) + (q.at(0) - p.at(0)) * u, p.at(1) + (q.at(1) - p.at(1)) * u)
  if path.kind != "line" {
    // de Casteljau
    while pts.len() > 1 { pts = pts.windows(2).map(((p, q)) => between(p, q, if pos == auto { 0.5 } else { pos / 100% })) }
    return pts.first()
  }
  let legs = pts.windows(2).map(((p, q)) => (p, q, calc.norm((q.at(0) - p.at(0)) / 1pt, (q.at(1) - p.at(1)) / 1pt)))
  if pos == auto {
    let (p, q, _) = legs.sorted(key: leg => -leg.at(2)).first()
    return between(p, q, 0.5)
  }
  let left = legs.map(leg => leg.at(2)).sum() * pos / 100%
  for (p, q, len) in legs {
    if left <= len { return between(p, q, if len == 0 { 0 } else { left / len }) }
    left -= len
  }
  pts.last()
}

// Joined frames share one outline; every other frame is a rounded rectangle.
#let _draw-frames(frames, t) = {
  // union-find; the array is passed in because closures capture by value
  let up(root, i) = {
    while root.at(i) != i { i = root.at(i) }
    i
  }
  let root = range(frames.len())
  for (i, f) in frames.enumerate().filter(((_, f)) => f.join != none) {
    let j = frames.position(o => o.name == f.join)
    if not (j != none) { assert(false, message: "flowchart: no group named \"" + f.join + "\" to join") }
    root.at(up(root, i)) = up(root, j)
  }
  for k in range(frames.len()).filter(k => up(root, k) == k) {
    let members = range(frames.len()).filter(i => up(root, i) == k).map(i => frames.at(i))
    let f = members.first()
    let outline = if f.stroke == auto {
      (paint: color.mix((t.line, 60%), (t.surface, 40%)), thickness: t.stroke, dash: "dashed")
    } else { f.stroke }
    if members.len() == 1 {
      place(top + left, dx: f.x0, dy: f.y0, rect(width: f.x1 - f.x0, height: f.y1 - f.y0,
        radius: 1.5 * t.corner-radius, fill: f.fill, stroke: outline))
    } else {
      for pts in _outline(members.map(m => (m.x0, m.y0, m.x1, m.y1))) {
        place(top + left, curve(fill: f.fill, stroke: outline, curve.move(pts.first()),
          ..pts.slice(1).map(curve.line), curve.close(mode: "straight")))
      }
    }
  }
}

#let _draw-edge(e, path, t, em) = {
  // an edge stroke falls back to the theme for what it leaves out, e.g. `stroke: red`
  let st = if e.stroke == auto { (paint: auto, thickness: auto) } else { stroke(e.stroke) }
  let paint = if st.paint == auto { t.line } else { st.paint }
  let thickness = if st.thickness == auto { 1.4 * t.stroke } else { st.thickness.to-absolute() }
  let (hl, start, end) = (thickness * 3 + 0.36 * em, e.marks.starts-with("<"), e.marks.ends-with(">"))
  let pts = path.pts
  if path.kind == "line" {
    _arrow(..pts, paint: paint, thickness: thickness, head: hl, start: start, end: end, dash: e.dash)
  } else {
    // heads point along the end tangents of the curve
    let back(tip, ctrl, d) = {
      let (ux, uy) = _unit(ctrl, tip)
      (tip.at(0) - ux * d, tip.at(1) - uy * d)
    }
    let (p, q) = (if start { back(pts.first(), pts.at(1), hl * 0.8) } else { pts.first() },
      if end { back(pts.last(), pts.at(-2), hl * 0.8) } else { pts.last() })
    place(top + left, curve(stroke: (paint: paint, thickness: thickness, dash: e.dash), curve.move(p),
      if path.kind == "quad" { curve.quad(pts.at(1), q) } else { curve.cubic(pts.at(1), pts.at(2), q) }))
    if end { _head(back(pts.last(), pts.at(-2), hl), pts.last(), paint, hl / 2) }
    if start { _head(back(pts.first(), pts.at(1), hl), pts.first(), paint, hl / 2) }
  }
}

#let _draw-node(nd, g, t) = {
  let y = g.sy
  let fill = if nd.fill != auto { nd.fill } else if g.kind == "loop" { none } else { t.panel }
  let outline = if nd.stroke != auto { nd.stroke } else if g.kind == "loop" { t.thick + t.accent } else {
    t.stroke + t.line
  }
  if g.kind == none {} else if g.kind == "diamond" {
    _poly((g.x, y - g.sh / 2), (g.x + g.sw / 2, y), (g.x, y + g.sh / 2), (g.x - g.sw / 2, y), fill: fill, stroke: outline,
      shadow: t.shadow)
  } else if g.kind == "loop" {
    let st = stroke(outline)
    if fill != none { place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, ellipse(width: g.sw, height: g.sh, fill: fill)) }
    _loop(g.x, y, g.sw / 2, g.sh / 2, if st.paint == auto { t.accent } else { st.paint },
      if st.thickness == auto { t.thick } else { st.thickness.to-absolute() })
  } else if g.kind == "ellipse" {
    place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, _shade(t.shadow, ellipse(width: g.sw, height: g.sh, fill: fill,
      stroke: outline)))
  } else {
    let r = if g.kind == "circle" { g.sw / 2 } else if g.kind == "pill" { g.sh / 2 } else { t.corner-radius }
    place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, _card(t, width: g.sw, height: g.sh, fill: fill,
      stroke: outline, radius: r))
  }
  // text on a coloured node takes the colour that reads best on it
  let body = if type(nd.fill) == color and g.kind != none { text(fill: _on(t, nd.fill), nd.body) } else { nd.body }
  _put(g.x, y, box(width: g.cw, align(center, body)), w: g.cw)
  if g.caption != none { _put(g.x, y + (g.sh + g.caption-gap + g.h - g.sh) / 2, g.caption, w: g.w) }
}

#let flowchart(
  ..children,
  dir: ltr,
  gap: (3.6em, 2.6em),
  inset: 0.65em,
  group-inset: 0.9em,
  group-stretch: none,
  title-style: (weight: "bold"),
  caption-style: (:),
  independent-columns: false,
  avoid-crossings: false,
  width: auto,
  theme: (:),
) = layout(area => {
  let t = _theme("flowchart", theme, arguments(..children.named()))
  let (gx, gy) = _pair("flowchart", "gap", gap)
  let (inset, group-inset, em) = _lens("flowchart", inset: inset, group-inset: group-inset, em: 1em).values()
  let (nodes, edges, groups, cells) = _resolve(children.pos().flatten(), dir, group-stretch)
  let titles = groups.map(g => if g.title != none { text(..title-style, g.title) })
  let (grid, geo) = _place(nodes, cells, _measure(nodes, inset, caption-style, em), groups, titles, edges, gx, gy,
    group-inset, independent-columns, em)
  let (frames, anchors) = _frames(nodes, geo, groups, titles, group-inset, em)
  if type(avoid-crossings) != bool { assert(false, message: "flowchart: `avoid-crossings` must be true or false, got "
    + repr(avoid-crossings)) }
  let paths = _routes(edges, anchors, geo, grid, dir, gx, gy, em, avoid-crossings)
  let labels = edges.zip(paths).filter(((e, _)) => e.label != none).map(((e, path)) => {
    let (x, y) = _along-path(path, e.label-pos)
    let body = box(fill: t.surface, inset: 0.18 * em, e.label)
    (x: x, y: y, body: body, ..measure(body))
  })
  // the canvas covers the tracks, the nodes, the frames with their titles, every edge and label
  let title-room(f, side) = if f.title-pos == side and not f.inside { f.th / 2 + 0.27 * em } else { 0pt }
  let extents = (
    (0pt, 0pt, grid.width, grid.height),
    ..geo.map(g => (g.x - g.a, g.y - g.b, g.x + g.a, g.y + g.b)),
    ..frames.map(f => (f.x0, f.y0 - title-room(f, top), f.x1, f.y1 + title-room(f, bottom))),
    ..labels.map(l => (l.x - l.width / 2, l.y - l.height / 2, l.x + l.width / 2, l.y + l.height / 2)),
  )
  // the four bounds, column by column (a zip, where a map would call a closure per box),
  // widened by the points of the edges plus the reach of their strokes and heads
  let (lefts, tops, rights, bottoms) = extents.first().zip(..extents.slice(1))
  let reach = 0.55 * em
  let (x0, y0, x1, y1) = (calc.min(..lefts), calc.min(..tops), calc.max(..rights), calc.max(..bottoms))
  if paths.len() > 0 {
    let pts = paths.map(path => path.pts).join()
    let (xs, ys) = pts.first().zip(..pts.slice(1))
    (x0, y0, x1, y1) = (calc.min(x0, calc.min(..xs) - reach), calc.min(y0, calc.min(..ys) - reach),
      calc.max(x1, calc.max(..xs) + reach), calc.max(y1, calc.max(..ys) + reach))
  }
  let (ox, oy) = (-x0, -y0)

  _canvas("flowchart", t, width, area, x1 - x0, y1 - y0,
    place(top + left, dx: ox, dy: oy, {
      _draw-frames(frames, t)
      for (e, path) in edges.zip(paths) { _draw-edge(e, path, t, em) }
      for (x, y) in _junctions(edges, paths) { _dot(x, y, 2.6 * t.stroke, fill: t.line) }
      for (nd, g) in nodes.zip(geo) { _draw-node(nd, g, t) }
      for f in frames.filter(f => f.title != none) {
        if f.inside {
          let y = if f.title-pos == top { f.y0 + 0.36 * em } else { f.y1 - 0.36 * em - f.th }
          place(top + left, dx: f.x0, dy: y, box(width: f.x1 - f.x0, align(center, f.title)))
        } else {
          let y = if f.title-pos == top { f.y0 } else { f.y1 }
          place(top + left, dx: f.x0 + 0.9 * em, dy: y - f.th / 2 - 0.09 * em,
            box(fill: t.surface, inset: (x: 0.36 * em, y: 0.09 * em), f.title))
        }
      }
      for l in labels { _put(l.x, l.y, l.body) }
    }))
})
