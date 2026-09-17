// Graphs: directed or undirected, described as an adjacency dictionary.
//
// #graph(("v1": ("v2", ("v3", [edge label])), "v2": ("v3",), "v3": ())) —
// keys are node labels, values are arrays of neighbor labels or
// `(neighbor, edge-label)` pairs. A node with no outgoing edges still needs
// its key present (with an empty array) to be drawn; a label that only ever
// appears as someone else's neighbor is picked up automatically.
//
// `labels:` swaps what's drawn inside a node for arbitrary content, keeping
// the adjacency keys as the plain-string identity used for edges,
// `positions:`, and `edge-customizations:`. `layout: "auto"` starts from the
// circular layout, then applies `positions:`. `layout: "linear"` starts from
// a linear layout, then applies `positions`. `layout: "manual"` starts from
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
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, circle, rect, content, bezier-through

// Adjacency entries are either `"to"` or `("to", label)`.
#let _edge-to(entry) = if type(entry) == array { entry.at(0) } else { entry }
#let _edge-label(entry) = if type(entry) == array and entry.len() > 1 { entry.at(1) } else { none }

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
    for entry in adjacency.at(k) {
      let t = _edge-to(entry)
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
    for entry in adjacency.at(from) {
      let to = _edge-to(entry)
      let label = _edge-label(entry)
      if directed {
        edges.push((from, to, label))
      } else {
        let key = _norm-key(from, to)
        if key not in seen {
          seen.insert(key, true)
          edges.push((from, to, label))
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

#let _node-shape(th, custom) = {
  if custom != none and "shape" in custom { return custom.shape }
  th.node-shape
}

#let _node-radius(th, custom) = {
  if custom != none and "node-radius" in custom { return custom.node-radius }
  th.node-radius
}

#let _boundary-radius(shape, r, ux, uy) = {
  if shape in ("square", "rounded") {
    return r / calc.max(calc.abs(ux), calc.abs(uy))
  }
  if shape == "diamond" {
    return r / (calc.abs(ux) + calc.abs(uy))
  }
  if shape == "capsule" {
    let a = 0.4 * r
    return a * calc.abs(ux) + calc.sqrt(r * r - a * a * uy * uy)
  }
  r
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
  let node-width = if th.node-shape == "capsule" { 2.8 * th.node-radius } else { 2 * th.node-radius }
  let min-chord = node-width + 1.05
  let r = if radius == auto { calc.max(min-chord / (2 * calc.sin(180deg / n)), th.node-radius * 2) } else { radius }
  for (i, name) in nodes.enumerate() {
    let theta = 90deg - 360deg * i / n
    pos.insert(name, (r * calc.cos(theta), r * calc.sin(theta)))
  }
  pos
}

// Evenly spaced linear layout, from left to right.
#let _linear-layout(nodes, gap) = {
  let n = nodes.len()
  let pos = (:)
  for (i, name) in nodes.enumerate() {
    pos.insert(name, (gap * i, 0.0))
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
#let _resolve-positions(pos, positions, nodes, manual) = {
  if manual {
    for name in nodes {
      assert(name in positions, message: "graph layout \"manual\" needs a position for " + name)
    }
  }
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
#let _trim-toward(a, b, r, shape: "circle") = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return a }
  let ux = dx / len
  let uy = dy / len
  let d = _boundary-radius(shape, r, ux, uy)
  (a.at(0) + ux * d, a.at(1) + uy * d)
}

#let _edge-label-point(p, q, r, custom, th) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  
  let base = if len == 0 { p } else {
    let bend = if custom != none { custom.at("bend", default: false) } else { false }
    if bend == false or bend == none {
      let ux = dx / len
      let uy = dy / len
      let a = (p.at(0) + ux * r, p.at(1) + uy * r)
      let b = (q.at(0) - ux * r, q.at(1) - uy * r)
      ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
    } else {
      let angle = if custom != none { custom.at("angle", default: 25deg) } else { 25deg }
      _bend-point(p, q, bend, angle)
    }
  }

  if len == 0 { return base }

  let ux = dx / len
  let uy = dy / len
  
  let o1x = -uy
  let o1y = ux
  let o2x = uy
  let o2y = -ux
  
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  
  // Choose the orthogonal shift direction.
  let (ox, oy) = if bend == "left" {
    (-uy, ux) // Shift further outward in the direction of the left bend
  } else if bend == "right" {
    (uy, -ux) // Shift further outward in the direction of the right bend
  } else {
    // For straight edges, we want the orthogonal vector that points "up" (negative y).
    // If both have the same y (i.e. the edge is vertical, uy = 0), we pick right.
    if o1y < o2y { 
      (o1x, o1y) 
    } else if o1y > o2y { 
      (o2x, o2y) 
    } else {
      if o1x > 0 { (o1x, o1y) } else { (o2x, o2y) }
    }
  }

  let size = th.edge-label-text.at("size", default: 9pt)
  // Gap is 10% of size. But since text is centered, we also need to shift by 50% of size 
  // so the text's bounding box clears the line. Total shift = 60% of size.
  // Convert pt to CetZ coordinate units (1 unit = 1cm = 28.346pt).
  let shift-pt = if type(size) == length { (size / 1pt) * 0.6 } else { 6.0 }
  let gap = shift-pt / 28.346
  
  (base.at(0) + ox * gap, base.at(1) + oy * gap)
}

