// Graph node placement and edge geometry calculations.

#import "graph-model.typ": (
  _collect-graph-connected-components, _collect-graph-edges,
  _collect-graph-node-ids, _edge-target-id, _topologically-order-graph-nodes,
)

#let _force-layout-defaults = (
  edge-length: 1.8,
  repulsion: 1.0,
  attraction: 1.0,
  node-edge-repulsion: 1.0,
  node-edge-clearance: 0.25,
  iterations: 60,
  component-gap: 2.5,
)

#let _layered-layout-defaults = (
  direction: "right",
  layer-gap: 2.2,
  node-gap: 1.4,
  crossing-sweeps: 4,
)

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

#let _add-graph-displacement(displacements, node-id, delta-x, delta-y) = {
  let current-displacement = displacements.at(node-id)
  displacements.insert(node-id, (
    current-displacement.at(0) + delta-x,
    current-displacement.at(1) + delta-y,
  ))
  displacements
}

#let _center-graph-positions(node-positions, node-ids) = {
  if node-ids.len() == 0 { return node-positions }
  let center-x = 0.0
  let center-y = 0.0
  for node-id in node-ids {
    center-x += node-positions.at(node-id).at(0)
    center-y += node-positions.at(node-id).at(1)
  }
  center-x /= node-ids.len()
  center-y /= node-ids.len()
  for node-id in node-ids {
    let node-position = node-positions.at(node-id)
    node-positions.insert(node-id, (
      node-position.at(0) - center-x,
      node-position.at(1) - center-y,
    ))
  }
  node-positions
}

#let _select-force-initial-slot(node-index, node-count, start-variant) = {
  if start-variant == 1 {
    return if calc.rem(node-index, 2) == 0 {
      node-index / 2
    } else {
      node-count - 1 - calc.floor(node-index / 2)
    }
  }
  if start-variant == 2 {
    return if calc.rem(node-index, 2) == 0 {
      calc.min(node-index + 1, node-count - 1)
    } else {
      node-index - 1
    }
  }
  node-index
}

#let _initialize-force-component(component-node-ids, edge-length, start-variant) = {
  let node-positions = (:)
  let node-count = component-node-ids.len()
  if node-count == 1 {
    node-positions.insert(component-node-ids.first(), (0.0, 0.0))
    return node-positions
  }
  let initial-radius = edge-length * calc.max(1.0, node-count / 6.283185)
  for (node-index, node-id) in component-node-ids.enumerate() {
    let initial-slot = _select-force-initial-slot(
      node-index, node-count, start-variant,
    )
    let node-angle = 90deg - 360deg * initial-slot / node-count
    let radial-perturbation = 0.85 + 0.3 * (initial-slot + 1) / node-count
    node-positions.insert(node-id, (
      initial-radius * radial-perturbation * calc.cos(node-angle),
      initial-radius * radial-perturbation * calc.sin(node-angle),
    ))
  }
  node-positions
}

#let _calculate-force-cooling(edge-length, iteration, iterations) = {
  let remaining-fraction = 1.0 - iteration / iterations
  edge-length * calc.max(0.02, remaining-fraction)
}

#let _project-point-to-graph-edge(node-position, from-position, to-position) = {
  let edge-delta-x = to-position.at(0) - from-position.at(0)
  let edge-delta-y = to-position.at(1) - from-position.at(1)
  let squared-edge-length = (
    edge-delta-x * edge-delta-x + edge-delta-y * edge-delta-y
  )
  if squared-edge-length == 0 {
    let delta-x = node-position.at(0) - from-position.at(0)
    let delta-y = node-position.at(1) - from-position.at(1)
    return (
      point: from-position,
      edge-fraction: 0.0,
      distance: calc.sqrt(delta-x * delta-x + delta-y * delta-y),
    )
  }
  let node-delta-x = node-position.at(0) - from-position.at(0)
  let node-delta-y = node-position.at(1) - from-position.at(1)
  let edge-fraction = calc.max(0.0, calc.min(
    1.0,
    (
      node-delta-x * edge-delta-x + node-delta-y * edge-delta-y
    ) / squared-edge-length,
  ))
  let closest-point = (
    from-position.at(0) + edge-fraction * edge-delta-x,
    from-position.at(1) + edge-fraction * edge-delta-y,
  )
  let closest-delta-x = node-position.at(0) - closest-point.at(0)
  let closest-delta-y = node-position.at(1) - closest-point.at(1)
  (
    point: closest-point,
    edge-fraction: edge-fraction,
    distance: calc.sqrt(
      closest-delta-x * closest-delta-x + closest-delta-y * closest-delta-y,
    ),
  )
}

