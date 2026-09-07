// =====================================================
// POLYGON - Polygon geometry object
// =====================================================

#import "point.typ": is-point, point

/// Create a polygon from a list of points
///
/// Parameters:
/// - ..points: Variable number of points (at least 3)
/// - label: Optional label (displayed at centroid)
/// - label-anchor: Optional anchor for label positioning
/// - fill: Optional fill color
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let polygon(..points, label: none, label-anchor: none, fill: none, style: auto, label-padding: 0.2) = {
  let pts = points
    .pos()
    .map(p => {
      if is-point(p) { p } else { point(p.at(0), p.at(1)) }
    })

  (
    type: "polygon",
    points: pts,
    label: label,
    label-anchor: label-anchor,
    fill: fill,
    style: style,
    label-padding: label-padding,
  )
}

/// Create a triangle from three points
#let triangle(p1, p2, p3, label: none, label-anchor: none, fill: none, style: auto, label-padding: 0.2) = {
  polygon(p1, p2, p3, label: label, label-anchor: label-anchor, fill: fill, style: style, label-padding: label-padding)
}

/// Create a rectangle from corner and dimensions
///
/// Parameters:
/// - corner: Bottom-left corner point
/// - width: Rectangle width
/// - height: Rectangle height
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - fill: Optional fill color
/// - label-padding: Label padding value (default: 0.2)
#let rectangle(corner, width, height, label: none, label-anchor: none, fill: none, style: auto, label-padding: 0.2) = {
  let c = if is-point(corner) { corner } else { point(corner.at(0), corner.at(1)) }
  let p1 = c
  let p2 = point(c.x + width, c.y)
  let p3 = point(c.x + width, c.y + height)
  let p4 = point(c.x, c.y + height)

  polygon(p1, p2, p3, p4, label: label, label-anchor: label-anchor, fill: fill, style: style, label-padding: label-padding)
}

/// Create a regular polygon from center and first vertex
///
/// Parameters:
/// - center: Center point
/// - first-vertex: Position of the first vertex (defines radius and orientation)
/// - n: Number of sides
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - fill: Optional fill color
/// - label-padding: Label padding value (default: 0.2)
#let regular-polygon(center, first-vertex, n, label: none, label-anchor: none, fill: none, style: auto, label-padding: 0.2) = {
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  let fv = if is-point(first-vertex) { first-vertex } else { point(first-vertex.at(0), first-vertex.at(1)) }

  // Calculate radius and start angle from first-vertex
  let dx = fv.x - c.x
  let dy = fv.y - c.y
  let radius = calc.sqrt(dx * dx + dy * dy)
  let start-angle = calc.atan2(dx, dy)

  let pts = range(n).map(i => {
    let angle = start-angle + (360deg / n) * i
    point(
      c.x + radius * calc.cos(angle),
      c.y + radius * calc.sin(angle),
    )
  })

  (
    type: "polygon",
    points: pts,
    label: label,
    label-anchor: label-anchor,
    fill: fill,
    style: style,
    label-padding: label-padding,
  )
}

/// Create a square
#let square(center, side, label: none, label-anchor: none, fill: none, style: auto, label-padding: 0.2) = {
  let half = side / 2
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  polygon(
    point(c.x - half, c.y - half),
    point(c.x + half, c.y - half),
    point(c.x + half, c.y + half),
    point(c.x - half, c.y + half),
    label: label,
    label-anchor: label-anchor,
    fill: fill,
    style: style,
    label-padding: label-padding,
  )
}

/// Check if object is a polygon
#let is-polygon(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "polygon"
}

/// Get the centroid of a polygon
#let polygon-centroid(poly) = {
  let sum-x = 0
  let sum-y = 0
  for p in poly.points {
    sum-x += p.x
    sum-y += p.y
  }
  let n = poly.points.len()
  point(sum-x / n, sum-y / n)
}

/// Get all edges of a polygon as segments
#let polygon-edges(poly) = {
  import "line.typ": segment
  let n = poly.points.len()
  range(n).map(i => {
    segment(poly.points.at(i), poly.points.at(calc.rem(i + 1, n)))
  })
}

/// Calculate the perimeter of a polygon
#let polygon-perimeter(poly) = {
  import "core.typ": distance
  let n = poly.points.len()
  let total = 0
  for i in range(n) {
    let p1 = poly.points.at(i)
    let p2 = poly.points.at(calc.rem(i + 1, n))
    total += distance(p1, p2)
  }
  total
}

/// Calculate the area of a polygon (shoelace formula)
#let polygon-area(poly) = {
  let n = poly.points.len()
  let sum = 0
  for i in range(n) {
    let p1 = poly.points.at(i)
    let p2 = poly.points.at(calc.rem(i + 1, n))
    sum += p1.x * p2.y - p2.x * p1.y
  }
  calc.abs(sum) / 2
}
