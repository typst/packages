// =====================================================
// CIRCLE, ARC - Circular geometry objects
// =====================================================

#import "point.typ": is-point, point

/// Create a circle
///
/// Parameters:
/// - center: Center point (point object or (x, y) tuple)
/// - radius: Circle radius
/// - label: Optional label
/// - style: Optional style overrides (stroke, fill)
#let circle(center, ..args) = {
  let pt = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  let named = args.named()
  let pos = args.pos()

  let r = if pos.len() > 0 {
    pos.first()
  } else if "radius" in named {
    named.radius
  } else if "through" in named {
    let through = named.through
    let pt2 = if is-point(through) { through } else { point(through.at(0), through.at(1)) }
    calc.sqrt(calc.pow(pt.x - pt2.x, 2) + calc.pow(pt.y - pt2.y, 2))
  } else {
    panic("circle: must provide radius or through point")
  }

  (
    type: "circle",
    center: pt,
    radius: r,
    label: named.at("label", default: none),
    label-anchor: named.at("label-anchor", default: none),
    fill: named.at("fill", default: none),
    style: named.at("style", default: auto),
  )
}

/// Create a circle through three points
///
/// Parameters:
/// - p1, p2, p3: Three points on the circle
/// - label: Optional label
#let circle-through(p1, p2, p3, label: none, style: auto) = {
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }
  let pt3 = if is-point(p3) { p3 } else { point(p3.at(0), p3.at(1)) }

  // Calculate circumcenter using perpendicular bisectors
  let ax = pt1.x
  let ay = pt1.y
  let bx = pt2.x
  let by = pt2.y
  let cx = pt3.x
  let cy = pt3.y

  let d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
  if calc.abs(d) < 0.0001 {
    // Points are collinear, return degenerate circle
    return circle((0, 0), 0, label: label)
  }

  let ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
  let uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d

  let r = calc.sqrt((ax - ux) * (ax - ux) + (ay - uy) * (ay - uy))

  circle(point(ux, uy), r, label: label, style: style)
}

/// Create an arc (portion of a circle) from a center and two points
///
/// Parameters:
/// - center: Center point of the arc
/// - p1: Start point on the arc
/// - p2: End point on the arc
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
#let arc(center, p1, p2, label: none, label-anchor: none, style: auto) = {
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }

  // Calculate radius from center to p1
  let r = calc.sqrt(calc.pow(pt1.x - c.x, 2) + calc.pow(pt1.y - c.y, 2))

  // Calculate angles from center to p1 and p2
  // Note: calc.atan2 takes (x, y) in Typst (not standard y, x)
  let start-angle = calc.atan2(pt1.x - c.x, pt1.y - c.y)
  let end-angle = calc.atan2(pt2.x - c.x, pt2.y - c.y)

  (
    type: "arc",
    center: c,
    radius: r,
    start: start-angle,
    end: end-angle,
    label: label,
    label-anchor: label-anchor,
    style: style,
  )
}

/// Create a semicircle from a center and a point on the arc
/// The semicircle will be drawn 180° counterclockwise from the start point
///
/// Parameters:
/// - center: Center point
/// - start-point: Starting point on the semicircle
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
#let semicircle(center, start-point, label: none, label-anchor: none, style: auto) = {
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  let pt = if is-point(start-point) { start-point } else { point(start-point.at(0), start-point.at(1)) }

  // Calculate the end point (180° from start)
  // Vector from center to start
  let dx = pt.x - c.x
  let dy = pt.y - c.y
  // Rotate 180° (negate)
  let end-pt = point(c.x - dx, c.y - dy)

  arc(c, pt, end-pt, label: label, label-anchor: label-anchor, style: style)
}

/// Check if object is a circle
#let is-circle(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "circle"
}

/// Check if object is an arc
#let is-arc(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "arc"
}

/// Get a point on the circle at a given angle
#let circle-point-at(circ, angle, label: none) = {
  point(
    circ.center.x + circ.radius * calc.cos(angle),
    circ.center.y + circ.radius * calc.sin(angle),
    label: label,
  )
}

/// Create a point at a given angle and radius from a center
/// Useful for creating arcs with precise angles (e.g., 67°)
///
/// Parameters:
/// - center: Center point (origin of rotation)
/// - angle: Counterclockwise angle from the reference point (or positive x-axis if none)
/// - radius: Distance from center
/// - from: Optional reference point defining the 0° direction from center
/// - label: Optional label
#let point-at-angle(center, angle, radius, from: none, label: none) = {
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }

  // Calculate base angle from reference point, or use 0 (positive x-axis)
  // Note: calc.atan2 takes (x, y) in Typst (not standard y, x)
  let base-angle = if from != none {
    let b = if is-point(from) { from } else { point(from.at(0), from.at(1)) }
    calc.atan2(b.x - c.x, b.y - c.y)
  } else {
    0deg
  }

  let total-angle = base-angle + angle
  point(
    c.x + radius * calc.cos(total-angle),
    c.y + radius * calc.sin(total-angle),
    label: label,
  )
}

/// Get the circumference of a circle
#let circumference(circ) = 2 * calc.pi * circ.radius

/// Get the area of a circle
#let circle-area(circ) = calc.pi * circ.radius * circ.radius