#let _select-node-edge-separation-direction(
  node-position,
  from-position,
  to-position,
  projection,
  node-index,
  edge-index,
) = {
  let delta-x = node-position.at(0) - projection.point.at(0)
  let delta-y = node-position.at(1) - projection.point.at(1)
  if projection.distance > 0.0001 {
    return (delta-x / projection.distance, delta-y / projection.distance)
  }
  let edge-delta-x = to-position.at(0) - from-position.at(0)
  let edge-delta-y = to-position.at(1) - from-position.at(1)
  let edge-length = calc.sqrt(
    edge-delta-x * edge-delta-x + edge-delta-y * edge-delta-y,
  )
  if edge-length == 0 { return (1.0, 0.0) }
  let direction-sign = if calc.rem(node-index + edge-index, 2) == 0 { 1 } else { -1 }
  (
    direction-sign * -edge-delta-y / edge-length,
    direction-sign * edge-delta-x / edge-length,
  )
}

#let _resolve-node-edge-clearance(
  node-id,
  node-position,
  from-position,
  to-position,
  projection,
  node-boundaries,
  node-edge-clearance,
  node-index,
  edge-index,
) = {
  let separation-direction = _select-node-edge-separation-direction(
    node-position,
    from-position,
    to-position,
    projection,
    node-index,
    edge-index,
  )
  let node-boundary = node-boundaries.at(node-id)
  let required-clearance = _calculate-node-boundary-radius(
    node-boundary.shape,
    node-boundary.radius,
    separation-direction.at(0),
    separation-direction.at(1),
  ) + node-edge-clearance
  (
    direction: separation-direction,
    required: required-clearance,
  )
}

#let _apply-force-node-edge-repulsion(
  component-node-ids,
  component-edges,
  node-positions,
  node-boundaries,
  displacements,
  options,
) = {
  for (edge-index, edge) in component-edges.enumerate() {
    let from-node-id = edge.at(0)
    let to-node-id = edge.at(1)
    if from-node-id == to-node-id { continue }
    let from-position = node-positions.at(from-node-id)
    let to-position = node-positions.at(to-node-id)
    for (node-index, node-id) in component-node-ids.enumerate() {
      if node-id in (from-node-id, to-node-id) { continue }
      let node-position = node-positions.at(node-id)
      let projection = _project-point-to-graph-edge(
        node-position, from-position, to-position,
      )
      let clearance = _resolve-node-edge-clearance(
        node-id,
        node-position,
        from-position,
        to-position,
        projection,
        node-boundaries,
        options.node-edge-clearance,
        node-index,
        edge-index,
      )
      if projection.distance >= clearance.required { continue }
      let penetration = clearance.required - projection.distance
      let force = options.node-edge-repulsion * options.edge-length * (
        0.25 + penetration / clearance.required
      )
      let force-x = clearance.direction.at(0) * force
      let force-y = clearance.direction.at(1) * force
      displacements = _add-graph-displacement(
        displacements, node-id, force-x, force-y,
      )
      let endpoint-reaction = 0.5
      displacements = _add-graph-displacement(
        displacements,
        from-node-id,
        -force-x * (1 - projection.edge-fraction) * endpoint-reaction,
        -force-y * (1 - projection.edge-fraction) * endpoint-reaction,
      )
      displacements = _add-graph-displacement(
        displacements,
        to-node-id,
        -force-x * projection.edge-fraction * endpoint-reaction,
        -force-y * projection.edge-fraction * endpoint-reaction,
      )
    }
  }
  displacements
}

