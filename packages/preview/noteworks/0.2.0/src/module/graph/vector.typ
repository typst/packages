// =====================================================
// VECTOR - Vector geometry object (extends point with operations)
// =====================================================

#import "../shape/point.typ": is-point, point, point-3d

/// Create a vector (2D or 3D)
/// Vectors represent direction and magnitude, not position.
///
/// Parameters:
/// - x: X component
/// - y: Y component
/// - z: Z component (optional, none for 2D)
/// - label: Optional label (e.g., $vec(v)$)
/// - origin: Starting point (default: origin)
/// - style: Optional style overrides
#let vector(x, y, z: none, label: none, origin: auto, style: auto) = {
  let default-origin = if z != none { (0, 0, 0) } else { (0, 0) }
  (
    type: "vector",
    x: x,
    y: y,
    z: z,
    label: label,
    origin: if origin == auto { default-origin } else { origin },
    style: style,
  )
}

/// Shorthand for vector - accepts tuple (x, y) or (x, y, z)
#let vec(coords, label: none, origin: auto, style: auto) = {
  if type(coords) == array {
    if coords.len() == 2 {
      vector(coords.at(0), coords.at(1), label: label, origin: origin, style: style)
    } else if coords.len() == 3 {
      vector(coords.at(0), coords.at(1), z: coords.at(2), label: label, origin: origin, style: style)
    } else {
      panic("vec: expected (x, y) or (x, y, z) tuple")
    }
  } else {
    panic("vec: expected array tuple")
  }
}

/// Check if a vector is 3D
#let is-3d-vector(v) = v.at("z", default: none) != none

/// Show vector components (decomposition into x, y, and optionally z parts)
/// Returns array: (main-vector, x-component, y-component, [z-component], helplines-object)
#let vec-components(v, labels: none, helplines: true) = {
  let lx = if labels != none and type(labels) == array and labels.len() > 0 { labels.at(0) } else { none }
  let ly = if labels != none and type(labels) == array and labels.len() > 1 { labels.at(1) } else { none }
  let lz = if labels != none and type(labels) == array and labels.len() > 2 { labels.at(2) } else { none }

  let origin = v.at("origin", default: if is-3d-vector(v) { (0, 0, 0) } else { (0, 0) })

  // Create component vectors
  let result = if is-3d-vector(v) {
    let vx = vector(v.x, 0, z: 0, label: lx, origin: origin)
    let vy = vector(0, v.y, z: 0, label: ly, origin: origin)
    let vz = vector(0, 0, z: v.z, label: lz, origin: origin)
    (v, vx, vy, vz)
  } else {
    let vx = vector(v.x, 0, label: lx, origin: origin)
    let vy = vector(0, v.y, label: ly, origin: origin)
    (v, vx, vy)
  }

  if helplines {
    result.push((
      type: "vec-components-helplines",
      v: v,
      is-3d: is-3d-vector(v),
    ))
  }

  result
}

/// Alias for vector-3d (backward compatibility)
#let vector-3d(x, y, z, label: none, origin: (0, 0, 0), style: auto) = vector(
  x,
  y,
  z: z,
  label: label,
  origin: origin,
  style: style,
)

/// Create a vector from a point (position vector)
#let vector-from-point(p, label: none) = {
  if p.z != none {
    vector-3d(p.x, p.y, p.z, label: label, style: p.style)
  } else {
    vector(p.x, p.y, label: label, style: p.style)
  }
}

/// Check if object is a vector
#let is-vector(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "vector"
}

// =====================================================
// Vector Operations
// =====================================================

/// Add two vectors - returns array: (result-vector, helplines-object)
/// The helplines object draws the parallelogram, result is a simple vector.
#let vec-add(v1, v2, label: none, helplines: true) = {
  let result = if v1.z != none or v2.z != none {
    let z1 = if v1.z == none { 0 } else { v1.z }
    let z2 = if v2.z == none { 0 } else { v2.z }
    vector-3d(v1.x + v2.x, v1.y + v2.y, z1 + z2, label: label)
  } else {
    vector(v1.x + v2.x, v1.y + v2.y, label: label)
  }

  // Return array: result vector + helplines object
  if helplines {
    (
      result,
      (
        type: "vec-add-helplines",
        v1: v1,
        v2: v2,
      ),
    )
  } else {
    (result,)
  }
}

