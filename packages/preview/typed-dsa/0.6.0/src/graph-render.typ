// CeTZ rendering for validated graph state and resolved graph layouts.

#import "@preview/cetz:0.5.2"
#import "style.typ": (
  theme, scaled, edge-stroke, edge-arrow, edge-wave, wavy-parts,
)
#import cetz.draw: line, circle, rect, content, bezier-through
#import "graph-model.typ": (
  _collect-graph-edges, _collect-graph-node-ids, _edge-display-label,
  _normalize-undirected-edge-key,
)
#import "graph-layout.typ": (
  _calculate-graph-edge-bend-point, _calculate-node-boundary-radius,
  _resolve-graph-node-radius,
  _resolve-graph-node-shape, _trim-edge-to-node-boundary,
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

#let _render-graph-at-positions(
  adjacency,
  directed,
  labels,
  node-positions,
  edge-customizations,
  node-customizations,
  node-labels,
  resolved-style,
) = {
  let node-ids = _collect-graph-node-ids(adjacency)
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