#let _resolve-force-node-boundaries(
  node-ids,
  resolved-style,
  node-customizations,
) = {
  let node-boundaries = (:)
  for node-id in node-ids {
    let node-customization = none
    for (custom-node-id, customization) in node-customizations {
      if custom-node-id == node-id {
        node-customization = customization
        break
      }
    }
    node-boundaries.insert(node-id, (
      shape: _resolve-graph-node-shape(resolved-style, node-customization),
      radius: _resolve-graph-node-radius(resolved-style, node-customization),
    ))
  }
  node-boundaries
}

#let _scale-force-component-for-node-edge-clearance(
  component-node-ids,
  component-edges,
  node-positions,
  node-boundaries,
  options,
) = {
  let required-scale = 1.0
  for (edge-index, edge) in component-edges.enumerate() {
    let from-node-id = edge.at(0)
    let to-node-id = edge.at(1)
    if from-node-id == to-node-id { continue }
    let from-position = node-positions.at(from-node-id)
    let to-position = node-positions.at(to-node-id)
    for (node-index, node-id) in component-node-ids.enumerate() {
      if node-id in (from-node-id, to-node-id) { continue }
      let node-position = node-positions.at(node-id)
      let projection = _project-point-to-graph-edge(
        node-position, from-position, to-position,
      )
      let clearance = _resolve-node-edge-clearance(
        node-id,
        node-position,
        from-position,
        to-position,
        projection,
        node-boundaries,
        options.node-edge-clearance,
        node-index,
        edge-index,
      )
      if projection.distance < clearance.required {
        required-scale = calc.max(
          required-scale,
          (clearance.required + 0.01) / calc.max(projection.distance, 0.0001),
        )
      }
    }
  }
  if required-scale == 1.0 { return node-positions }
  for node-id in component-node-ids {
    let node-position = node-positions.at(node-id)
    node-positions.insert(node-id, (
      node-position.at(0) * required-scale,
      node-position.at(1) * required-scale,
    ))
  }
  node-positions
}

// The force simulation is approximate, so a bounded geometric pass establishes
// separation directions before uniform scaling establishes final clearance.
#let _resolve-force-node-edge-overlaps(
  component-node-ids,
  component-edges,
  node-positions,
  node-boundaries,
  options,
) = {
  let clearance-sweeps = 16
  for _ in range(clearance-sweeps) {
    let found-overlap = false
    for (edge-index, edge) in component-edges.enumerate() {
      let from-node-id = edge.at(0)
      let to-node-id = edge.at(1)
      if from-node-id == to-node-id { continue }
      let from-position = node-positions.at(from-node-id)
      let to-position = node-positions.at(to-node-id)
      for (node-index, node-id) in component-node-ids.enumerate() {
        if node-id in (from-node-id, to-node-id) { continue }
        let node-position = node-positions.at(node-id)
        let projection = _project-point-to-graph-edge(
          node-position, from-position, to-position,
        )
        let clearance = _resolve-node-edge-clearance(
          node-id,
          node-position,
          from-position,
          to-position,
          projection,
          node-boundaries,
          options.node-edge-clearance,
          node-index,
          edge-index,
        )
        if projection.distance >= clearance.required { continue }
        found-overlap = true
        let correction = clearance.required - projection.distance + 0.01
        node-positions.insert(node-id, (
          node-position.at(0) + clearance.direction.at(0) * correction,
          node-position.at(1) + clearance.direction.at(1) * correction,
        ))
      }
    }
    node-positions = _center-graph-positions(
      node-positions, component-node-ids,
    )
    if not found-overlap { break }
  }
  _scale-force-component-for-node-edge-clearance(
    component-node-ids,
    component-edges,
    node-positions,
    node-boundaries,
    options,
  )
}

