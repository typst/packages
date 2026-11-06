// CeTZ rendering for validated graph state and resolved graph layouts.

#import "@preview/cetz:0.5.2"
#import "../shared/style.typ": (
  theme, scaled, edge-stroke, edge-arrow, edge-wave, wavy-parts,
)
#import cetz.draw: line, circle, rect, content, bezier-through, bezier
#import "model.typ": (
  _collect-graph-edges, _collect-graph-node-ids, _edge-display-label,
  _normalize-undirected-edge-key,
)
#import "layout.typ": (
  _calculate-graph-edge-bend-point, _calculate-node-boundary-radius, _calculate-graph-loop-geometry,
  _default-node-half-width, _fitted-node-half-width,
  _resolve-graph-node-radius, _resolve-graph-node-shape, _trim-edge-to-node-boundary,
)

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

#let _resolve-graph-edge-routing(graph-edges, from-node-id, to-node-id, directed, edge-routing, custom) = {
  let options = if custom == none { (:) } else { custom }
  let has-reciprocal-edge = graph-edges.any(edge => (
    edge.at(0) == to-node-id and edge.at(1) == from-node-id
  ))
  let should-route-reciprocal-edge = (
    edge-routing == "auto" and directed and from-node-id != to-node-id
      and has-reciprocal-edge and "bend" not in options
  )
  if should-route-reciprocal-edge {
    options.bend = "left"
  }
  options
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

// A node boundary is `(shape, radius, half-width)`: `radius` is the half-height,
// and `half-width` is the measured width for node-fit nodes.
#let _trim-edge-to-boundary(node-position, toward-position, boundary) = _trim-edge-to-node-boundary(
  node-position,
  toward-position,
  boundary.at(1),
  shape: boundary.at(0),
  half-width: boundary.at(2),
)

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
    let a = _trim-edge-to-boundary(p, q, from-boundary)
    let b = _trim-edge-to-boundary(q, p, to-boundary)
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
    let p2 = _trim-edge-to-boundary(p, bp, from-boundary)
    let q2 = _trim-edge-to-boundary(q, bp, to-boundary)
    bezier-through(p2, bp, q2, stroke: stroke, mark: mark)
  }
}

#let _render-graph-edge-label(label, p, q, r, resolved-style, custom) = {
  let displayed-label = label
  let label-options = if custom == none { none } else { custom.at("label", default: none) }
  if custom != none and "label" in custom {
    if type(label-options) == dictionary {
      displayed-label = label-options.at("content", default: label-options.at("body", default: label))
    } else { displayed-label = label-options }
  }
  if displayed-label == none { return }
  let pt = _calculate-edge-label-position(p, q, r, custom, resolved-style)

  let label-style = resolved-style.edge-label-text
  let rotation = label-style.at("rotation", default: 0deg)

  if custom != none and "label" in custom {
    let l-custom = custom.label
    if type(l-custom) == dictionary {
      if "content" in l-custom { let _ = l-custom.remove("content") }
      if "body" in l-custom { let _ = l-custom.remove("body") }
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

  content(pt, text(..label-style)[#displayed-label], angle: rotation)
}

#let _render-graph-self-loop(position, boundary, label, directed, resolved-style, custom) = {
  let geometry = _calculate-graph-loop-geometry(
    position, boundary, bend: custom.at("bend", default: false),
  )
  bezier(
    geometry.start, geometry.end, geometry.control-start, geometry.control-end,
    stroke: edge-stroke(resolved-style, custom: custom),
    mark: edge-arrow(resolved-style, directed, custom: custom),
  )
  let label-override = custom.at("label", default: (:))
  let label-size = if type(label-override) == dictionary {
    label-override.at("size", default: resolved-style.edge-label-text.at("size", default: 9pt))
  } else { resolved-style.edge-label-text.at("size", default: 9pt) }
  let label-gap = if type(label-size) == length {
    (label-size / 1pt) * 0.6 / 28.346
  } else { 0.22 }
  let label-position = (geometry.label.at(0), geometry.label.at(1) + geometry.side * label-gap)
  _render-graph-edge-label(label, label-position, label-position, 0, resolved-style, custom)
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
    half-width: boundary.at(2),
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

// The text a node label is drawn with: the value-text role plus the node's
// `text:` customization. The rotation is split off because `text()` does not
// take it. Measuring and drawing both use this, so node-fit sees drawn text.
#let _resolve-graph-node-text(resolved-style, custom) = {
  let text-style = resolved-style.value-text
  if custom != none and "text" in custom { text-style = text-style + custom.text }
  text-style = _normalize-graph-text-style(text-style)
  let rotation = text-style.at("rotation", default: 0deg)
  if "rotation" in text-style { let _ = text-style.remove("rotation") }
  (style: text-style, rotation: rotation)
}

// Labels are measured in their drawn text style. `measure` needs the document
// styles, so callers must invoke this inside a `context` block.
#let _measure-fitted-node-half-widths(node-ids, labels, resolved-style, node-customizations) = {
  let measured-half-widths = (:)
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(node-customizations, node-id)
    let shape = _resolve-graph-node-shape(resolved-style, node-customization)
    let radius = _resolve-graph-node-radius(resolved-style, node-customization)
    let node-text = _resolve-graph-node-text(resolved-style, node-customization)
    let label-box = measure(text(..node-text.style, labels.at(node-id, default: node-id)))
    measured-half-widths.insert(
      node-id,
      _fitted-node-half-width(label-box.width / 1cm, shape, radius),
    )
  }
  measured-half-widths
}

