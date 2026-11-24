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
#import "@preview/cetz:0.5.2"
#import "style.typ": (
  theme, resolve, scaled, edge-stroke, edge-arrow, edge-wave, wavy-parts,
  validate-style, check-coordinate-pair, check-edge-customization-options,
  check-node-customization-options, check-node-label-override,
)
#import "validate.typ": (
  check-array, check-bool, check-customization-entries, check-dictionary,
  check-enum, check-id-value-references, check-integer, check-known-keys,
  check-number, check-positive, check-reference, fail, is-number,
  normalize-id-value-entries, show-list, show-value,
)
#import "messages.typ": default-catalog, resolve-catalog, msg
#import cetz.draw: line, circle, rect, content, bezier-through

// Adjacency entries are either `"to"` or `("to", label)`.
#let _edge-target-id(entry) = if type(entry) == array { entry.at(0) } else { entry }
#let _edge-display-label(entry) = if type(entry) == array and entry.len() > 1 { entry.at(1) } else { none }

// Every key, plus every neighbor not already a key, in first-seen order.
#let _collect-graph-node-ids(adjacency) = {
  let seen-node-ids = (:)
  let node-ids = ()
  for adjacency-key in adjacency.keys() {
    if adjacency-key not in seen-node-ids {
      seen-node-ids.insert(adjacency-key, true)
      node-ids.push(adjacency-key)
    }
  }
  for adjacency-key in adjacency.keys() {
    for edge-entry in adjacency.at(adjacency-key) {
      let target-node-id = _edge-target-id(edge-entry)
      if target-node-id not in seen-node-ids {
        seen-node-ids.insert(target-node-id, true)
        node-ids.push(target-node-id)
      }
    }
  }
  node-ids
}

// A key for an unordered pair, so an undirected "a","b" and "b","a" match.
#let _normalize-undirected-edge-key(from-node-id, to-node-id) = if from-node-id < to-node-id {
  from-node-id + "\u{0}" + to-node-id
} else {
  to-node-id + "\u{0}" + from-node-id
}

// Directed edges keep every declared (from, to) pair as its own arrow.
// Undirected edges collapse a reciprocal pair (both "a": ("b",) and
// "b": ("a",)) into the single line it represents.
#let _collect-graph-edges(adjacency, directed) = {
  let graph-edges = ()
  let seen-edge-keys = (:)
  for from-node-id in adjacency.keys() {
    for edge-entry in adjacency.at(from-node-id) {
      let to-node-id = _edge-target-id(edge-entry)
      let edge-label = _edge-display-label(edge-entry)
      if directed {
        graph-edges.push((from-node-id, to-node-id, edge-label))
      } else {
        let edge-key = _normalize-undirected-edge-key(
          from-node-id,
          to-node-id,
        )
        if edge-key not in seen-edge-keys {
          seen-edge-keys.insert(edge-key, true)
          graph-edges.push((from-node-id, to-node-id, edge-label))
        }
      }
    }
  }
  graph-edges
}

// Looks up an edge's customization dict. Order matters for a directed graph
// (from -> to is a specific edge) but not for an undirected one.
#let _resolve-graph-edge-customization(customizations, from-node-id, to-node-id, directed) = {
  let requested-edge-key = if directed {
    from-node-id + "\u{0}" + to-node-id
  } else {
    _normalize-undirected-edge-key(from-node-id, to-node-id)
  }
  for (custom-from-id, custom-to-id, options) in customizations {
    let customized-edge-key = if directed {
      custom-from-id + "\u{0}" + custom-to-id
    } else {
      _normalize-undirected-edge-key(custom-from-id, custom-to-id)
    }
    if customized-edge-key == requested-edge-key { return options }
  }
  none
}

#let _resolve-graph-node-customization(customizations, node-id) = {
  for (custom-node-id, options) in customizations {
    if custom-node-id == node-id { return options }
  }
  none
}

#let _normalize-graph-text-style(style) = {
  let normalized-style = style
  if "color" in normalized-style {
    normalized-style.fill = normalized-style.color
    let _ = normalized-style.remove("color")
  }
  normalized-style
}

#let _lookup-graph-node-value(values, node-id) = {
  if type(values) == dictionary {
    if type(node-id) == str or type(node-id) == int or type(node-id) == float {
      return values.at(str(node-id), default: none)
    }
    return none
  }
  for (candidate-node-id, value) in values {
    if candidate-node-id == node-id { return value }
  }
  none
}

#let _resolve-graph-node-shape(resolved-style, custom) = {
  if custom != none and "shape" in custom { return custom.shape }
  resolved-style.node-shape
}

#let _resolve-graph-node-radius(resolved-style, custom) = {
  if custom != none and "node-radius" in custom { return custom.node-radius }
  resolved-style.node-radius
}