/// Subtract two vectors (v1 - v2)
#let vec-sub(v1, v2) = {
  if v1.z != none or v2.z != none {
    let z1 = if v1.z == none { 0 } else { v1.z }
    let z2 = if v2.z == none { 0 } else { v2.z }
    vector-3d(v1.x - v2.x, v1.y - v2.y, z1 - z2)
  } else {
    vector(v1.x - v2.x, v1.y - v2.y)
  }
}

/// Scale a vector by a scalar
#let vec-scale(v, scalar) = {
  if v.z != none {
    vector-3d(v.x * scalar, v.y * scalar, v.z * scalar, label: v.label, style: v.style)
  } else {
    vector(v.x * scalar, v.y * scalar, label: v.label, style: v.style)
  }
}

/// Negate a vector
#let vec-neg(v) = vec-scale(v, -1)

/// Dot product of two vectors
#let vec-dot(v1, v2) = {
  let result = v1.x * v2.x + v1.y * v2.y
  if v1.z != none and v2.z != none {
    result += v1.z * v2.z
  }
  result
}

/// Cross product of two 3D vectors (returns a 3D vector)
#let vec-cross(v1, v2) = {
  let z1 = if v1.z == none { 0 } else { v1.z }
  let z2 = if v2.z == none { 0 } else { v2.z }

  vector-3d(
    v1.y * z2 - z1 * v2.y,
    z1 * v2.x - v1.x * z2,
    v1.x * v2.y - v1.y * v2.x,
  )
}

/// Magnitude (length) of a vector
#let vec-magnitude(v) = {
  if v.z != none {
    calc.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
  } else {
    calc.sqrt(v.x * v.x + v.y * v.y)
  }
}

/// Alias for magnitude
#let vec-length = vec-magnitude

/// Get unit vector (normalized)
#let vec-normalize(v) = {
  let mag = vec-magnitude(v)
  if mag == 0 { v } else { vec-scale(v, 1 / mag) }
}

/// Alias for normalize
#let vec-unit = vec-normalize

/// Project v1 onto v2 - returns array: (projection-vector, helplines-object)
/// Supports: vec-project(v1, v2) or vec-project(v1, onto: v2)
#let vec-project(v1, v2: none, onto: none, label: none, helplines: true) = {
  // Handle both vec-project(v1, v2) and vec-project(v1, onto: v2)
  let target = if v2 != none { v2 } else if onto != none { onto } else {
    panic("vec-project: must provide v2 or onto:")
  }

  let dot = vec-dot(v1, target)
  let mag-sq = vec-dot(target, target)
  if mag-sq == 0 {
    (vector(0, 0, label: label),)
  } else {
    let proj = vec-scale(target, dot / mag-sq)
    let result = proj + (label: label)

    if helplines {
      (
        result,
        (
          type: "vec-proj-helplines",
          v1: v1,
          v2: target,
          proj: result,
        ),
      )
    } else {
      (result,)
    }
  }
}

/// Angle between two vectors in radians
#let vec-angle-between(v1, v2) = {
  let dot = vec-dot(v1, v2)
  let m1 = vec-magnitude(v1)
  let m2 = vec-magnitude(v2)
  if m1 == 0 or m2 == 0 { 0 } else {
    calc.acos(dot / (m1 * m2))
  }
}

/// Check if two vectors are parallel
#let vec-parallel(v1, v2) = {
  let cross = v1.x * v2.y - v1.y * v2.x
  calc.abs(cross) < 0.0001
}

/// Check if two vectors are perpendicular
#let vec-perpendicular(v1, v2) = {
  calc.abs(vec-dot(v1, v2)) < 0.0001
}
