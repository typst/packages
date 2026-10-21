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
#import "common.typ": _arrow, _head, _loop, _poly, _put

// node(name, [(column, row)], body, shape:, fill:, stroke:, width:, height:, inset:, caption:)
// A fractional position such as (0.5, 1) centres the node between tracks and spans them.
// shape: "rect", "pill", "circle", "ellipse", "diamond" or "loop" (a ring with an arrowhead).
#let node(name, ..args) = {
  let pos = args.pos()
  assert(pos.len() in (1, 2), message: "node(name, [(column, row)], body): expected a body")
  (kind: "node", name: str(name), at: if pos.len() == 2 { pos.first() } else { auto }, body: pos.last(),
    style: args.named())
}

// edge("a", "b", "c") chains a -> b -> c; ends may be nodes or named groups.
// marks: "->", "<-", "<->" or "-".  route: auto, "straight", "hv", "vh", "hvh", "vhv"
// (h/v = horizontal/vertical legs) or "detour" (around the row or column).
// bend: curve the edge by this angle (positive bends left of the travel direction).
// via: (column, row) waypoints, fractional allowed, for hand-drawn paths.
#let edge(..names, label: none, marks: "->", stroke: auto, dash: none, route: auto, bend: 0deg, via: ()) = {
  names.pos().map(str).windows(2).map(((a, b)) => (kind: "edge", from: a, to: b, label: label,
    marks: marks, stroke: stroke, dash: dash, route: route, bend: bend, via: via))
}

// A dashed frame around nodes (and earlier groups).  Its title sits on the top or bottom
// border, or inside the frame with `inside: true`.  A `name` makes it an edge end.
#let group(title, ..names, name: none, fill: none, stroke: auto, title-pos: top, inside: false) = (
  kind: "group", title: title, names: names.pos().map(str), name: if name != none { str(name) },
  fill: fill, stroke: stroke, title-pos: title-pos, inside: inside)

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
  for l in range(calc.max(0, ..layer) + 1) {
    let members = range(n).filter(v => layer.at(v) == l)
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

// unit vector from p to q, as floats
#let _unit(p, q) = {
  let (dx, dy) = ((q.at(0) - p.at(0)) / 1pt, (q.at(1) - p.at(1)) / 1pt)
  let len = calc.max(calc.norm(dx, dy), 1e-9)
  (dx / len, dy / len)
}