#let _calculate-node-boundary-radius(shape, r, ux, uy) = {
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
#let _calculate-circular-graph-layout(node-ids, resolved-style, radius) = {
  let node-count = node-ids.len()
  let node-positions = (:)
  if node-count == 1 {
    node-positions.insert(node-ids.at(0), (0.0, 0.0))
    return node-positions
  }
  let node-width = if resolved-style.node-shape == "capsule" {
    2.8 * resolved-style.node-radius
  } else {
    2 * resolved-style.node-radius
  }
  let minimum-chord = node-width + 1.05
  let layout-radius = if radius == auto {
    calc.max(
      minimum-chord / (2 * calc.sin(180deg / node-count)),
      resolved-style.node-radius * 2,
    )
  } else {
    radius
  }
  for (node-index, node-id) in node-ids.enumerate() {
    let node-angle = 90deg - 360deg * node-index / node-count
    node-positions.insert(node-id, (
      layout-radius * calc.cos(node-angle),
      layout-radius * calc.sin(node-angle),
    ))
  }
  node-positions
}

// Evenly spaced linear layout, from left to right.
#let _calculate-linear-graph-layout(node-ids, gap) = {
  let node-positions = (:)
  for (node-index, node-id) in node-ids.enumerate() {
    node-positions.insert(node-id, (gap * node-index, 0.0))
  }
  node-positions
}

#let _resolve-position-specification(position-specification, resolved-positions) = {
  if "rel" in position-specification {
    if position-specification.rel not in resolved-positions { return none }
    let reference-position = resolved-positions.at(position-specification.rel)
    let offset = position-specification.at("offset", default: (0, 0))
    return (
      reference-position.at(0) + offset.at(0),
      reference-position.at(1) + offset.at(1),
    )
  }
  (position-specification.at(0), position-specification.at(1))
}

// Resolves `positions:`. In auto mode, omitted nodes keep their automatic
// circular spot. In manual mode, every node must be positioned, with at least
// one absolute `(x, y)` entry acting as the anchor for relative entries.
#let _resolve-graph-node-positions(initial-positions, positions, node-ids, uses-manual-layout) = {
  if uses-manual-layout {
    for node-id in node-ids {
      assert(node-id in positions, message: "graph layout \"manual\" needs a position for " + node-id)
    }
  }
  for _ in range(node-ids.len()) {
    for node-id in node-ids {
      if node-id in positions {
        let resolved-position = _resolve-position-specification(
          positions.at(node-id),
          initial-positions,
        )
        if resolved-position != none {
          initial-positions.insert(node-id, resolved-position)
        }
      }
    }
  }
  for node-id in node-ids {
    assert(node-id in initial-positions, message: "graph could not resolve a position for " + node-id)
  }
  for node-id in node-ids {
    if node-id in positions {
      let position-specification = positions.at(node-id)
      if "rel" in position-specification {
        assert(position-specification.rel in initial-positions, message: "graph position for " + node-id + " references missing node " + position-specification.rel)
      }
    }
  }
  initial-positions
}

// A point offset from the straight p-q midpoint, perpendicular to p-q, sized
// so the curve leaves each endpoint roughly `angle` off the straight line.
// `bend` is `"left"` or `"right"` (relative to travel from p to q).
#let _calculate-graph-edge-bend-point(from-position, to-position, bend-direction, angle) = {
  let delta-x = to-position.at(0) - from-position.at(0)
  let delta-y = to-position.at(1) - from-position.at(1)
  let edge-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  let midpoint-x = (from-position.at(0) + to-position.at(0)) / 2
  let midpoint-y = (from-position.at(1) + to-position.at(1)) / 2
  if edge-length == 0 { return (midpoint-x, midpoint-y) }
  let unit-x = delta-x / edge-length
  let unit-y = delta-y / edge-length
  let (perpendicular-x, perpendicular-y) = if bend-direction == "left" {
    (-unit-y, unit-x)
  } else {
    (unit-y, -unit-x)
  }
  let sagitta = (edge-length / 2) * calc.tan(angle)
  (
    midpoint-x + perpendicular-x * sagitta,
    midpoint-y + perpendicular-y * sagitta,
  )
}

#let _trim-edge-to-node-boundary(node-position, toward-position, node-radius, shape: "circle") = {
  let delta-x = toward-position.at(0) - node-position.at(0)
  let delta-y = toward-position.at(1) - node-position.at(1)
  let edge-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  if edge-length == 0 { return node-position }
  let unit-x = delta-x / edge-length
  let unit-y = delta-y / edge-length
  let boundary-distance = _calculate-node-boundary-radius(
    shape,
    node-radius,
    unit-x,
    unit-y,
  )
  (
    node-position.at(0) + unit-x * boundary-distance,
    node-position.at(1) + unit-y * boundary-distance,
  )
}

#let _calculate-edge-label-position(p, q, r, custom, resolved-style) = {
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
      _calculate-graph-edge-bend-point(p, q, bend, angle)
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

  let size = resolved-style.edge-label-text.at("size", default: 9pt)
  // Gap is 10% of size. But since text is centered, we also need to shift by 50% of size 
  // so the text's bounding box clears the line. Total shift = 60% of size.
  // Convert pt to CetZ coordinate units (1 unit = 1cm = 28.346pt).
  let shift-pt = if type(size) == length { (size / 1pt) * 0.6 } else { 6.0 }
  let gap = shift-pt / 28.346
  
  (base.at(0) + ox * gap, base.at(1) + oy * gap)
}

