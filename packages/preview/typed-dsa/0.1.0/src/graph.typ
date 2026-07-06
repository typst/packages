// Graphs: directed or undirected, described as an adjacency dictionary.
//
// #graph(("v1": ("v2", "v3"), "v2": ("v3",), "v3": ())) — keys are node
// labels, values are arrays of neighbor labels. A node with no outgoing edges
// still needs its key present (with an empty array) to be drawn; a label that
// only ever appears as someone else's neighbor is picked up automatically.
//
// `labels:` swaps what's drawn inside a node for arbitrary content, keeping
// the adjacency keys as the plain-string identity used for edges,
// `positions:`, and `edge-customizations:`. `layout: "auto"` starts from the
// circular layout, then applies `positions:`. `layout: "manual"` starts from
// `positions:` only and requires every node to be placed.
// `edge-customizations:` restyles individual edges, including dash, wave,
// arrowheads, and bend.
//
// ponytail: nodes default to a circle, in first-seen order — no attempt yet
// to place connected nodes closer together. A force-directed layout (see
// AGENTS.md) is the planned upgrade; the call shape here won't need to
// change when it lands, only the default positions will improve. Manually
// placed nodes (`positions:`) are unaffected either way.

#import "@preview/cetz:0.5.2"
#import "style.typ": theme, resolve, scaled, edge-stroke, edge-arrow, edge-wave, wavy-parts
#import cetz.draw: line, circle, rect, content, bezier-through

// Every key, plus every neighbor not already a key, in first-seen order.
#let _nodes(adjacency) = {
  let seen = (:)
  let order = ()
  for k in adjacency.keys() {
    if k not in seen {
      seen.insert(k, true)
      order.push(k)
    }
  }
  for k in adjacency.keys() {
    for t in adjacency.at(k) {
      if t not in seen {
        seen.insert(t, true)
        order.push(t)
      }
    }
  }
  order
}

// A key for an unordered pair, so an undirected "a","b" and "b","a" match.
#let _norm-key(from, to) = if from < to { from + "\u{0}" + to } else { to + "\u{0}" + from }

// Directed edges keep every declared (from, to) pair as its own arrow.
// Undirected edges collapse a reciprocal pair (both "a": ("b",) and
// "b": ("a",)) into the single line it represents.
#let _edges(adjacency, directed) = {
  let edges = ()
  let seen = (:)
  for from in adjacency.keys() {
    for to in adjacency.at(from) {
      if directed {
        edges.push((from, to))
      } else {
        let key = _norm-key(from, to)
        if key not in seen {
          seen.insert(key, true)
          edges.push((from, to))
        }
      }
    }
  }
  edges
}

// Looks up an edge's customization dict. Order matters for a directed graph
// (from -> to is a specific edge) but not for an undirected one.
#let _edge-custom(customizations, from, to, directed) = {
  let key = if directed { from + "\u{0}" + to } else { _norm-key(from, to) }
  for (a, b, opts) in customizations {
    let k = if directed { a + "\u{0}" + b } else { _norm-key(a, b) }
    if k == key { return opts }
  }
  none
}

// Evenly spaced on a circle, starting at the top and going clockwise.
// `radius: auto` grows with node count; a number fixes the circle radius.
#let _circle-layout(nodes, th, radius) = {
  let n = nodes.len()
  let pos = (:)
  if n == 1 {
    pos.insert(nodes.at(0), (0.0, 0.0))
    return pos
  }
  let min-chord = 2 * th.node-radius + 1.05
  let r = if radius == auto { calc.max(min-chord / (2 * calc.sin(180deg / n)), th.node-radius * 2) } else { radius }
  for (i, name) in nodes.enumerate() {
    let theta = 90deg - 360deg * i / n
    pos.insert(name, (r * calc.cos(theta), r * calc.sin(theta)))
  }
  pos
}

#let _position-point(spec, pos) = {
  if "rel" in spec {
    if spec.rel not in pos { return none }
    let ref = pos.at(spec.rel)
    let off = spec.at("offset", default: (0, 0))
    return (ref.at(0) + off.at(0), ref.at(1) + off.at(1))
  }
  (spec.at(0), spec.at(1))
}