#let _apply-force-repulsion(
  component-node-ids,
  node-positions,
  displacements,
  edge-length,
  repulsion,
) = {
  for left-index in range(component-node-ids.len()) {
    for right-index in range(left-index + 1, component-node-ids.len()) {
      let left-node-id = component-node-ids.at(left-index)
      let right-node-id = component-node-ids.at(right-index)
      let left-position = node-positions.at(left-node-id)
      let right-position = node-positions.at(right-node-id)
      let delta-x = left-position.at(0) - right-position.at(0)
      let delta-y = left-position.at(1) - right-position.at(1)
      let distance = calc.max(0.0001, calc.sqrt(delta-x * delta-x + delta-y * delta-y))
      let force = repulsion * edge-length * edge-length / distance
      let force-x = delta-x / distance * force
      let force-y = delta-y / distance * force
      displacements = _add-graph-displacement(
        displacements, left-node-id, force-x, force-y,
      )
      displacements = _add-graph-displacement(
        displacements, right-node-id, -force-x, -force-y,
      )
    }
  }
  displacements
}

#let _apply-force-attraction(
  component-edges,
  node-positions,
  displacements,
  edge-length,
  attraction,
) = {
  for (from-node-id, to-node-id, _) in component-edges {
    if from-node-id == to-node-id { continue }
    let from-position = node-positions.at(from-node-id)
    let to-position = node-positions.at(to-node-id)
    let delta-x = from-position.at(0) - to-position.at(0)
    let delta-y = from-position.at(1) - to-position.at(1)
    let distance = calc.max(0.0001, calc.sqrt(delta-x * delta-x + delta-y * delta-y))
    let force = attraction * distance * distance / edge-length
    let force-x = delta-x / distance * force
    let force-y = delta-y / distance * force
    displacements = _add-graph-displacement(
      displacements, from-node-id, -force-x, -force-y,
    )
    displacements = _add-graph-displacement(
      displacements, to-node-id, force-x, force-y,
    )
  }
  displacements
}

#let _graph-vector-cross-product(left-x, left-y, right-x, right-y) = (
  left-x * right-y - left-y * right-x
)

#let _force-graph-edges-cross(left-edge, right-edge, node-positions) = {
  let left-from-id = left-edge.at(0)
  let left-to-id = left-edge.at(1)
  let right-from-id = right-edge.at(0)
  let right-to-id = right-edge.at(1)
  if (
    left-from-id in (right-from-id, right-to-id)
      or left-to-id in (right-from-id, right-to-id)
  ) { return false }
  let left-from = node-positions.at(left-from-id)
  let left-to = node-positions.at(left-to-id)
  let right-from = node-positions.at(right-from-id)
  let right-to = node-positions.at(right-to-id)
  let left-delta-x = left-to.at(0) - left-from.at(0)
  let left-delta-y = left-to.at(1) - left-from.at(1)
  let right-delta-x = right-to.at(0) - right-from.at(0)
  let right-delta-y = right-to.at(1) - right-from.at(1)
  let denominator = _graph-vector-cross-product(
    left-delta-x, left-delta-y, right-delta-x, right-delta-y,
  )
  if calc.abs(denominator) < 0.0001 { return false }
  let between-starts-x = right-from.at(0) - left-from.at(0)
  let between-starts-y = right-from.at(1) - left-from.at(1)
  let left-fraction = _graph-vector-cross-product(
    between-starts-x, between-starts-y, right-delta-x, right-delta-y,
  ) / denominator
  let right-fraction = _graph-vector-cross-product(
    between-starts-x, between-starts-y, left-delta-x, left-delta-y,
  ) / denominator
  (
    left-fraction > 0.0001 and left-fraction < 0.9999
      and right-fraction > 0.0001 and right-fraction < 0.9999
  )
}