#let _render-graph-edge(p, q, from-boundary, to-boundary, directed, resolved-style, custom) = {
  let stroke = edge-stroke(resolved-style, custom: custom)
  let mark = edge-arrow(resolved-style, directed, custom: custom)
  let bend = if custom != none { custom.at("bend", default: false) } else { false }
  if bend == false or bend == none {
    let dx = q.at(0) - p.at(0)
    let dy = q.at(1) - p.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len == 0 { return }
    let ux = dx / len
    let uy = dy / len
    let a = _trim-edge-to-node-boundary(p, q, from-boundary.at(1), shape: from-boundary.at(0))
    let b = _trim-edge-to-node-boundary(q, p, to-boundary.at(1), shape: to-boundary.at(0))
    if edge-wave(resolved-style, custom: custom) {
      let start-tip = mark != none and "start" in mark
      let end-tip = mark != none and "end" in mark
      let parts = wavy-parts(a, b, resolved-style, start-tip: start-tip, end-tip: end-tip)
      line(..parts.points, stroke: stroke)
      let fill = if mark == none { none } else { mark.at("fill", default: none) }
      if start-tip { line(a, parts.start-cap, stroke: stroke, mark: (start: ">", fill: fill)) }
      if end-tip { line(parts.end-cap, b, stroke: stroke, mark: (end: ">", fill: fill)) }
    } else {
      line(a, b, stroke: stroke, mark: mark)
    }
  } else {
    let angle = if custom != none { custom.at("angle", default: 25deg) } else { 25deg }
    let bp = _calculate-graph-edge-bend-point(p, q, bend, angle)
    let p2 = _trim-edge-to-node-boundary(p, bp, from-boundary.at(1), shape: from-boundary.at(0))
    let q2 = _trim-edge-to-node-boundary(q, bp, to-boundary.at(1), shape: to-boundary.at(0))
    bezier-through(p2, bp, q2, stroke: stroke, mark: mark)
  }
}

#let _render-graph-edge-label(label, p, q, r, resolved-style, custom) = {
  if label == none { return }
  let pt = _calculate-edge-label-position(p, q, r, custom, resolved-style)
  
  let label-style = resolved-style.edge-label-text
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

#let _graph-node-label-direction(pos) = {
  if pos == "right" { return (1, 0) }
  if pos == "left" { return (-1, 0) }
  if pos == "top" { return (0, 1) }
  if pos == "bottom" { return (0, -1) }
  if type(pos) == angle { return (calc.cos(pos), calc.sin(pos)) }
  (1, 0)
}

#let _resolve-graph-node-label(resolved-style, node-labels, id) = {
  let raw = _lookup-graph-node-value(node-labels, id)
  if raw == none { return none }
  let body = raw
  let style = resolved-style.label-text
  let defaults = resolved-style.at("node-labels", default: (:))
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

#let _render-graph-node-label(node-position, boundary, resolved-style, label) = {
  if label == none { return }
  let label-direction = _graph-node-label-direction(label.position)
  let offset-x = label.offset.at(0)
  let offset-y = label.offset.at(1)
  let label-gap = label.gap
  let boundary-distance = _calculate-node-boundary-radius(
    boundary.at(0),
    boundary.at(1),
    label-direction.at(0),
    label-direction.at(1),
  )
  let label-position = (
    node-position.at(0)
      + label-direction.at(0) * (boundary-distance + label-gap)
      + offset-x,
    node-position.at(1)
      + label-direction.at(1) * (boundary-distance + label-gap)
      + offset-y,
  )
  let text-style = label.style
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  content(label-position, text(..text-style)[#label.body], angle: rotation)
}

#let _render-graph-node(label, p, resolved-style, custom) = {
  let r = _resolve-graph-node-radius(resolved-style, custom)
  let shape = _resolve-graph-node-shape(resolved-style, custom)
  let fill = if custom != none and "fill" in custom { custom.fill } else { resolved-style.node-fill }
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else { resolved-style.node-stroke }
  let text-style = resolved-style.value-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-graph-text-style(text-style)
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

#let _render-graph(adjacency, directed, labels, positions, layout, radius, gap, edge-customizations, node-customizations, node-labels, resolved-style) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let initial-node-positions = if layout == "auto" {
    _calculate-circular-graph-layout(node-ids, resolved-style, radius)
  } else if layout == "linear" {
    _calculate-linear-graph-layout(
      node-ids,
      if gap == auto { 1.5 } else { gap },
    )
  } else {
    (:)
  }
  let node-positions = _resolve-graph-node-positions(
    initial-node-positions,
    positions,
    node-ids,
    layout == "manual",
  )
  let graph-edges = _collect-graph-edges(adjacency, directed)

  scaled(resolved-style, cetz.canvas({
    for (from-node-id, to-node-id, edge-label) in graph-edges {
      let edge-customization = _resolve-graph-edge-customization(
        edge-customizations,
        from-node-id,
        to-node-id,
        directed,
      )
      let from-node-customization = _resolve-graph-node-customization(
        node-customizations,
        from-node-id,
      )
      let to-node-customization = _resolve-graph-node-customization(
        node-customizations,
        to-node-id,
      )
      let from-boundary = (
        _resolve-graph-node-shape(resolved-style, from-node-customization),
        _resolve-graph-node-radius(resolved-style, from-node-customization),
      )
      let to-boundary = (
        _resolve-graph-node-shape(resolved-style, to-node-customization),
        _resolve-graph-node-radius(resolved-style, to-node-customization),
      )
      _render-graph-edge(
        node-positions.at(from-node-id),
        node-positions.at(to-node-id),
        from-boundary,
        to-boundary,
        directed,
        resolved-style,
        edge-customization,
      )
      _render-graph-edge-label(
        edge-label,
        node-positions.at(from-node-id),
        node-positions.at(to-node-id),
        resolved-style.node-radius,
        resolved-style,
        edge-customization,
      )
    }
    for node-id in node-ids {
      let node-customization = _resolve-graph-node-customization(
        node-customizations,
        node-id,
      )
      _render-graph-node(
        labels.at(node-id, default: node-id),
        node-positions.at(node-id),
        resolved-style,
        node-customization,
      )
      let node-boundary = (
        _resolve-graph-node-shape(resolved-style, node-customization),
        _resolve-graph-node-radius(resolved-style, node-customization),
      )
      _render-graph-node-label(
        node-positions.at(node-id),
        node-boundary,
        resolved-style,
        _resolve-graph-node-label(resolved-style, node-labels, node-id),
      )
    }
  }))
}

