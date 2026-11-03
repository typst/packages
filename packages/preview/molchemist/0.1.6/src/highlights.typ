// Reaction highlight geometry, independent of foreground bond clipping.

#let _clip-highlight-polygon(polygon, axis, boundary, greater) = {
  if polygon.len() == 0 { return () }
  let inside(point) = if greater { point.at(axis) >= boundary } else { point.at(axis) <= boundary }
  let output = ()
  let previous = polygon.last()
  for point in polygon {
    if inside(point) != inside(previous) {
      let t = (boundary - previous.at(axis)) / (point.at(axis) - previous.at(axis))
      output.push(previous.zip(point).map(((a, b)) => a + t * (b - a)))
    }
    if inside(point) { output.push(point) }
    previous = point
  }
  output
}

// Retain the disjoint pieces outside a label rectangle. Successive cuts
// prevent overlap between pieces and preserve their winding direction.
#let _subtract-highlight-rect(polygon, rect) = {
  let inside = polygon
  let pieces = ()
  for (axis, boundary, greater) in ((0, rect.at(0), true), (0, rect.at(2), false),
      (1, rect.at(1), true), (1, rect.at(3), false)) {
    let outside = _clip-highlight-polygon(inside, axis, boundary, not greater)
    if outside.len() >= 3 { pieces.push(outside) }
    inside = _clip-highlight-polygon(inside, axis, boundary, greater)
    if inside.len() == 0 { break }
  }
  pieces
}

#let _highlight-band(start, end, radius, exclusions: ()) = {
  let dx = end.at(0) - start.at(0)
  let dy = end.at(1) - start.at(1)
  let length = calc.sqrt(dx*dx + dy*dy)
  if length <= 0.00000001 { return () }
  let normal = (-dy / length * radius, dx / length * radius)
  let shifted(point, sign) = point.zip(normal).map(((p, n)) => p + sign*n)
  let pieces = ((shifted(start, 1), shifted(start, -1), shifted(end, -1), shifted(end, 1)),)
  for rect in exclusions {
    let remaining = ()
    for polygon in pieces { remaining += _subtract-highlight-rect(polygon, rect) }
    pieces = remaining
  }
  pieces.filter(polygon => {
    let twice-area = 0.0
    let previous = polygon.last()
    for point in polygon {
      twice-area += previous.at(0)*point.at(1) - point.at(0)*previous.at(1)
      previous = point
    }
    calc.abs(twice-area) > 0.00000001
  })
}

// Script columns occupy only their respective half of the label. Excluding
// the full height would sever horizontal highlights beside atom-map labels.
#let _highlight-label-exclusions(bounds, center, symbol-width, padding, columns) = {
  let left = center.at(0) - symbol-width/2 - padding
  let right = center.at(0) + symbol-width/2 + padding
  let exclusions = ()
  for (start, end, half) in columns {
    start += center.at(0)
    end += center.at(0)
    let bottom = if half == "upper" { center.at(1) } else { bounds.at(1) }
    let top = if half == "lower" { center.at(1) } else { bounds.at(3) }
    for (x1, x2) in ((start, calc.min(end, left)), (calc.max(start, right), end)) {
      if x2 > x1 { exclusions.push((x1, bottom, x2, top)) }
    }
  }
  exclusions
}
