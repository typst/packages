// =====================================================
// GEOMETRY CORE - Base utilities for geometry objects
// =====================================================

/// Check if an object is a geometry type
#let is-geo-object(obj) = {
  if type(obj) != dictionary { return false }
  "type" in obj
}

/// Get the type of a geometry object
#let geo-type(obj) = {
  if is-geo-object(obj) { obj.type } else { none }
}

/// Convert polar coordinates to Cartesian
#let polar-to-cartesian(r, theta) = {
  (r * calc.cos(theta), r * calc.sin(theta))
}

/// Convert Cartesian to polar
#let cartesian-to-polar(x, y) = {
  let r = calc.sqrt(x * x + y * y)
  let theta = calc.atan2(y, x)
  (r, theta)
}

/// Calculate distance between two points (x1, y1) and (x2, y2)
#let distance(p1, p2) = {
  let dx = p2.x - p1.x
  let dy = p2.y - p1.y
  calc.sqrt(dx * dx + dy * dy)
}

/// Calculate distance for 3D points
#let distance-3d(p1, p2) = {
  let dx = p2.x - p1.x
  let dy = p2.y - p1.y
  let dz = p2.at("z", default: 0) - p1.at("z", default: 0)
  calc.sqrt(dx * dx + dy * dy + dz * dz)
}

/// Normalize a 2D vector
#let normalize(dx, dy) = {
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { (0, 0) } else { (dx / len, dy / len) }
}

/// Dot product of two 2D vectors
#let dot-2d(v1, v2) = {
  v1.at(0) * v2.at(0) + v1.at(1) * v2.at(1)
}

/// Cross product magnitude of two 2D vectors (z-component)
#let cross-2d(v1, v2) = {
  v1.at(0) * v2.at(1) - v1.at(1) * v2.at(0)
}

/// Linear interpolation
#let lerp(a, b, t) = a + (b - a) * t

/// Clamp a value between min and max
#let clamp(val, min-val, max-val) = {
  calc.max(min-val, calc.min(max-val, val))
}