// Resolves `positions:`. In auto mode, omitted nodes keep their automatic
// circular spot. In manual mode, every node must be positioned, with at least
// one absolute `(x, y)` entry acting as the anchor for relative entries.
#let _resolve-positions(base, positions, nodes, layout) = {
  assert(layout == "auto" or layout == "manual", message: "graph layout must be \"auto\" or \"manual\"")
  let manual = layout == "manual"
  if manual {
    for name in nodes {
      assert(name in positions, message: "graph layout \"manual\" needs a position for " + name)
    }
  }
  let pos = if manual { (:) } else { base }
  for _ in range(nodes.len()) {
    for name in nodes {
      if name in positions {
        let p = _position-point(positions.at(name), pos)
        if p != none { pos.insert(name, p) }
      }
    }
  }
  for name in nodes {
    assert(name in pos, message: "graph could not resolve a position for " + name)
  }
  for name in nodes {
    if name in positions {
      let spec = positions.at(name)
      if "rel" in spec {
        assert(spec.rel in pos, message: "graph position for " + name + " references missing node " + spec.rel)
      }
    }
  }
  pos
}

// A point offset from the straight p-q midpoint, perpendicular to p-q, sized
// so the curve leaves each endpoint roughly `angle` off the straight line.
// `bend` is `"left"` or `"right"` (relative to travel from p to q).
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

// Backs `a` off toward `b` by `r`, landing it on a node's circumference
// instead of its center.
#let _trim-toward(a, b, r) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return a }
  (a.at(0) + dx / len * r, a.at(1) + dy / len * r)
}

#let _draw-edge(p, q, r, directed, th, custom) = {
  let stroke = edge-stroke(th, custom: custom)
  let mark = edge-arrow(th, directed, custom: custom)
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  if bend == false or bend == none {
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len == 0 { return }
    let ux = dx / len
    let uy = dy / len
    let a = (p.at(0) + ux * r, p.at(1) + uy * r)
    let b = (q.at(0) - ux * r, q.at(1) - uy * r)
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
  } else {
    let angle = if custom != none { custom.at("angle", default: 25deg) } else { 25deg }
    let bp = _bend-point(p, q, bend, angle)
    let p2 = _trim-toward(p, bp, r)
    let q2 = _trim-toward(q, bp, r)
    bezier-through(p2, bp, q2, stroke: stroke, mark: mark)
  }
}

#let _draw-node(label, p, th) = {
  if th.node-shape == "square" {
    let r = th.node-radius
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: th.node-fill, stroke: th.node-stroke)
  } else {
    circle(p, radius: th.node-radius, fill: th.node-fill, stroke: th.node-stroke)
  }
  content(p, text(size: th.text-size, label))
}

#let _render(adjacency, directed, labels, positions, layout, radius, edge-customizations, th) = {
  assert(layout == "auto" or radius == auto, message: "graph radius only works with layout \"auto\"")
  let nodes = _nodes(adjacency)
  let pos = _resolve-positions(_circle-layout(nodes, th, radius), positions, nodes, layout)
  let edges = _edges(adjacency, directed)
  scaled(th, cetz.canvas({
    for (from, to) in edges {
      let custom = _edge-custom(edge-customizations, from, to, directed)
      _draw-edge(pos.at(from), pos.at(to), th.node-radius, directed, th, custom)
    }
    for name in nodes {
      _draw-node(labels.at(name, default: name), pos.at(name), th)
    }
  }))
}

// `adjacency` maps each node label to an array of its neighbor labels.
// `directed` draws an arrowhead per declared pair; set it to `false` for an
// undirected graph, where a reciprocal pair collapses to one plain edge.
// `labels` swaps a node's drawn content, keyed by its adjacency label, any
// content: math, an image, styled text. `layout` is `"auto"` for the circular
// layout plus optional per-node positions, or `"manual"` to require every
// node in `positions`. `radius` controls the automatic circle only.
// `positions` accepts absolute `(x, y)` anchors or
// `(rel: other-label, offset: (dx, dy))` relative placements.
// `edge-customizations` is an array of `(from, to, options)` tuples restyling
// one edge. Options: `stroke:`, `color:`, `pattern:`, `arrow:`,
// `bend:`, `angle:`. `bend` is `"left"`, `"right"`, or `false` (default),
// and `angle` (default `25deg`) sets how sharply a bent edge curves.
#let graph(
  adjacency,
  directed: true,
  labels: (:),
  positions: (:),
  layout: "auto",
  radius: auto,
  edge-customizations: (),
  style: (:),
) = (
  diagram: _render(adjacency, directed, labels, positions, layout, radius, edge-customizations, resolve(style)),
)
