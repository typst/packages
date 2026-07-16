// =====================================================
// POINT - Fundamental geometry object
// =====================================================

#import "core.typ": polar-to-cartesian

/// Create a point (2D or 3D) from Cartesian coordinates
///
/// Parameters:
/// - x: X coordinate
/// - y: Y coordinate
/// - z: Z coordinate (optional, none for 2D)
/// - label: Optional label to display
/// - label-anchor: Optional anchor for label positioning (e.g., "north", "south", "east", "west")
/// - style: Optional style overrides (stroke, fill, size)
/// - label-padding: Label padding value (default: 0.2)
#let point(x, y, z: none, label: none, label-anchor: none, style: auto, label-padding: 0.2) = (
  type: "point",
  x: x,
  y: y,
  z: z,
  label: label,
  label-anchor: label-anchor,
  style: style,
  label-padding: label-padding,
)

/// Alias for backward compatibility
#let point-3d(x, y, z, label: none, label-anchor: none, style: auto, label-padding: 0.2) = point(
  x,
  y,
  z: z,
  label: label,
  label-anchor: label-anchor,
  style: style,
  label-padding: label-padding,
)

/// Create a point from polar coordinates
///
/// Parameters:
/// - r: Radius (distance from origin)
/// - theta: Angle in radians or degrees
/// - label: Optional label
/// - label-anchor: Optional anchor for label positioning
/// - style: Optional style overrides
/// - label-padding: Label padding value (default: 0.2)
#let point-polar(r, theta, label: none, label-anchor: none, style: auto, label-padding: 0.2) = {
  let (x, y) = polar-to-cartesian(r, theta)
  point(x, y, label: label, label-anchor: label-anchor, style: style, label-padding: label-padding)
}

/// Check if object is a point
#let is-point(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "point"
}

/// Get point coordinates as tuple
#let point-coords(p) = {
  if p.z != none { (p.x, p.y, p.z) } else { (p.x, p.y) }
}

/// Get point as (x, y) tuple (for 2D operations)
#let point-xy(p) = (p.x, p.y)

/// Create a labeled copy of a point
#let with-label(p, label) = {
  let result = p
  result.label = label
  result
}

/// Create a styled copy of a point
#let with-style(p, style) = {
  let result = p
  result.style = style
  result
}

/// Calculate the Euclidean distance between two points
///
/// Parameters:
/// - p1: First point (point object or (x, y) tuple)
/// - p2: Second point (point object or (x, y) tuple)
/// Returns: The distance as a float
#let distance(p1, p2) = {
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }

  let dx = pt2.x - pt1.x
  let dy = pt2.y - pt1.y

  if pt1.z != none and pt2.z != none {
    let dz = pt2.z - pt1.z
    calc.sqrt(dx * dx + dy * dy + dz * dz)
  } else {
    calc.sqrt(dx * dx + dy * dy)
  }
}

/// Get the x-coordinate of a point
#let x(p) = {
  let pt = if is-point(p) { p } else { point(p.at(0), p.at(1)) }
  pt.x
}

/// Get the y-coordinate of a point
#let y(p) = {
  let pt = if is-point(p) { p } else { point(p.at(0), p.at(1)) }
  pt.y
}

/// Get the z-coordinate of a point (returns none for 2D points)
#let z(p) = {
  let pt = if is-point(p) { p } else { point(p.at(0), p.at(1)) }
  pt.z
}