// A node's boundary is `(shape, radius, half-width)`. Nodes that are not
// fitted use the default half-width for their shape.
#let _resolve-graph-node-boundary(resolved-style, custom, measured-half-width) = {
  let shape = _resolve-graph-node-shape(resolved-style, custom)
  let radius = _resolve-graph-node-radius(resolved-style, custom)
  let half-width = if measured-half-width == none {
    _default-node-half-width(shape, radius)
  } else {
    measured-half-width
  }
  (shape, radius, half-width)
}

#let _render-graph-node(label, p, boundary, resolved-style, custom) = {
  let shape = boundary.at(0)
  let r = boundary.at(1)
  let half-width = boundary.at(2)
  let fill = if custom != none and "fill" in custom { custom.fill } else { resolved-style.node-fill }
  let stroke = if custom != none and "stroke" in custom { custom.stroke } else { resolved-style.node-stroke }
  let node-text = _resolve-graph-node-text(resolved-style, custom)
  let polygon = pts => line(..pts, close: true, fill: fill, stroke: stroke)
  if shape == "square" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), fill: fill, stroke: stroke)
  } else if shape == "rounded" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), radius: 25%, fill: fill, stroke: stroke)
  } else if shape == "capsule" {
    rect((p.at(0) - half-width, p.at(1) - r), (p.at(0) + half-width, p.at(1) + r), radius: 50%, fill: fill, stroke: stroke)
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
  content(p, text(..node-text.style, label), angle: node-text.rotation)
}

// Draws the graph once every node's boundary is known. `measured-half-widths`
// maps node ids to fitted half-widths, or is empty when no node is fitted.
#let _draw-graph-at-positions(
  adjacency,
  directed,
  labels,
  node-positions,
  edge-customizations,
  node-customizations,
  node-labels,
  resolved-style,
  edge-routing,
  measured-half-widths,
) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let graph-edges = _collect-graph-edges(adjacency, directed)
  let node-boundaries = (:)
  for node-id in node-ids {
    let node-customization = _resolve-graph-node-customization(
      node-customizations,
      node-id,
    )
    node-boundaries.insert(node-id, _resolve-graph-node-boundary(
      resolved-style,
      node-customization,
      measured-half-widths.at(node-id, default: none),
    ))
  }

  scaled(resolved-style, cetz.canvas({
    for (from-node-id, to-node-id, edge-label) in graph-edges {
      let edge-customization = _resolve-graph-edge-customization(
        edge-customizations,
        from-node-id,
        to-node-id,
        directed,
      )
      edge-customization = _resolve-graph-edge-routing(
        graph-edges, from-node-id, to-node-id, directed, edge-routing, edge-customization,
      )
      let from-boundary = node-boundaries.at(from-node-id)
      let to-boundary = node-boundaries.at(to-node-id)
      if from-node-id == to-node-id {
        _render-graph-self-loop(
          node-positions.at(from-node-id), from-boundary, edge-label,
          directed, resolved-style, edge-customization,
        )
      } else {
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
    }
    for node-id in node-ids {
      let node-customization = _resolve-graph-node-customization(
        node-customizations,
        node-id,
      )
      let node-boundary = node-boundaries.at(node-id)
      _render-graph-node(
        labels.at(node-id, default: node-id),
        node-positions.at(node-id),
        node-boundary,
        resolved-style,
        node-customization,
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

#let _render-graph-at-positions(
  adjacency,
  directed,
  labels,
  node-positions,
  edge-customizations,
  node-customizations,
  node-labels,
  resolved-style,
  edge-routing: "manual",
) = {
  if not resolved-style.node-fit {
    return _draw-graph-at-positions(
      adjacency, directed, labels, node-positions, edge-customizations,
      node-customizations, node-labels, resolved-style, edge-routing, (:),
    )
  }
  let node-ids = _collect-graph-node-ids(adjacency)
  context _draw-graph-at-positions(
    adjacency, directed, labels, node-positions, edge-customizations,
    node-customizations, node-labels, resolved-style, edge-routing,
    _measure-fitted-node-half-widths(node-ids, labels, resolved-style, node-customizations),
  )
}