// ── Validation ───────────────────────────────────────────────────────────────
//
// Identity comes from the adjacency keys, so everything else — labels,
// positions, customizations, traversal endpoints — is checked against the node
// set those keys produce. A neighbour that appears only as someone else's
// target is a declared node too, by design.

#let graph-layouts = ("auto", "linear", "manual")

#let _validate-graph-adjacency(where, adjacency) = {
  check-dictionary(
    where, "adjacency", adjacency,
    fix: "pass a dictionary, for example (\"a\": (\"b\",), \"b\": ())",
  )
  for (from-node-id, edge-entries) in adjacency {
    let entries-name = "adjacency entry \"" + from-node-id + "\""
    check-array(
      where, entries-name, edge-entries,
      fix: "list the neighbours in an array, for example \"" + from-node-id + "\": (\"b\",)",
    )
    for (entry-index, edge-entry) in edge-entries.enumerate() {
      let entry-name = entries-name + " neighbour " + str(entry-index)
      if type(edge-entry) == str { continue }
      let is-labelled-pair = (
        type(edge-entry) == array
          and edge-entry.len() in (1, 2)
          and type(edge-entry.at(0)) == str
      )
      if is-labelled-pair { continue }
      fail(
        where,
        entry-name + " is " + show-value(edge-entry),
        expected: "a neighbour name, or a (neighbour, edge-label) pair",
        fix: "write it as \"b\", or (\"b\", [w]) to label the edge",
      )
    }
  }
}

#let _graph-edge-key(from-node-id, to-node-id, directed) = if directed {
  from-node-id + "\u{0}" + to-node-id
} else {
  _normalize-undirected-edge-key(from-node-id, to-node-id)
}

#let _show-graph-edges(graph-edges, directed) = if graph-edges.len() == 0 {
  "(the graph has no edges)"
} else {
  graph-edges.map(
    edge => edge.at(0) + (if directed { " -> " } else { " -- " }) + edge.at(1),
  ).join(", ")
}

#let _validate-graph-edge-references(where, adjacency, directed, edge-customizations) = {
  check-customization-entries(
    where,
    "edge-customizations:",
    edge-customizations,
    3,
    check-edge-customization-options,
  )
  let graph-edges = _collect-graph-edges(adjacency, directed)
  let declared-edge-keys = graph-edges.map(
    edge => _graph-edge-key(edge.at(0), edge.at(1), directed),
  )
  for (custom-from-id, custom-to-id, _) in edge-customizations {
    let customized-edge-key = _graph-edge-key(custom-from-id, custom-to-id, directed)
    if customized-edge-key in declared-edge-keys { continue }
    fail(
      where,
      "edge-customizations: refers to edge " + custom-from-id + " -> " + custom-to-id + ", which does not exist in the graph",
      expected: "one of the edges: " + _show-graph-edges(graph-edges, directed),
      fix: if directed {
        "a directed edge is customized in its declared direction"
      } else {
        "declare the edge in the adjacency dictionary first"
      },
    )
  }
}

// A relative position that eventually points back at itself can never be
// resolved, so the placement loop would silently leave those nodes wherever
// the base layout happened to put them.
#let _check-relative-position-cycles(where, positions) = {
  for start-node-id in positions.keys() {
    let visited-node-ids = (start-node-id,)
    let current-node-id = start-node-id
    while true {
      let position-specification = positions.at(current-node-id, default: none)
      let is-relative = (
        type(position-specification) == dictionary
          and "rel" in position-specification
      )
      if not is-relative { break }
      let reference-node-id = position-specification.rel
      if reference-node-id in visited-node-ids {
        fail(
          where,
          "positions: relative placements form a cycle: " + (visited-node-ids + (reference-node-id,)).join(" -> "),
          expected: "every relative chain to end at an absolute (x, y) position",
          fix: "give one node in the cycle an absolute position",
        )
      }
      visited-node-ids.push(reference-node-id)
      current-node-id = reference-node-id
    }
  }
}