#let _count-force-graph-edge-crossings(component-edges, node-positions) = {
  let crossing-count = 0
  for left-edge-index in range(component-edges.len()) {
    for right-edge-index in range(left-edge-index + 1, component-edges.len()) {
      if _force-graph-edges-cross(
        component-edges.at(left-edge-index),
        component-edges.at(right-edge-index),
        node-positions,
      ) {
        crossing-count += 1
      }
    }
  }
  crossing-count
}

#let _calculate-force-node-edge-overlap-penalty(
  component-node-ids,
  component-edges,
  node-positions,
  node-boundaries,
  node-edge-clearance,
) = {
  let overlap-penalty = 0.0
  for (edge-index, edge) in component-edges.enumerate() {
    let from-node-id = edge.at(0)
    let to-node-id = edge.at(1)
    if from-node-id == to-node-id { continue }
    let from-position = node-positions.at(from-node-id)
    let to-position = node-positions.at(to-node-id)
    for (node-index, node-id) in component-node-ids.enumerate() {
      if node-id in (from-node-id, to-node-id) { continue }
      let node-position = node-positions.at(node-id)
      let projection = _project-point-to-graph-edge(
        node-position, from-position, to-position,
      )
      let clearance = _resolve-node-edge-clearance(
        node-id,
        node-position,
        from-position,
        to-position,
        projection,
        node-boundaries,
        node-edge-clearance,
        node-index,
        edge-index,
      )
      if projection.distance < clearance.required {
        overlap-penalty += (
          clearance.required - projection.distance
        ) / clearance.required
      }
    }
  }
  overlap-penalty
}

#let _calculate-force-component-score(
  component-node-ids,
  component-edges,
  node-positions,
  node-boundaries,
  options,
) = {
  let node-edge-penalty = _calculate-force-node-edge-overlap-penalty(
    component-node-ids,
    component-edges,
    node-positions,
    node-boundaries,
    options.node-edge-clearance,
  )
  let edge-crossings = _count-force-graph-edge-crossings(
    component-edges, node-positions,
  )
  let edge-length-error = 0.0
  for (from-node-id, to-node-id, _) in component-edges {
    if from-node-id == to-node-id { continue }
    let from-position = node-positions.at(from-node-id)
    let to-position = node-positions.at(to-node-id)
    let delta-x = to-position.at(0) - from-position.at(0)
    let delta-y = to-position.at(1) - from-position.at(1)
    let actual-length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
    edge-length-error += calc.abs(actual-length - options.edge-length) / options.edge-length
  }
  node-edge-penalty * 1000 + edge-crossings * 100 + edge-length-error
}

#let _simulate-force-component(
  component-node-ids,
  graph-edges,
  node-boundaries,
  options,
  start-variant,
) = {
  let edge-length = options.edge-length
  let node-positions = _initialize-force-component(
    component-node-ids, edge-length, start-variant,
  )
  if component-node-ids.len() == 1 { return node-positions }
  let component-edges = graph-edges.filter(edge => (
    edge.at(0) in component-node-ids and edge.at(1) in component-node-ids
  ))
  for iteration in range(options.iterations) {
    let displacements = (:)
    for node-id in component-node-ids {
      displacements.insert(node-id, (0.0, 0.0))
    }
    displacements = _apply-force-repulsion(
      component-node-ids,
      node-positions,
      displacements,
      edge-length,
      options.repulsion,
    )
    displacements = _apply-force-attraction(
      component-edges,
      node-positions,
      displacements,
      edge-length,
      options.attraction,
    )
    displacements = _apply-force-node-edge-repulsion(
      component-node-ids,
      component-edges,
      node-positions,
      node-boundaries,
      displacements,
      options,
    )
    let temperature = _calculate-force-cooling(
      edge-length, iteration, options.iterations,
    )
    for node-id in component-node-ids {
      let displacement = displacements.at(node-id)
      let displacement-length = calc.sqrt(
        displacement.at(0) * displacement.at(0)
          + displacement.at(1) * displacement.at(1),
      )
      if displacement-length > 0 {
        let movement-scale = calc.min(displacement-length, temperature) / displacement-length
        let node-position = node-positions.at(node-id)
        node-positions.insert(node-id, (
          node-position.at(0) + displacement.at(0) * movement-scale,
          node-position.at(1) + displacement.at(1) * movement-scale,
        ))
      }
    }
    node-positions = _center-graph-positions(node-positions, component-node-ids)
  }
  node-positions = _resolve-force-node-edge-overlaps(
    component-node-ids,
    component-edges,
    node-positions,
    node-boundaries,
    options,
  )
  _center-graph-positions(node-positions, component-node-ids)
}