#let _draw-edge(p, q, from-boundary, to-boundary, directed, th, custom) = {
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
    let a = _trim-toward(p, q, from-boundary.at(1), shape: from-boundary.at(0))
    let b = _trim-toward(q, p, to-boundary.at(1), shape: to-boundary.at(0))
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
    let p2 = _trim-toward(p, bp, from-boundary.at(1), shape: from-boundary.at(0))
    let q2 = _trim-toward(q, bp, to-boundary.at(1), shape: to-boundary.at(0))
    bezier-through(p2, bp, q2, stroke: stroke, mark: mark)
  }
}

#let _draw-edge-label(label, p, q, r, th, custom) = {
  if label == none { return }
  let pt = _edge-label-point(p, q, r, custom, th)
  
  let label-style = th.edge-label-text
  let rotation = label-style.at("rotation", default: 0deg)
  
  if custom != none and "label" in custom {
    let l-custom = custom.label
    if type(l-custom) == dictionary {
      if "color" in l-custom {
        l-custom.fill = l-custom.color
        let _ = l-custom.remove("color")
      }
      if "rotation" in l-custom {
        rotation = l-custom.rotation
        let _ = l-custom.remove("rotation")
      }
      label-style = label-style + l-custom
    }
  }
  
  // Remove rotation from label-style so text() doesn't fail
  if "rotation" in label-style {
    let _ = label-style.remove("rotation")
  }
  
  if rotation == "edge" {
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let angle = calc.atan2(dx, dy)
    if dx < 0 {
      angle += 180deg
    }
    rotation = angle
  }
  
  content(pt, text(..label-style)[#label], angle: rotation)
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
  content(pt, text(..text-style)[#label.body], angle: rotation)
}

#let _draw-node(label, p, th, custom) = {
  let r = _node-radius(th, custom)
  let shape = _node-shape(th, custom)
  let fill = if custom != none and "fill" in custom { custom.fill } else { th.node-fill }
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else { th.node-stroke }
  let text-style = th.value-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  let polygon = pts => line(..pts, close: true, fill: fill, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: fill, stroke: stroke)
  } else if shape == "rounded" {
    rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), radius: 25%, fill: fill, stroke: stroke)
  } else if shape == "capsule" {
    rect((p.at(0) - 1.4 * r, p.at(1) - r), (p.at(0) + 1.4 * r, p.at(1) + r), radius: 50%, fill: fill, stroke: stroke)
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
    circle(p, radius: r, fill: fill, stroke: stroke)
  }
  content(p, text(..text-style, label), angle: rotation)
}