#let _validate-graph-positions(where, positions, node-ids) = {
  check-dictionary(
    where, "positions:", positions,
    fix: "pass a dictionary keyed by node name",
  )
  for (node-id, position-specification) in positions {
    check-reference(where, "positions:", node-id, node-ids)
    let what = "positions.\"" + node-id + "\""
    if type(position-specification) == dictionary {
      check-known-keys(where, what, position-specification, ("rel", "offset"))
      if "rel" not in position-specification {
        fail(
          where,
          what + " has no \"rel\" entry",
          expected: "an (x, y) pair, or (rel: other-node, offset: (dx, dy))",
          fix: "name the node this one is placed against",
        )
      }
      check-reference(where, what + ".rel", position-specification.rel, node-ids)
      if "offset" in position-specification {
        check-coordinate-pair(where, what + ".offset", position-specification.offset)
      }
      continue
    }
    check-coordinate-pair(where, what, position-specification)
  }
  _check-relative-position-cycles(where, positions)
}

#let _validate-graph-layout(where, layout, radius, gap, positions, node-ids) = {
  check-enum(where, "layout:", layout, graph-layouts)
  if radius != auto {
    check-positive(where, "radius:", radius)
    if layout != "auto" {
      fail(
        where,
        "radius: was given with layout \"" + layout + "\"",
        expected: "radius: only applies to layout \"auto\", which places nodes on a circle",
        fix: "drop radius:, or switch to layout: \"auto\"",
      )
    }
  }
  if gap != auto {
    check-positive(where, "gap:", gap)
    if layout != "linear" {
      fail(
        where,
        "gap: was given with layout \"" + layout + "\"",
        expected: "gap: only applies to layout \"linear\", which spaces nodes in a row",
        fix: "drop gap:, or switch to layout: \"linear\"",
      )
    }
  }
  _validate-graph-positions(where, positions, node-ids)
  if layout != "manual" { return }
  for node-id in node-ids {
    if node-id in positions { continue }
    fail(
      where,
      "layout \"manual\" has no position for node \"" + node-id + "\"",
      expected: "a positions: entry for every node: " + show-list(node-ids),
      fix: "add \"" + node-id + "\": (x, y), or use layout: \"auto\"",
    )
  }
}

#let _validate-graph-arguments(
  where,
  adjacency,
  directed,
  labels,
  positions,
  layout,
  radius,
  gap,
  edge-customizations,
  node-customizations,
  node-labels,
  style,
) = {
  _validate-graph-adjacency(where, adjacency)
  check-bool(where, "directed:", directed)
  validate-style(where, style)
  let node-ids = _collect-graph-node-ids(adjacency)
  _validate-graph-layout(where, layout, radius, gap, positions, node-ids)
  check-dictionary(
    where, "labels:", labels,
    fix: "pass a dictionary keyed by node name, for example labels: (\"a\": [$alpha$])",
  )
  check-id-value-references(where, "labels:", labels, node-ids)
  check-id-value-references(where, "node-labels:", node-labels, node-ids)
  for (_, label-value) in normalize-id-value-entries(where, "node-labels:", node-labels) {
    check-node-label-override(where, "node-labels: entry", label-value)
  }
  check-customization-entries(
    where,
    "node-customizations:",
    node-customizations,
    2,
    check-node-customization-options,
  )
  for (node-id, _) in node-customizations {
    check-reference(where, "node-customizations:", node-id, node-ids)
  }
  _validate-graph-edge-references(where, adjacency, directed, edge-customizations)
  node-ids
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
) = {
  let _ = _validate-graph-arguments(
    "graph()", adjacency, directed, labels, positions, layout, radius, gap,
    edge-customizations, node-customizations, node-labels, style,
  )
  (
    diagram: _render-graph(adjacency, directed, labels, positions, layout, radius, gap, edge-customizations, node-customizations, node-labels, resolve(style)),
  )
}

// ── Algorithm traces ────────────────────────────────────────────────────────

#let _collect-graph-neighbors(adjacency, node-id, directed) = {
  let neighbors = ()
  if node-id in adjacency {
    for edge-entry in adjacency.at(node-id) {
      neighbors.push((
        node: _edge-target-id(edge-entry),
        weight: _edge-display-label(edge-entry),
      ))
    }
  }
  if not directed {
    for from-node-id in adjacency.keys() {
      for edge-entry in adjacency.at(from-node-id) {
        let is-incoming-edge = _edge-target-id(edge-entry) == node-id
        let neighbor-is-recorded = neighbors.position(
          neighbor => neighbor.node == from-node-id,
        ) != none
        if is-incoming-edge and not neighbor-is-recorded {
          neighbors.push((
            node: from-node-id,
            weight: _edge-display-label(edge-entry),
          ))
        }
      }
    }
  }
  neighbors
}

#let _build-graph-state-node-customizations(
  base-customizations,
  node-ids,
  visited-node-ids,
  current-node-id,
  frontier-node-ids,
  resolved-style,
) = {
  let state-customizations = ()
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(
      base-customizations,
      node-id,
    )
    if node-customization == none { node-customization = (:) }
    let state-style = if node-id == current-node-id {
      resolved-style.current-style
    } else if node-id in frontier-node-ids {
      resolved-style.queued-style
    } else if node-id in visited-node-ids {
      resolved-style.visited-style
    } else {
      none
    }
    if state-style != none { node-customization += state-style }
    if node-customization.len() > 0 {
      state-customizations.push((node-id, node-customization))
    }
  }
  state-customizations
}

