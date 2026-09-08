// =====================================================
// LINE, SEGMENT, RAY - Linear geometry objects
// =====================================================

#import "point.typ": is-point, point

/// Create a line segment between two points
/// A segment has definite endpoints and finite length.
///
/// Parameters:
/// - p1: First endpoint (point object or (x, y) tuple)
/// - p2: Second endpoint
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let segment(p1, p2, label: none, label-anchor: none, style: auto, label-padding: 0.2) = {
  // Convert tuples to points if needed
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }

  (
    type: "segment",
    p1: pt1,
    p2: pt2,
    label: label,
    label-anchor: label-anchor,
    style: style,
    label-padding: label-padding,
  )
}

/// Create an infinite line through two points
/// A line extends infinitely in both directions.
///
/// Parameters:
/// - p1: First point on the line
/// - p2: Second point on the line
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let line(p1, p2, label: none, label-anchor: none, style: auto, label-padding: 0.2) = {
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }

  (
    type: "line",
    p1: pt1,
    p2: pt2,
    label: label,
    label-anchor: label-anchor,
    style: style,
    label-padding: label-padding,
  )
}

/// Create a ray starting at origin, passing through a point
/// A ray extends infinitely in one direction from its origin.
///
/// Parameters:
/// - origin: Starting point of the ray
/// - through: A point the ray passes through
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let ray(origin, through, label: none, label-anchor: none, style: auto, label-padding: 0.2) = {
  let pt1 = if is-point(origin) { origin } else { point(origin.at(0), origin.at(1)) }
  let pt2 = if is-point(through) { through } else { point(through.at(0), through.at(1)) }

  (
    type: "ray",
    origin: pt1,
    through: pt2,
    label: label,
    label-anchor: label-anchor,
    style: style,
    label-padding: label-padding,
  )
}

/// Create a line from a point in the direction of another point
///
/// Parameters:
/// - p: Point on the line
/// - direction: Point indicating the direction (line passes through p toward direction)
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let line-through-direction(p, direction, style: auto, label-padding: 0.2) = {
  let pt = if is-point(p) { p } else { point(p.at(0), p.at(1)) }
  let dir = if is-point(direction) { direction } else { point(direction.at(0), direction.at(1)) }
  line(pt, dir, style: style, label-padding: label-padding)
}

/// Create a line from a point and a slope
///
/// Parameters:
/// - p: Point on the line
/// - slope: Slope of the line
/// - style: Optional style overrides
#let line-point-slope(p, slope, ..args) = {
  let pt = if is-point(p) { p } else { point(p.at(0), p.at(1)) }
  let pt2 = point(pt.x + 1, pt.y + slope)
  
  line(pt, pt2, ..args)
}

/// Check if object is a segment
#let is-segment(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "segment"
}

/// Check if object is a line
#let is-line(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "line"
}

/// Check if object is a ray
#let is-ray(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "ray"
}

/// Check if object is any linear type
#let is-linear(obj) = is-segment(obj) or is-line(obj) or is-ray(obj)

/// Get the direction vector of a linear object
#let linear-direction(obj) = {
  let p1 = if obj.type == "ray" { obj.origin } else { obj.p1 }
  let p2 = if obj.type == "ray" { obj.through } else { obj.p2 }
  (p2.x - p1.x, p2.y - p1.y)
}

/// Get the length of a segment
#let segment-length(seg) = {
  let dx = seg.p2.x - seg.p1.x
  let dy = seg.p2.y - seg.p1.y
  calc.sqrt(dx * dx + dy * dy)
}

// =====================================================
// Conversion Utilities
// =====================================================

/// Convert a ray to a segment of a given length
#let ray-to-segment(ray, length: 2) = {
  let o = ray.origin
  let t = ray.through
  let dir = (t.x - o.x, t.y - o.y)
  let norm = calc.sqrt(dir.at(0) * dir.at(0) + dir.at(1) * dir.at(1))
  if norm == 0 { return segment(o, o) }
  let udx = dir.at(0) / norm
  let udy = dir.at(1) / norm
  let p2 = point(o.x + length * udx, o.y + length * udy)
  segment(o, p2)
}

/// Convert a line to a segment of a given length, centered on its first point
#let line-to-segment(line, length: 2) = {
  let p1 = line.p1
  let p2 = line.p2
  let dir = (p2.x - p1.x, p2.y - p1.y)
  let norm = calc.sqrt(dir.at(0) * dir.at(0) + dir.at(1) * dir.at(1))
  if norm == 0 { return segment(p1, p1) }
  let udx = dir.at(0) / norm
  let udy = dir.at(1) / norm
  let half-len = length / 2.0
  let new-p1 = point(p1.x - half-len * udx, p1.y - half-len * udy)
  let new-p2 = point(p1.x + half-len * udx, p1.y + half-len * udy)
  segment(new-p1, new-p2)
}

/// Convert a segment to an infinite line
#let segment-to-line(seg) = {
  line(seg.p1, seg.p2)
}

/// Convert a segment to a ray
#let segment-to-ray(seg) = {
  ray(seg.p1, seg.p2)
}

/// Convert a ray to an infinite line
#let ray-to-line(r) = {
  line(r.origin, r.through)
}

/// Convert a line to a ray
#let line-to-ray(l) = {
  ray(l.p1, l.p2)
}
