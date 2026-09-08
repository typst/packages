// Graph node placement and edge geometry calculations.

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