#let _graph-edges-match(
  candidate-from-id,
  candidate-to-id,
  from-node-id,
  to-node-id,
  directed,
) = if directed {
  candidate-from-id == from-node-id and candidate-to-id == to-node-id
} else {
  (
    candidate-from-id == from-node-id and candidate-to-id == to-node-id
  ) or (
    candidate-from-id == to-node-id and candidate-to-id == from-node-id
  )
}

#let _path-to-graph-edges(path) = {
  let path-edges = ()
  for path-index in range(path.len() - 1) {
    path-edges.push((path.at(path-index), path.at(path-index + 1)))
  }
  path-edges
}

#let _build-graph-state-edge-customizations(
  base-customizations,
  active-edge,
  path,
  directed,
  resolved-style,
) = {
  let highlighted-edges = if active-edge == none {
    _path-to-graph-edges(path)
  } else {
    (active-edge,) + _path-to-graph-edges(path)
  }
  if highlighted-edges.len() == 0 { return base-customizations }
  let state-customizations = ()
  for (from-node-id, to-node-id) in highlighted-edges {
    let existing-customization = _resolve-graph-edge-customization(
      base-customizations,
      from-node-id,
      to-node-id,
      directed,
    )
    let highlighted-customization = (
      if existing-customization == none { (:) } else { existing-customization }
    ) + resolved-style.active-edge-style
    state-customizations.push((
      from-node-id,
      to-node-id,
      highlighted-customization,
    ))
  }
  for (from-node-id, to-node-id, customization) in base-customizations {
    let edge-is-highlighted = highlighted-edges.any(edge => (
      _graph-edges-match(
        from-node-id,
        to-node-id,
        edge.at(0),
        edge.at(1),
        directed,
      )
    ))
    if not edge-is-highlighted {
      state-customizations.push((
        from-node-id,
        to-node-id,
        customization,
      ))
    }
  }
  state-customizations
}

#let _build-distance-node-labels(
  node-ids,
  distances,
  supplied-labels,
  resolved-style,
  message-catalog,
) = {
  let distance-labels = ()
  for node-id in node-ids {
    let supplied-label = _lookup-graph-node-value(supplied-labels, node-id)
    let distance-value = if distances.at(node-id) == none {
      $infinity$
    } else {
      distances.at(node-id)
    }
    let label-body = msg(
      message-catalog,
      "graph.distance",
      distance-value,
    )
    let label-customization = (
      color: rgb("#7048E8"),
      weight: "bold",
    )
    let label-defaults = resolved-style.at("node-labels", default: (:))
    if "gap" not in label-defaults { label-customization.gap = 0.5 }
    if type(supplied-label) == dictionary {
      label-customization += supplied-label
    }
    label-customization.content = label-body
    distance-labels.push((node-id, label-customization))
  }
  distance-labels
}

#let _create-graph-algorithm-step(
  label, adjacency, directed, labels, positions, layout, radius,
  edge-customizations, node-customizations, node-labels, style,
  visited, current, queued, active,
  captions, distances: none, path: (), gap: auto, cat: default-catalog,
) = {
  let resolved-style = resolve(style)
  let node-ids = _collect-graph-node-ids(adjacency)
  let state-node-customizations = _build-graph-state-node-customizations(
    node-customizations,
    node-ids,
    visited,
    current,
    queued,
    resolved-style,
  )
  let state-edge-customizations = _build-graph-state-edge-customizations(
    edge-customizations,
    active,
    path,
    directed,
    resolved-style,
  )
  let state-node-labels = if distances == none {
    node-labels
  } else {
    _build-distance-node-labels(
      node-ids,
      distances,
      node-labels,
      resolved-style,
      cat,
    )
  }
  let graph-diagram = _render-graph(
    adjacency,
    directed,
    labels,
    positions,
    layout,
    radius,
    gap,
    state-edge-customizations,
    state-node-customizations,
    state-node-labels,
    resolved-style,
  )
  (
    label: label,
    current: current,
    visited: visited,
    queued: queued,
    active-edge: active,
    path: path,
    diagram: align(center)[
      #if captions [#text(..resolved-style.algorithm-label-text)[#label] #v(0.25em)]
      #graph-diagram
    ],
  ) + if distances == none { (:) } else { (distances: distances,) }
}

#let _create-graph-trace-result(steps, result, columns, row-gap) = (
  steps: steps,
  result: result,
  diagram: grid(columns: columns, column-gutter: row-gap, row-gutter: row-gap, ..steps.map(step => step.diagram)),
)

#let _reconstruct-graph-path(previous, source, target, found) = {
  if target == none or not found { return () }
  let reverse-path = (target,)
  let current-node-id = target
  while current-node-id != source {
    current-node-id = previous.at(current-node-id, default: none)
    if current-node-id == none { return () }
    reverse-path.push(current-node-id)
  }
  reverse-path.rev()
}

// Every trace shares the same argument surface as `graph()`, plus its
// endpoints and presentation options.
#let _validate-graph-traversal(
  where, adjacency, source, target, directed, labels, positions, layout, radius,
  gap, edge-customizations, node-customizations, node-labels, style, columns,
  captions,
) = {
  let node-ids = _validate-graph-arguments(
    where, adjacency, directed, labels, positions, layout, radius, gap,
    edge-customizations, node-customizations, node-labels, style,
  )
  check-integer(where, "columns:", columns, min: 1)
  check-bool(where, "captions:", captions)
  check-reference(where, "source", source, node-ids)
  if target != none {
    check-reference(where, "target:", target, node-ids)
  }
  node-ids
}