#let _calculate-graph-position-bounds(node-positions, node-ids) = {
  if node-ids.len() == 0 { return (0.0, 0.0, 0.0, 0.0) }
  let first-position = node-positions.at(node-ids.first())
  let minimum-x = first-position.at(0)
  let maximum-x = first-position.at(0)
  let minimum-y = first-position.at(1)
  let maximum-y = first-position.at(1)
  for node-id in node-ids.slice(1) {
    let node-position = node-positions.at(node-id)
    minimum-x = calc.min(minimum-x, node-position.at(0))
    maximum-x = calc.max(maximum-x, node-position.at(0))
    minimum-y = calc.min(minimum-y, node-position.at(1))
    maximum-y = calc.max(maximum-y, node-position.at(1))
  }
  (minimum-x, maximum-x, minimum-y, maximum-y)
}

#let _pack-force-components(component-layouts, component-gap) = {
  let packed-positions = (:)
  let horizontal-cursor = 0.0
  let all-node-ids = ()
  for component-layout in component-layouts {
    let component-node-ids = component-layout.node-ids
    let component-positions = component-layout.positions
    let bounds = _calculate-graph-position-bounds(
      component-positions, component-node-ids,
    )
    let component-center-y = (bounds.at(2) + bounds.at(3)) / 2
    for node-id in component-node-ids {
      let node-position = component-positions.at(node-id)
      packed-positions.insert(node-id, (
        node-position.at(0) - bounds.at(0) + horizontal-cursor,
        node-position.at(1) - component-center-y,
      ))
      all-node-ids.push(node-id)
    }
    horizontal-cursor += bounds.at(1) - bounds.at(0) + component-gap
  }
  _center-graph-positions(packed-positions, all-node-ids)
}

// Deterministic restarts reduce sensitivity to a single circular node ordering.
#let _calculate-best-force-component-layout(
  component-node-ids,
  graph-edges,
  node-boundaries,
  options,
) = {
  let component-edges = graph-edges.filter(edge => (
    edge.at(0) in component-node-ids and edge.at(1) in component-node-ids
  ))
  let candidate-count = if component-node-ids.len() <= 2 { 1 } else { 3 }
  let best-positions = none
  let best-score = none
  for start-variant in range(candidate-count) {
    let candidate-positions = _simulate-force-component(
      component-node-ids,
      graph-edges,
      node-boundaries,
      options,
      start-variant,
    )
    let candidate-score = _calculate-force-component-score(
      component-node-ids,
      component-edges,
      candidate-positions,
      node-boundaries,
      options,
    )
    if best-score == none or candidate-score < best-score {
      best-score = candidate-score
      best-positions = candidate-positions
    }
  }
  best-positions
}

#let _calculate-force-graph-layout(
  adjacency,
  layout-options,
  resolved-style,
  node-customizations,
) = {
  let options = _force-layout-defaults + layout-options
  let node-ids = _collect-graph-node-ids(adjacency)
  let graph-edges = _collect-graph-edges(adjacency, false)
  let node-boundaries = _resolve-force-node-boundaries(
    node-ids, resolved-style, node-customizations,
  )
  let component-layouts = _collect-graph-connected-components(adjacency).map(
    component-node-ids => (
      node-ids: component-node-ids,
      positions: _calculate-best-force-component-layout(
        component-node-ids, graph-edges, node-boundaries, options,
      ),
    ),
  )
  _pack-force-components(component-layouts, options.component-gap)
}