#let _render(adjacency, directed, labels, positions, layout, radius, gap, edge-customizations, node-customizations, node-labels, th) = {
  assert(layout == "auto" or layout == "linear" or layout == "manual", message: "graph layout must be \"auto\", \"linear\" or \"manual\"")

  assert(layout == "auto" or radius == auto, message: "graph radius only works with layout \"auto\"")
  assert(layout == "linear" or gap == auto, message: "gap only works with layout \"linear\"")

  let nodes = _nodes(adjacency)
  let layout = if layout == "auto" {
    _circle-layout(nodes, th, radius)
  } else if layout == "linear" {
    _linear-layout(nodes, if gap == auto { 1.5 } else { gap })
  } else {
    (:)
  }
  let pos = _resolve-positions(layout, positions, nodes, layout == "manual")
  let edges = _edges(adjacency, directed)
  
  for (u, v, opts) in edge-customizations {
    let found = false
    let key = if directed { u + "\u{0}" + v } else { _norm-key(u, v) }
    for (from, to, _) in edges {
      let k = if directed { from + "\u{0}" + to } else { _norm-key(from, to) }
      if k == key { found = true }
    }
    assert(found, message: "edge-customizations specified edge " + u + " -> " + v + " which does not exist in the graph")
  }

  scaled(th, cetz.canvas({
    for (from, to, label) in edges {
      let custom = _edge-custom(edge-customizations, from, to, directed)
      let from-custom = _node-custom(node-customizations, from)
      let to-custom = _node-custom(node-customizations, to)
      let from-boundary = (_node-shape(th, from-custom), _node-radius(th, from-custom))
      let to-boundary = (_node-shape(th, to-custom), _node-radius(th, to-custom))
      _draw-edge(pos.at(from), pos.at(to), from-boundary, to-boundary, directed, th, custom)
      _draw-edge-label(label, pos.at(from), pos.at(to), th.node-radius, th, custom)
    }
    for name in nodes {
      let custom = _node-custom(node-customizations, name)
      _draw-node(labels.at(name, default: name), pos.at(name), th, custom)
      let boundary = (_node-shape(th, custom), _node-radius(th, custom))
      _draw-node-label(pos.at(name), boundary, th, _resolve-node-label(th, node-labels, name))
    }
  }))
}

// `adjacency` maps each node label to an array of neighbor labels or
// `(neighbor-label, edge-label)` pairs.
// `directed` draws an arrowhead per declared pair; set it to `false` for an
// undirected graph, where a reciprocal pair collapses to one plain edge.
// `labels` swaps a node's drawn content, keyed by its adjacency label, any
// content: math, an image, styled text. `layout` is `"auto"` for the circular
// layout or "linear" for the row layout, plus optional per-node positions,
// or `"manual"` to require every node in `positions`. `gap` controls the spacing
// between nodes in the linear layout, it has no effect on other layouts. `radius`
// controls the
// automatic circle only. `positions` accepts absolute `(x, y)` anchors or
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
  gap: auto,
  edge-customizations: (),
  node-customizations: (),
  node-labels: (:),
  style: (:),
) = (
  diagram: _render(adjacency, directed, labels, positions, layout, radius, gap, edge-customizations, node-customizations, node-labels, resolve(style)),
)

// ── Algorithm traces ────────────────────────────────────────────────────────

#let _neighbors(adjacency, node, directed) = {
  let result = ()
  if node in adjacency {
    for entry in adjacency.at(node) {
      result.push((node: _edge-to(entry), weight: _edge-label(entry)))
    }
  }
  if not directed {
    for from in adjacency.keys() {
      for entry in adjacency.at(from) {
        if _edge-to(entry) == node and result.position(item => item.node == from) == none {
          result.push((node: from, weight: _edge-label(entry)))
        }
      }
    }
  }
  result
}

#let _state-node-customizations(base, nodes, visited, current, queued, th) = {
  let result = ()
  for node in nodes {
    let custom = _node-custom(base, node)
    if custom == none { custom = (:) }
    let state = if node == current { th.current-style }
      else if node in queued { th.queued-style }
      else if node in visited { th.visited-style }
      else { none }
    if state != none { custom += state }
    if custom.len() > 0 { result.push((node, custom)) }
  }
  result
}

#let _same-edge(a, b, from, to, directed) = if directed {
  a == from and b == to
} else {
  (a == from and b == to) or (a == to and b == from)
}

#let _path-edges(path) = {
  let result = ()
  for index in range(path.len() - 1) {
    result.push((path.at(index), path.at(index + 1)))
  }
  result
}

#let _state-edge-customizations(base, active, path, directed, th) = {
  let highlights = if active == none { _path-edges(path) } else { (active,) + _path-edges(path) }
  if highlights.len() == 0 { return base }
  let result = ()
  for (from, to) in highlights {
    let existing = _edge-custom(base, from, to, directed)
    result.push((from, to, (if existing == none { (:) } else { existing }) + th.active-edge-style))
  }
  for (a, b, custom) in base {
    if highlights.all(edge => not _same-edge(a, b, edge.at(0), edge.at(1), directed)) {
      result.push((a, b, custom))
    }
  }
  result
}