#let flowchart(
  ..children,
  dir: ltr,
  spacing: (1.4cm, 1cm),
  node-fill: rgb("#ebedf5"),
  node-stroke: 0.8pt + rgb("#4c4f69"),
  edge-stroke: 1.2pt + rgb("#4c4f69"),
  loop-stroke: 3pt + rgb("#a7dd9b"),
  radius: 4pt,
  inset: 7pt,
  group-stroke: (paint: luma(150), thickness: 0.8pt, dash: "dashed"),
  group-inset: 10pt,
) = context {
  let parts = children.pos().flatten()
  let nodes = parts.filter(c => c.kind == "node")
  let groups = parts.filter(c => c.kind == "group")
  let edges = parts.filter(c => c.kind == "edge")
  let idx = (:)
  for (i, nd) in nodes.enumerate() { idx.insert(nd.name, i) }
  let (gx, gy) = if type(spacing) == array { spacing } else { (spacing, spacing) }

  // grid cells: given positions, or the automatic layout (layers run along `dir`)
  let auto-cells = if nodes.any(nd => nd.at == auto) {
    let links = edges.filter(e => e.from in idx and e.to in idx).map(e => (idx.at(e.from), idx.at(e.to)))
    _layout(nodes.len(), links).map(((l, k)) => if dir == ttb { (k, l) } else { (l, k) })
  }
  let cells = nodes.enumerate().map(((i, nd)) => if nd.at == auto { auto-cells.at(i) } else { nd.at })
  for c in cells.flatten() { assert(type(c) in (int, float), message: "flowchart: positions are (column, row) numbers") }

  // one measure per node: content, shape, then the footprint with its caption below
  let sizes = nodes.map(nd => {
    let st = nd.style
    let pad = st.at("inset", default: inset)
    let w = st.at("width", default: auto)
    let m = if w == auto { measure(nd.body) } else { measure(nd.body, width: w - 2 * pad) }
    let cw = if w == auto { m.width } else { w - 2 * pad }
    let (bw, bh) = (cw + 2 * pad, calc.max(m.height + 2 * pad, st.at("height", default: 0pt)))
    let kind = st.at("shape", default: "rect")
    let (sw, sh) = if kind == "circle" {
      let d = calc.norm(bw / 1pt, bh / 1pt) * 1pt
      (d, d)
    } else if kind == "diamond" { (2 * bw, 2 * bh) } else if kind in ("ellipse", "loop") {
      (bw * calc.sqrt(2), bh * calc.sqrt(2))
    } else { (bw, bh) }
    let caption = st.at("caption", default: none)
    let cm = if caption == none { (width: 0pt, height: 0pt) } else { measure(caption) }
    // a caption hangs 4pt under the shape and keeps 4pt clear of edges leaving below
    let gap = if caption == none { 0pt } else { 8pt }
    // edges clip to the footprint: the shape itself, or a box around shape and caption
    (w: calc.max(sw, cm.width), h: sh + gap + cm.height, sw: sw, sh: sh, cw: cw, kind: kind, caption: caption,
      shape: if caption == none { kind } else { "rect" })
  })

  // the tracks a node covers: one for an integer position, both neighbours for a fraction
  let tracks = cells.map(((c, r)) => (int(calc.floor(c)), int(calc.ceil(c)), int(calc.floor(r)), int(calc.ceil(r))))
  // track sizes as in CSS grid: single-track nodes take the largest size per track,
  // then a node spanning tracks spreads whatever it still lacks over them
  let (c0, r0) = (calc.min(..tracks.map(t => t.at(0))), calc.min(..tracks.map(t => t.at(2))))
  let col-w = (0pt,) * (calc.max(..tracks.map(t => t.at(1))) - c0 + 1)
  let row-h = (0pt,) * (calc.max(..tracks.map(t => t.at(3))) - r0 + 1)
  let fit(tracks, first, n, need, gap) = {
    let have = tracks.slice(first, first + n).sum() + gap * (n - 1)
    if n == 1 { tracks.at(first) = calc.max(tracks.at(first), need) } else if need > have {
      for k in range(first, first + n) { tracks.at(k) += (need - have) / n }
    }
    tracks
  }
  for pass in (1, 2) {
    for (i, (ca, cb, ra, rb)) in tracks.enumerate() {
      if (ca == cb) == (pass == 1) { col-w = fit(col-w, ca - c0, cb - ca + 1, sizes.at(i).w, gx) }
      if (ra == rb) == (pass == 1) { row-h = fit(row-h, ra - r0, rb - ra + 1, sizes.at(i).h, gy) }
    }
  }
  // groups as sets of nodes (a group may contain earlier groups) with the room their
  // frame and title take beyond those nodes, so the gaps between tracks can fit them
  let titles = groups.map(g => if g.title != none { text(weight: "bold", g.title) })
  let members = (:)
  for (i, nd) in nodes.enumerate() { members.insert(nd.name, (i,)) }
  let rooms = (:)
  let items = tracks.map(((ca, cb, ra, rb)) => (c0: ca - c0, c1: cb - c0, r0: ra - r0, r1: rb - r0,
    top: 0pt, bottom: 0pt, side: 0pt))
  for (g, title) in groups.zip(titles) {
    let ids = g.names.map(nm => {
      assert(nm in members, message: "flowchart: no node or group named \"" + nm + "\"")
      members.at(nm)
    }).flatten().dedup()
    let th = if title == none { 0pt } else { measure(title).height }
    let head = if title == none { 0pt } else if g.inside { th + 6pt } else { th / 2 + 3pt }
    let inner = g.names.filter(nm => nm in rooms).map(nm => rooms.at(nm))
    let ext(key) = group-inset + calc.max(0pt, ..inner.map(e => e.at(key)))
    let room = (top: ext("top") + (if g.title-pos == top { head } else { 0pt }),
      bottom: ext("bottom") + (if g.title-pos == bottom { head } else { 0pt }), side: ext("side"))
    if g.name != none {
      members.insert(g.name, ids)
      rooms.insert(g.name, room)
    }
    items.push((c0: calc.min(..ids.map(i => items.at(i).c0)), c1: calc.max(..ids.map(i => items.at(i).c1)),
      r0: calc.min(..ids.map(i => items.at(i).r0)), r1: calc.max(..ids.map(i => items.at(i).r1)), ..room))
  }
  // a gap grows until whatever faces each other across it fits, frames included
  let gaps(n, gap, last, first, lo, hi, before, after) = range(n - 1).map(k => calc.max(gap, ..items
    .filter(a => a.at(last) == k)
    .map(a => items.filter(b => b.at(first) == k + 1 and b.at(lo) <= a.at(hi) and a.at(lo) <= b.at(hi))
      .map(b => a.at(before) + b.at(after) + 6pt))
    .flatten()))
  let starts(tracks, gaps) = {
    let (acc, out) = (0pt, ())
    for (k, t) in tracks.enumerate() {
      out.push(acc)
      acc += t + gaps.at(k, default: 0pt)
    }
    out
  }
  let xs = starts(col-w, gaps(col-w.len(), gx, "c1", "c0", "r0", "r1", "side", "side"))
  let ys = starts(row-h, gaps(row-h.len(), gy, "r1", "r0", "c0", "c1", "bottom", "top"))
  let cxs = range(col-w.len()).map(i => xs.at(i) + col-w.at(i) / 2)
  let cys = range(row-h.len()).map(i => ys.at(i) + row-h.at(i) / 2)
  // a fractional grid coordinate, interpolated (or extrapolated) between track centres
  let along(v, cs, pitch) = if cs.len() == 1 { cs.first() + v * pitch } else {
    let k = calc.min(calc.max(int(calc.floor(v)), 0), cs.len() - 2)
    cs.at(k) + (v - k) * (cs.at(k + 1) - cs.at(k))
  }
  let grid-point((c, r)) = (along(c - c0, cxs, col-w.first() + gx), along(r - r0, cys, row-h.first() + gy))
  let geo = cells.enumerate().map(((i, cell)) => {
    let (x, y) = grid-point(cell)
    let sz = sizes.at(i)
    // a/b: half footprint; sa/sb/sy: half size and centre of the shape above its caption
    (x: x, y: y, a: sz.w / 2, b: sz.h / 2, sa: sz.sw / 2, sb: sz.sh / 2, sy: y - sz.h / 2 + sz.sh / 2, ..sz)
  })

  // edge ends: nodes, then group frames (a group may enclose earlier groups)
  let anchors = (:)
  for (nd, g) in nodes.zip(geo) { anchors.insert(nd.name, g) }
  let frames = ()
  for (g, title) in groups.zip(titles) {
    let ms = g.names.map(nm => anchors.at(nm))
    let (width: tw, height: th) = if title == none { (width: 0pt, height: 0pt) } else { measure(title) }
    let room = if g.inside and title != none { th + 6pt } else { 0pt }
    let (x0, x1) = (calc.min(..ms.map(m => m.x - m.a)) - group-inset, calc.max(..ms.map(m => m.x + m.a)) + group-inset)
    // a title inside the frame widens it when needed
    let widen = if g.inside { calc.max(0pt, tw + 2 * group-inset - (x1 - x0)) / 2 } else { 0pt }
    let f = (..g, title: title, th: th, x0: x0 - widen, x1: x1 + widen,
      y0: calc.min(..ms.map(m => m.y - m.b)) - group-inset - (if g.title-pos == top { room } else { 0pt }),
      y1: calc.max(..ms.map(m => m.y + m.b)) + group-inset + (if g.title-pos == bottom { room } else { 0pt }))
    frames.push(f)
    if g.name != none {
      let (x, y, a, b) = ((f.x0 + f.x1) / 2, (f.y0 + f.y1) / 2, (f.x1 - f.x0) / 2, (f.y1 - f.y0) / 2)
      anchors.insert(g.name, (x: x, y: y, a: a, b: b, sa: a, sb: b, sy: y, shape: "rect"))
    }
  }

  // closures capture by value, so this lookup is defined once every frame is known
  let find(name) = {
    assert(name in anchors, message: "flowchart: no node or group named \"" + name + "\"")
    anchors.at(name)
  }
  // distance from a centre to the border along the unit direction (ux, uy)
  let reach(g, ux, uy) = if g.shape == "circle" { g.a } else if g.shape == "diamond" {
    1pt / (calc.abs(ux) / (g.a / 1pt) + calc.abs(uy) / (g.b / 1pt))
  } else if g.shape in ("ellipse", "loop") {
    1pt / calc.norm(ux / (g.a / 1pt), uy / (g.b / 1pt))
  } else {
    calc.min(if calc.abs(ux) > 1e-9 { g.a / calc.abs(ux) } else { 1e6pt },
      if calc.abs(uy) > 1e-9 { g.b / calc.abs(uy) } else { 1e6pt })
  }
  // the border point of g in the direction of p
  let exit(g, p) = {
    let (ux, uy) = _unit((g.x, g.y), p)
    let d = reach(g, ux, uy)
    (g.x + ux * d, g.y + uy * d)
  }
  // horizontal edges meet the shape at mid height; vertical ones meet the footprint
  // (shape plus caption) at mid width
  let side(g, k) = (g.x + k * g.sa, g.sy)
  let end(g, k) = (g.x, g.y + k * g.b)
  // an end waypoint p slides along the leg it shares with its neighbour q until it
  // lines up with node g, so the edge meets g straight (orthogonal connector snapping)
  // (kept where it already faces the node, else moved to the middle of the shape)
  let snap(g, p, q) = {
    let (px, py) = p
    if calc.abs(q.at(0) - px) < 0.5pt and calc.abs(px - g.x) > g.sa {
      (px, if calc.abs(py - g.sy) < g.sb { py } else { g.sy })
    } else if calc.abs(q.at(1) - py) < 0.5pt and calc.abs(py - g.y) > g.b {
      (if calc.abs(px - g.x) < g.sa { px } else { g.x }, py)
    } else { p }
  }
  // where an edge from waypoint p meets g: a side when p faces it, else top or bottom
  let attach(g, p) = {
    let (px, py) = p
    // from above an edge must meet the shape itself; from below, the caption under it
    let half = if py < g.y { g.sa } else { g.a }
    if calc.abs(px - g.x) > g.sa and py >= g.sy - g.sb and py <= g.sy + g.sb {
      (g.x + (if px > g.x { g.sa } else { -g.sa }), py)
    } else if calc.abs(px - g.x) <= half { (px, g.y + (if py > g.y { g.b } else { -g.b })) } else { exit(g, p) }
  }
  let path(e) = {
    let (s, t) = (find(e.from), find(e.to))
    if e.via.len() > 0 {
      let pts = e.via.map(grid-point)
      if pts.len() > 1 {
        pts.at(0) = snap(s, pts.at(0), pts.at(1))
        pts.at(-1) = snap(t, pts.at(-1), pts.at(-2))
      }
      return (attach(s, pts.first()), ..pts, attach(t, pts.last()))
    }
    if e.bend != 0deg {
      let k = calc.tan(e.bend) / 2
      let c = ((s.x + t.x) / 2 + (t.y - s.y) * k, (s.y + t.y) / 2 - (t.x - s.x) * k)
      return (exit(s, c), c, exit(t, c))
    }
    let (dx, dy) = (t.x - s.x, t.y - s.y)
    let (hx, hy) = (if dx < 0pt { -1 } else { 1 }, if dy < 0pt { -1 } else { 1 })
    let (same-row, same-col) = (calc.abs(t.sy - s.sy) < 0.5pt, calc.abs(dx) < 0.5pt)
    // overlapping spans allow a straight edge even between different rows (or columns)
    let (lo-y, hi-y) = (calc.max(s.sy - s.sb, t.sy - t.sb), calc.min(s.sy + s.sb, t.sy + t.sb))
    let (lo-x, hi-x) = (calc.max(s.x - s.a, t.x - t.a), calc.min(s.x + s.a, t.x + t.a))
    let side-by-side = hi-y - lo-y > 8pt and calc.abs(dx) > s.a + t.a
    let stacked = hi-x - lo-x > 8pt and calc.abs(dy) > s.b + t.b
    // a straight edge must not run through another node or on top of its reverse edge
    let backwards = (same-row or same-col) and edges.any(o => o.from == e.to and o.to == e.from) and (
      if dir == ttb { dy < 0pt or dx < 0pt } else { dx < 0pt or dy < 0pt })
    // only nodes between the facing borders block (a group's own nodes do not)
    let blocked = geo.any(g => if same-row {
      calc.abs(g.sy - s.sy) < 0.5pt and (g.x - s.x - hx * s.sa) * hx > 0pt and (t.x - hx * t.sa - g.x) * hx > 0pt
    } else if same-col {
      calc.abs(g.x - s.x) < 0.5pt and (g.y - s.y - hy * s.b) * hy > 0pt and (t.y - hy * t.b - g.y) * hy > 0pt
    } else { false })
    let route = if e.route != auto { e.route } else if backwards or blocked { "detour" } else if same-row or same-col {
      "straight"
    } else if side-by-side { "across" } else if stacked { "down" } else if dir == ttb { "vhv" } else { "hvh" }
    // the line goes through the centre of the smaller end when it can
    let pick(lo, hi, u, v, small-first) = {
      let (p, q) = if small-first { (u, v) } else { (v, u) }
      if p >= lo and p <= hi { p } else if q >= lo and q <= hi { q } else { (lo + hi) / 2 }
    }
    if route == "straight" and same-row {
      (side(s, hx), side(t, -hx))
    } else if route == "straight" and same-col {
      (end(s, hy), end(t, -hy))
    } else if route == "straight" {
      (exit(s, (t.x, t.y)), exit(t, (s.x, s.y)))
    } else if route == "across" {
      let y = pick(lo-y, hi-y, s.sy, t.sy, s.sb <= t.sb)
      ((s.x + hx * s.sa, y), (t.x - hx * t.sa, y))
    } else if route == "down" {
      let x = pick(lo-x, hi-x, s.x, t.x, s.a <= t.a)
      ((x, s.y + hy * s.b), (x, t.y - hy * t.b))
    } else if route == "hv" {
      (side(s, hx), (t.x, s.sy), end(t, -hy))
    } else if route == "vh" {
      (end(s, hy), (s.x, t.sy), side(t, -hx))
    } else if route == "hvh" {
      let (x0, x1) = (s.x + hx * s.sa, t.x - hx * t.sa)
      ((x0, s.sy), ((x0 + x1) / 2, s.sy), ((x0 + x1) / 2, t.sy), (x1, t.sy))
    } else if route == "vhv" {
      let (y0, y1) = (s.y + hy * s.b, t.y - hy * t.b)
      ((s.x, y0), (s.x, (y0 + y1) / 2), (t.x, (y0 + y1) / 2), (t.x, y1))
    } else if route == "detour" and dir == ttb {
      // pass on the right unless nodes sit there, then on the left
      let (lo, hi) = (calc.min(s.y, t.y), calc.max(s.y, t.y))
      let k = if geo.any(g => g.x > calc.max(s.x, t.x) + 0.5pt and g.y >= lo and g.y <= hi) { -1 } else { 1 }
      let xd = if k > 0 { calc.max(s.x + s.a, t.x + t.a) + gx / 2 } else { calc.min(s.x - s.a, t.x - t.a) - gx / 2 }
      (side(s, k), (xd, s.sy), (xd, t.sy), side(t, k))
    } else if route == "detour" {
      // pass below unless nodes sit there, then above
      let (lo, hi) = (calc.min(s.x, t.x), calc.max(s.x, t.x))
      let k = if geo.any(g => g.y > calc.max(s.y, t.y) + 0.5pt and g.x >= lo and g.x <= hi) { -1 } else { 1 }
      let yd = if k > 0 { calc.max(s.y + s.b, t.y + t.b) + gy / 2 } else { calc.min(s.y - s.b, t.y - t.b) - gy / 2 }
      (end(s, k), (s.x, yd), (t.x, yd), end(t, k))
    } else { panic("flowchart: unknown route \"" + route + "\"") }
  }

  let paths = edges.map(path)
  // a label sits mid-curve on bent edges, else on the longest leg
  let labels = edges.zip(paths).filter(((e, _)) => e.label != none).map(((e, pts)) => {
    let (x, y) = if e.bend != 0deg and e.via.len() == 0 {
      let (p, c, q) = pts
      ((p.at(0) + 2 * c.at(0) + q.at(0)) / 4, (p.at(1) + 2 * c.at(1) + q.at(1)) / 4)
    } else {
      let (p, q) = pts.windows(2).sorted(key: ((p, q)) =>
        -calc.norm((q.at(0) - p.at(0)) / 1pt, (q.at(1) - p.at(1)) / 1pt)).first()
      ((p.at(0) + q.at(0)) / 2, (p.at(1) + q.at(1)) / 2)
    }
    let body = box(fill: white, inset: 2pt, e.label)
    (x: x, y: y, body: body, ..measure(body))
  })
  // the canvas covers the tracks, the frames with their titles, every edge and label
  let extents = (
    (0pt, 0pt, xs.last() + col-w.last(), ys.last() + row-h.last()),
    ..frames.map(f => (f.x0, if f.title-pos == top and not f.inside { f.y0 - f.th / 2 - 3pt } else { f.y0 },
      f.x1, if f.title-pos == bottom and not f.inside { f.y1 + f.th / 2 + 3pt } else { f.y1 })),
    ..paths.flatten().chunks(2).map(((x, y)) => (x - 6pt, y - 6pt, x + 6pt, y + 6pt)),
    ..labels.map(l => (l.x - l.width / 2, l.y - l.height / 2, l.x + l.width / 2, l.y + l.height / 2)),
  )
  let (ox, oy) = (-calc.min(..extents.map(m => m.at(0))), -calc.min(..extents.map(m => m.at(1))))
  let width = ox + calc.max(..extents.map(m => m.at(2)))
  let height = oy + calc.max(..extents.map(m => m.at(3)))

  box(width: width, height: height, place(top + left, dx: ox, dy: oy, {
    for f in frames {
      place(top + left, dx: f.x0, dy: f.y0, rect(width: f.x1 - f.x0, height: f.y1 - f.y0, radius: 6pt,
        fill: f.fill, stroke: if f.stroke == auto { group-stroke } else { f.stroke }))
    }
    for (e, pts) in edges.zip(paths) {
      let st = stroke(if e.stroke == auto { edge-stroke } else { e.stroke })
      let paint = if st.paint == auto { black } else { st.paint }
      let thickness = if st.thickness == auto { 1pt } else { st.thickness }
      let (hl, start, end) = (thickness * 3 + 4pt, e.marks.starts-with("<"), e.marks.ends-with(">"))
      if e.bend != 0deg and e.via.len() == 0 {
        // a quadratic curve; heads point along its end tangents
        let (p, c, q) = pts
        let back(tip, d) = {
          let (ux, uy) = _unit(c, tip)
          (tip.at(0) - ux * d, tip.at(1) - uy * d)
        }
        place(top + left, curve(stroke: (paint: paint, thickness: thickness, dash: e.dash),
          curve.move(if start { back(p, hl * 0.8) } else { p }), curve.quad(c, if end { back(q, hl * 0.8) } else { q })))
        if end { _head(back(q, hl), q, paint, hl / 2) }
        if start { _head(back(p, hl), p, paint, hl / 2) }
      } else {
        _arrow(..pts, paint: paint, thickness: thickness, head: hl, start: start, end: end, dash: e.dash)
      }
    }
    for (i, nd) in nodes.enumerate() {
      let g = geo.at(i)
      let y = g.sy
      let fill = nd.style.at("fill", default: if g.kind == "loop" { none } else { node-fill })
      let outline = nd.style.at("stroke", default: if g.kind == "loop" { loop-stroke } else { node-stroke })
      let body = box(width: g.cw, align(center, nd.body))
      if g.kind == "diamond" {
        _poly((g.x, y - g.sh / 2), (g.x + g.sw / 2, y), (g.x, y + g.sh / 2), (g.x - g.sw / 2, y), fill: fill, stroke: outline)
      } else if g.kind == "loop" {
        let st = stroke(outline)
        if fill != none { place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, ellipse(width: g.sw, height: g.sh, fill: fill)) }
        _loop(g.x, y, g.sw / 2, g.sh / 2, st.paint, if st.thickness == auto { 1pt } else { st.thickness })
      } else if g.kind == "ellipse" {
        place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, ellipse(width: g.sw, height: g.sh, fill: fill, stroke: outline))
      } else {
        let r = if g.kind == "circle" { g.sw / 2 } else if g.kind == "pill" { g.sh / 2 } else { radius }
        place(top + left, dx: g.x - g.sw / 2, dy: y - g.sh / 2, box(width: g.sw, height: g.sh, fill: fill,
          stroke: outline, radius: r))
      }
      _put(g.x, y, body, w: g.cw)
      if g.caption != none { _put(g.x, y + g.sh / 2 + 4pt + (g.h - g.sh - 8pt) / 2, g.caption, w: g.w) }
    }
    for f in frames.filter(f => f.title != none) {
      if f.inside {
        let y = if f.title-pos == top { f.y0 + 4pt } else { f.y1 - 4pt - f.th }
        place(top + left, dx: f.x0, dy: y, box(width: f.x1 - f.x0, align(center, f.title)))
      } else {
        let y = if f.title-pos == top { f.y0 } else { f.y1 }
        place(top + left, dx: f.x0 + 10pt, dy: y - f.th / 2 - 1pt, box(fill: white, inset: (x: 4pt, y: 1pt), f.title))
      }
    }
    for l in labels { _put(l.x, l.y, l.body) }
  }))
}