#let _build-layered-graph-ranks(adjacency, topological-node-ids) = {
  let ranks = (:)
  for node-id in topological-node-ids { ranks.insert(node-id, 0) }
  for from-node-id in topological-node-ids {
    if from-node-id not in adjacency { continue }
    for edge-entry in adjacency.at(from-node-id) {
      let to-node-id = _edge-target-id(edge-entry)
      ranks.insert(
        to-node-id,
        calc.max(ranks.at(to-node-id), ranks.at(from-node-id) + 1),
      )
    }
  }
  ranks
}

#let _build-layered-graph-neighbor-maps(adjacency, node-ids) = {
  let predecessors = (:)
  let successors = (:)
  for node-id in node-ids {
    predecessors.insert(node-id, ())
    successors.insert(node-id, ())
  }
  for from-node-id in adjacency.keys() {
    for edge-entry in adjacency.at(from-node-id) {
      let to-node-id = _edge-target-id(edge-entry)
      let from-successors = successors.at(from-node-id)
      if to-node-id not in from-successors {
        from-successors.push(to-node-id)
        successors.insert(from-node-id, from-successors)
      }
      let to-predecessors = predecessors.at(to-node-id)
      if from-node-id not in to-predecessors {
        to-predecessors.push(from-node-id)
        predecessors.insert(to-node-id, to-predecessors)
      }
    }
  }
  (predecessors, successors)
}

#let _index-layered-graph-nodes(layers) = {
  let layer-positions = (:)
  for layer-node-ids in layers {
    for (node-index, node-id) in layer-node-ids.enumerate() {
      layer-positions.insert(node-id, node-index)
    }
  }
  layer-positions
}

#let _calculate-layer-barycenter(adjacent-node-ids, layer-positions, fallback) = {
  let positioned-neighbor-ids = adjacent-node-ids.filter(
    adjacent-node-id => adjacent-node-id in layer-positions,
  )
  if positioned-neighbor-ids.len() == 0 { return fallback }
  let total-position = 0.0
  for adjacent-node-id in positioned-neighbor-ids {
    total-position += layer-positions.at(adjacent-node-id)
  }
  total-position / positioned-neighbor-ids.len()
}

#let _order-layer-by-barycenter(
  layer-node-ids,
  adjacent-node-ids-by-node,
  layer-positions,
  declared-order,
) = {
  let remaining-node-ids = layer-node-ids
  let ordered-node-ids = ()
  while remaining-node-ids.len() > 0 {
    let selected-index = 0
    let selected-node-id = remaining-node-ids.first()
    let selected-score = _calculate-layer-barycenter(
      adjacent-node-ids-by-node.at(selected-node-id),
      layer-positions,
      layer-positions.at(selected-node-id),
    )
    for candidate-index in range(1, remaining-node-ids.len()) {
      let candidate-node-id = remaining-node-ids.at(candidate-index)
      let candidate-score = _calculate-layer-barycenter(
        adjacent-node-ids-by-node.at(candidate-node-id),
        layer-positions,
        layer-positions.at(candidate-node-id),
      )
      let candidate-comes-first = (
        candidate-score < selected-score
          or (
            candidate-score == selected-score
              and declared-order.at(candidate-node-id) < declared-order.at(selected-node-id)
          )
      )
      if candidate-comes-first {
        selected-index = candidate-index
        selected-node-id = candidate-node-id
        selected-score = candidate-score
      }
    }
    ordered-node-ids.push(selected-node-id)
    let _ = remaining-node-ids.remove(selected-index)
  }
  ordered-node-ids
}