#let _distance-node-labels(nodes, distances, supplied, th, cat) = {
  let result = ()
  for node in nodes {
    let raw = _lookup-key(supplied, node)
    let value = if distances.at(node) == none { $infinity$ } else { distances.at(node) }
    let body = msg(cat, "graph.distance", value)
    let custom = (color: rgb("#7048E8"), weight: "bold")
    let defaults = th.at("node-labels", default: (:))
    if "gap" not in defaults { custom.gap = 0.5 }
    if type(raw) == dictionary { custom += raw }
    custom.content = body
    result.push((node, custom))
  }
  result
}

#let _algorithm-step(
  label, adjacency, directed, labels, positions, layout, radius,
  edge-customizations, node-customizations, node-labels, style,
  visited, current, queued, active,
  captions, distances: none, path: (), gap: auto, cat: default-catalog,
) = {
  let th = resolve(style)
  let nodes = _nodes(adjacency)
  let state-nodes = _state-node-customizations(node-customizations, nodes, visited, current, queued, th)
  let state-edges = _state-edge-customizations(edge-customizations, active, path, directed, th)
  let state-labels = if distances == none { node-labels } else { _distance-node-labels(nodes, distances, node-labels, th, cat) }
  let picture = _render(adjacency, directed, labels, positions, layout, radius, gap, state-edges, state-nodes, state-labels, th)
  (
    label: label,
    current: current,
    visited: visited,
    queued: queued,
    active-edge: active,
    path: path,
    diagram: align(center)[
      #if captions [#text(..th.algorithm-label-text)[#label] #v(0.25em)]
      #picture
    ],
  ) + if distances == none { (:) } else { (distances: distances,) }
}

#let _trace-result(steps, result, columns, row-gap) = (
  steps: steps,
  result: result,
  diagram: grid(columns: columns, column-gutter: row-gap, row-gutter: row-gap, ..steps.map(step => step.diagram)),
)

#let _path(previous, source, target, found) = {
  if target == none or not found { return () }
  let path = (target,)
  let current = target
  while current != source {
    current = previous.at(current, default: none)
    if current == none { return () }
    path.push(current)
  }
  path.rev()
}

#let _validate-traversal(adjacency, source, target) = {
  let nodes = _nodes(adjacency)
  assert(source in nodes, message: "graph traversal source must be a node in the graph")
  if target != none { assert(target in nodes, message: "graph traversal target must be a node in the graph") }
  nodes
}

#let bfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  goal-test: "discovery", language: "en", messages: (:),
) = {
  assert(goal-test in ("discovery", "expansion"), message: "bfs goal-test must be \"discovery\" or \"expansion\"")
  let cat = resolve-catalog(language: language, messages: messages)
  let nodes = _validate-traversal(adjacency, source, target)
  let queue = (source,)
  let seen = (:)
  seen.insert(source, true)
  let visited = ()
  let order = ()
  let previous = (:)
  let steps = ()
  let make(label, state-visited, state-queued, current: none, active: none) = _algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-queued, active, captions, gap: gap, cat: cat,
  )
  steps.push(make(msg(cat, "graph.queue", source), visited, queue))
  if target == source {
    order.push(source)
    visited.push(source)
    steps.push(make(msg(cat, "graph.reached", target), visited, ()))
    return _trace-result(steps, (order: order, found: true, path: (source,)), columns, row-gap)
  }
  while queue.len() > 0 {
    let current = queue.first()
    queue = queue.slice(1)
    steps.push(make(msg(cat, "graph.visit", current), visited, queue, current: current))
    order.push(current)
    if goal-test == "expansion" and target != none and current == target {
      visited.push(current)
      steps.push(make(msg(cat, "graph.reached", target), visited, queue))
      break
    }
    let target-discovered = false
    for neighbor in _neighbors(adjacency, current, directed) {
      let next = neighbor.node
      let discovered = next not in seen
      if discovered {
        seen.insert(next, true)
        previous.insert(next, current)
        queue.push(next)
      }
      steps.push(make(msg(cat, "graph.inspect", current, next), visited, queue, current: current, active: (current, next)))
      if goal-test == "discovery" and target != none and discovered and next == target {
        visited.push(current)
        steps.push(make(msg(cat, "graph.reached", target), visited, queue, current: target))
        target-discovered = true
        break
      }
    }
    if target-discovered { break }
    visited.push(current)
    steps.push(make(msg(cat, "graph.finish", current), visited, queue))
  }
  let found = if target == none { none } else { target in seen }
  _trace-result(steps, (order: order, found: found, path: _path(previous, source, target, found == true)), columns, row-gap)
}