// Weights are checked across the whole graph before the search starts, so an
// unusable weight on an edge the search never relaxes still fails at the call.
// An unlabelled edge is weight 1 by definition.
#let _validate-dijkstra-weights(where, adjacency) = {
  for (from-node-id, edge-entries) in adjacency {
    for edge-entry in edge-entries {
      let edge-weight = _edge-display-label(edge-entry)
      if edge-weight == none { continue }
      let to-node-id = _edge-target-id(edge-entry)
      let edge-name = "edge " + from-node-id + " -> " + to-node-id
      if not is-number(edge-weight) {
        fail(
          where,
          edge-name + " has weight " + show-value(edge-weight) + ", which is not a number",
          expected: "a non-negative number, or no label for weight 1",
          fix: "write the weight as a number, for example (\"" + to-node-id + "\", 4)",
        )
      }
      if edge-weight < 0 {
        fail(
          where,
          edge-name + " has weight " + show-value(edge-weight),
          expected: "a non-negative weight; Dijkstra's algorithm requires it",
          fix: "use a non-negative weight, or a different shortest-path algorithm",
        )
      }
    }
  }
}

#let _should-relax-edge(current-distance, edge-weight, neighbor-distance) = (
  neighbor-distance == none or current-distance + edge-weight < neighbor-distance
)

#let _select-closest-unvisited-node(node-ids, distances, visited-node-ids) = {
  let closest-node-id = none
  for node-id in node-ids {
    let node-is-reachable = distances.at(node-id) != none
    if node-id not in visited-node-ids and node-is-reachable {
      let node-is-closer = if closest-node-id == none {
        true
      } else {
        distances.at(node-id) < distances.at(closest-node-id)
      }
      if node-is-closer { closest-node-id = node-id }
    }
  }
  closest-node-id
}

#let bfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  goal-test: "discovery", language: "en", messages: (:),
) = {
  check-enum("bfs()", "goal-test:", goal-test, ("discovery", "expansion"))
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "bfs()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  let queue = (source,)
  let discovered-node-ids = (:)
  discovered-node-ids.insert(source, true)
  let visited-node-ids = ()
  let traversal-order = ()
  let previous-node-by-id = (:)
  let steps = ()
  let create-step(label, state-visited, state-queued, current: none, active: none) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-queued, active, captions,
    gap: gap, cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.queue", source),
    visited-node-ids,
    queue,
  ))
  if target == source {
    traversal-order.push(source)
    visited-node-ids.push(source)
    steps.push(create-step(
      msg(message-catalog, "graph.reached", target),
      visited-node-ids,
      (),
    ))
    return _create-graph-trace-result(
      steps,
      (order: traversal-order, found: true, path: (source,)),
      columns,
      row-gap,
    )
  }
  while queue.len() > 0 {
    let current-node-id = queue.first()
    queue = queue.slice(1)
    steps.push(create-step(
      msg(message-catalog, "graph.visit", current-node-id),
      visited-node-ids,
      queue,
      current: current-node-id,
    ))
    traversal-order.push(current-node-id)
    let reached-target-on-expansion = (
      goal-test == "expansion"
        and target != none
        and current-node-id == target
    )
    if reached-target-on-expansion {
      visited-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.reached", target),
        visited-node-ids,
        queue,
      ))
      break
    }
    let has-discovered-target = false
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      let neighbor-is-new = neighbor-node-id not in discovered-node-ids
      if neighbor-is-new {
        discovered-node-ids.insert(neighbor-node-id, true)
        previous-node-by-id.insert(neighbor-node-id, current-node-id)
        queue.push(neighbor-node-id)
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.inspect",
          current-node-id,
          neighbor-node-id,
        ),
        visited-node-ids,
        queue,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
      let reached-target-on-discovery = (
        goal-test == "discovery"
          and target != none
          and neighbor-is-new
          and neighbor-node-id == target
      )
      if reached-target-on-discovery {
        visited-node-ids.push(current-node-id)
        steps.push(create-step(
          msg(message-catalog, "graph.reached", target),
          visited-node-ids,
          queue,
          current: target,
        ))
        has-discovered-target = true
        break
      }
    }
    if has-discovered-target { break }
    visited-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      visited-node-ids,
      queue,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    target in discovered-node-ids
  }
  _create-graph-trace-result(
    steps,
    (
      order: traversal-order,
      found: found-target,
      path: _reconstruct-graph-path(
        previous-node-by-id,
        source,
        target,
        found-target == true,
      ),
    ),
    columns,
    row-gap,
  )
}