#let _reduce-layered-graph-crossings(layers, predecessors, successors, node-ids, sweeps) = {
  let declared-order = (:)
  for (node-index, node-id) in node-ids.enumerate() {
    declared-order.insert(node-id, node-index)
  }
  for _ in range(sweeps) {
    for layer-index in range(1, layers.len()) {
      let layer-positions = _index-layered-graph-nodes(layers)
      layers.at(layer-index) = _order-layer-by-barycenter(
        layers.at(layer-index), predecessors, layer-positions, declared-order,
      )
    }
    for layer-index in range(layers.len() - 1).rev() {
      let layer-positions = _index-layered-graph-nodes(layers)
      layers.at(layer-index) = _order-layer-by-barycenter(
        layers.at(layer-index), successors, layer-positions, declared-order,
      )
    }
  }
  layers
}

#let _transform-layered-graph-position(canonical-position, direction) = {
  let x = canonical-position.at(0)
  let y = canonical-position.at(1)
  if direction == "left" { return (-x, y) }
  if direction == "down" { return (y, -x) }
  if direction == "up" { return (y, x) }
  (x, y)
}

#let _calculate-layered-graph-layout(adjacency, layout-options) = {
  let options = _layered-layout-defaults + layout-options
  let node-ids = _collect-graph-node-ids(adjacency)
  if node-ids.len() == 0 { return (:) }
  let topological-node-ids = _topologically-order-graph-nodes(adjacency)
  assert(topological-node-ids != none, message: "layered layout requires a DAG")
  let ranks = _build-layered-graph-ranks(adjacency, topological-node-ids)
  let maximum-rank = 0
  for node-id in node-ids { maximum-rank = calc.max(maximum-rank, ranks.at(node-id)) }
  let layers = range(maximum-rank + 1).map(_ => ())
  for node-id in node-ids {
    let node-rank = ranks.at(node-id)
    let layer-node-ids = layers.at(node-rank)
    layer-node-ids.push(node-id)
    layers.at(node-rank) = layer-node-ids
  }
  let (predecessors, successors) = _build-layered-graph-neighbor-maps(adjacency, node-ids)
  layers = _reduce-layered-graph-crossings(
    layers,
    predecessors,
    successors,
    node-ids,
    options.crossing-sweeps,
  )
  let node-positions = (:)
  for (layer-index, layer-node-ids) in layers.enumerate() {
    let layer-center = (layer-node-ids.len() - 1) / 2
    for (node-index, node-id) in layer-node-ids.enumerate() {
      let canonical-position = (
        layer-index * options.layer-gap,
        (layer-center - node-index) * options.node-gap,
      )
      node-positions.insert(
        node-id,
        _transform-layered-graph-position(canonical-position, options.direction),
      )
    }
  }
  _center-graph-positions(node-positions, node-ids)
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

// Resolves `positions:`. With an automatic layout, omitted nodes keep their
// calculated spot. In manual mode, every node must be positioned, with at
// least one absolute `(x, y)` entry anchoring relative entries.
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

#let _resolve-graph-layout(
  adjacency,
  positions,
  layout,
  radius,
  gap,
  layout-options,
  resolved-style,
  node-customizations,
) = {
  let node-ids = _collect-graph-node-ids(adjacency)
  let initial-node-positions = if layout == "auto" {
    _calculate-circular-graph-layout(node-ids, resolved-style, radius)
  } else if layout == "linear" {
    _calculate-linear-graph-layout(
      node-ids,
      if gap == auto { 1.5 } else { gap },
    )
  } else if layout == "force" {
    _calculate-force-graph-layout(
      adjacency, layout-options, resolved-style, node-customizations,
    )
  } else if layout == "layered" {
    _calculate-layered-graph-layout(adjacency, layout-options)
  } else {
    (:)
  }
  _resolve-graph-node-positions(
    initial-node-positions,
    positions,
    node-ids,
    layout == "manual",
  )
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