#let dfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let cat = resolve-catalog(language: language, messages: messages)
  let nodes = _validate-traversal(adjacency, source, target)
  let stack = (source,)
  let seen = (:)
  seen.insert(source, true)
  let visited = ()
  let order = ()
  let previous = (:)
  let steps = ()
  let make(label, state-visited, state-queued, current: none, active: none) = _algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-queued, active, captions, gap: gap, cat: cat,
  )
  steps.push(make(msg(cat, "graph.stack", source), visited, stack))
  while stack.len() > 0 {
    let current = stack.last()
    stack = stack.slice(0, stack.len() - 1)
    steps.push(make(msg(cat, "graph.visit", current), visited, stack, current: current))
    order.push(current)
    if target != none and current == target {
      visited.push(current)
      steps.push(make(msg(cat, "graph.reached", target), visited, stack))
      break
    }
    let discovered = ()
    for neighbor in _neighbors(adjacency, current, directed) {
      let next = neighbor.node
      if next not in seen {
        seen.insert(next, true)
        previous.insert(next, current)
        discovered.push(next)
      }
      steps.push(make(msg(cat, "graph.inspect", current, next), visited, stack + discovered, current: current, active: (current, next)))
    }
    stack += discovered.rev()
    visited.push(current)
    steps.push(make(msg(cat, "graph.finish", current), visited, stack))
  }
  let found = if target == none { none } else { target in seen }
  _trace-result(steps, (order: order, found: found, path: _path(previous, source, target, found == true)), columns, row-gap)
}

#let dijkstra(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let cat = resolve-catalog(language: language, messages: messages)
  let nodes = _validate-traversal(adjacency, source, target)
  let distances = (:)
  for node in nodes { distances.insert(node, if node == source { 0 } else { none }) }
  let previous = (:)
  let visited = ()
  let order = ()
  let steps = ()
  let frontier(state-distances, state-visited, current: none) = nodes.filter(node => state-distances.at(node) != none and node not in state-visited and node != current)
  let make(label, state-visited, state-distances, current: none, active: none, path: ()) = _algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, frontier(state-distances, state-visited, current: current), active, captions, distances: state-distances, path: path, gap: gap, cat: cat,
  )
  steps.push(make(msg(cat, "graph.distance-init", source), visited, distances))
  while true {
    let current = none
    for node in nodes {
      if node not in visited and distances.at(node) != none and (current == none or distances.at(node) < distances.at(current)) {
        current = node
      }
    }
    if current == none { break }
    steps.push(make(msg(cat, "graph.settle", current), visited, distances, current: current))
    order.push(current)
    if target != none and current == target {
      visited.push(current)
      steps.push(make(
        msg(cat, "graph.shortest-path", target),
        visited,
        distances,
        path: _path(previous, source, target, true),
      ))
      break
    }
    for neighbor in _neighbors(adjacency, current, directed) {
      let next = neighbor.node
      let weight = if neighbor.weight == none { 1 } else { neighbor.weight }
      assert(type(weight) in (int, float) and weight >= 0, message: "dijkstra edge weights must be non-negative numbers")
      if next not in visited {
        let candidate = distances.at(current) + weight
        if distances.at(next) == none or candidate < distances.at(next) {
          distances.insert(next, candidate)
          previous.insert(next, current)
        }
      }
      steps.push(make(msg(cat, "graph.relax", current, next), visited, distances, current: current, active: (current, next)))
    }
    visited.push(current)
    steps.push(make(msg(cat, "graph.finish", current), visited, distances))
  }
  let found = if target == none { none } else { distances.at(target) != none }
  _trace-result(steps, (
    distances: distances,
    previous: previous,
    order: order,
    found: found,
    path: _path(previous, source, target, found == true),
  ), columns, row-gap)
}