#let dfs(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "dfs()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  let stack = (source,)
  let discovered-node-ids = (:)
  discovered-node-ids.insert(source, true)
  let visited-node-ids = ()
  let traversal-order = ()
  let previous-node-by-id = (:)
  let steps = ()
  let create-step(label, state-visited, state-frontier, current: none, active: none) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-visited, current, state-frontier, active, captions,
    gap: gap, cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.stack", source),
    visited-node-ids,
    stack,
  ))
  while stack.len() > 0 {
    let current-node-id = stack.last()
    stack = stack.slice(0, stack.len() - 1)
    steps.push(create-step(
      msg(message-catalog, "graph.visit", current-node-id),
      visited-node-ids,
      stack,
      current: current-node-id,
    ))
    traversal-order.push(current-node-id)
    if target != none and current-node-id == target {
      visited-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.reached", target),
        visited-node-ids,
        stack,
      ))
      break
    }
    let newly-discovered-node-ids = ()
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      if neighbor-node-id not in discovered-node-ids {
        discovered-node-ids.insert(neighbor-node-id, true)
        previous-node-by-id.insert(neighbor-node-id, current-node-id)
        newly-discovered-node-ids.push(neighbor-node-id)
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.inspect",
          current-node-id,
          neighbor-node-id,
        ),
        visited-node-ids,
        stack + newly-discovered-node-ids,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
    }
    stack += newly-discovered-node-ids.rev()
    visited-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      visited-node-ids,
      stack,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    target in discovered-node-ids
  }
  _create-graph-trace-result(
    steps,
    (
      order: traversal-order,
      found: found-target,
      path: _reconstruct-graph-path(
        previous-node-by-id,
        source,
        target,
        found-target == true,
      ),
    ),
    columns,
    row-gap,
  )
}

#let dijkstra(
  adjacency, source, target: none, directed: true, labels: (:), positions: (:),
  layout: "auto", radius: auto, gap: auto, edge-customizations: (), node-customizations: (),
  node-labels: (:), style: (:), columns: 1, row-gap: 0.8em, captions: true,
  language: "en", messages: (:),
) = {
  let message-catalog = resolve-catalog(language: language, messages: messages)
  let node-ids = _validate-graph-traversal(
    "dijkstra()", adjacency, source, target, directed, labels, positions, layout,
    radius, gap, edge-customizations, node-customizations, node-labels, style,
    columns, captions,
  )
  _validate-dijkstra-weights("dijkstra()", adjacency)
  let distances = (:)
  for node-id in node-ids {
    distances.insert(node-id, if node-id == source { 0 } else { none })
  }
  let previous-node-by-id = (:)
  let settled-node-ids = ()
  let settlement-order = ()
  let steps = ()
  let frontier-node-ids(state-distances, state-settled, current: none) = (
    node-ids.filter(node-id => (
      state-distances.at(node-id) != none
        and node-id not in state-settled
        and node-id != current
    ))
  )
  let create-step(label, state-settled, state-distances, current: none, active: none, path: ()) = _create-graph-algorithm-step(
    label, adjacency, directed, labels, positions, layout, radius,
    edge-customizations, node-customizations, node-labels, style,
    state-settled,
    current,
    frontier-node-ids(state-distances, state-settled, current: current),
    active,
    captions,
    distances: state-distances,
    path: path,
    gap: gap,
    cat: message-catalog,
  )
  steps.push(create-step(
    msg(message-catalog, "graph.distance-init", source),
    settled-node-ids,
    distances,
  ))
  while true {
    let current-node-id = _select-closest-unvisited-node(
      node-ids,
      distances,
      settled-node-ids,
    )
    if current-node-id == none { break }
    steps.push(create-step(
      msg(message-catalog, "graph.settle", current-node-id),
      settled-node-ids,
      distances,
      current: current-node-id,
    ))
    settlement-order.push(current-node-id)
    if target != none and current-node-id == target {
      settled-node-ids.push(current-node-id)
      steps.push(create-step(
        msg(message-catalog, "graph.shortest-path", target),
        settled-node-ids,
        distances,
        path: _reconstruct-graph-path(
          previous-node-by-id,
          source,
          target,
          true,
        ),
      ))
      break
    }
    for neighbor in _collect-graph-neighbors(
      adjacency,
      current-node-id,
      directed,
    ) {
      let neighbor-node-id = neighbor.node
      let edge-weight = if neighbor.weight == none { 1 } else { neighbor.weight }
      if neighbor-node-id not in settled-node-ids {
        let current-distance = distances.at(current-node-id)
        let neighbor-distance = distances.at(neighbor-node-id)
        if _should-relax-edge(
          current-distance,
          edge-weight,
          neighbor-distance,
        ) {
          distances.insert(
            neighbor-node-id,
            current-distance + edge-weight,
          )
          previous-node-by-id.insert(neighbor-node-id, current-node-id)
        }
      }
      steps.push(create-step(
        msg(
          message-catalog,
          "graph.relax",
          current-node-id,
          neighbor-node-id,
        ),
        settled-node-ids,
        distances,
        current: current-node-id,
        active: (current-node-id, neighbor-node-id),
      ))
    }
    settled-node-ids.push(current-node-id)
    steps.push(create-step(
      msg(message-catalog, "graph.finish", current-node-id),
      settled-node-ids,
      distances,
    ))
  }
  let found-target = if target == none {
    none
  } else {
    distances.at(target) != none
  }
  _create-graph-trace-result(steps, (
    distances: distances,
    previous: previous-node-by-id,
    order: settlement-order,
    found: found-target,
    path: _reconstruct-graph-path(
      previous-node-by-id,
      source,
      target,
      found-target == true,
    ),
  ), columns, row-gap)
}
