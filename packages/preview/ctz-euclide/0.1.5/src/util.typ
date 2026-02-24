// ctz-euclide/src/util.typ
// Utility functions for geometric calculations

// =============================================================================
// EPSILON CONSTANTS
// =============================================================================

/// Small epsilon for exact equality checks (floating point comparisons)
#let eps = 1e-9

/// Epsilon for geometric comparisons (intersections, tangents)
#let eps-geometric = 1e-6

/// Epsilon for visual/rendering comparisons
#let eps-visual = 1e-3

// =============================================================================
// ANGLE CONVERSION HELPERS
// =============================================================================

/// Convert a value to an angle type
/// - val: number (degrees) or angle
/// Returns: angle
#let to-angle(val) = {
  if type(val) == angle { val } else { val * 1deg }
}

/// Convert an angle to degrees (number)
/// - val: angle or number
/// Returns: float (degrees)
#let to-degrees(val) = {
  if type(val) == angle { val / 1deg } else { val }
}

// =============================================================================
// VECTOR HELPERS
// =============================================================================

/// Return perpendicular vector (90° counter-clockwise rotation)
/// - v: 2D vector as (x, y)
/// Returns: (-y, x)
#let perpendicular(v) = (-v.at(1), v.at(0))

/// Check if two floats are approximately equal
#let approx-eq(a, b, epsilon: eps) = {
  calc.abs(a - b) < epsilon
}

/// Check if a float is approximately zero
#let approx-zero(a, epsilon: eps) = {
  calc.abs(a) < epsilon
}

/// Clamp a value between min and max
#let clamp(val, min-val, max-val) = {
  calc.max(min-val, calc.min(max-val, val))
}

/// Calculate the squared distance between two points (avoids sqrt)
#let dist-sq(a, b) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  dx * dx + dy * dy
}

/// Calculate the distance between two points
#let dist(a, b) = {
  calc.sqrt(dist-sq(a, b))
}

/// Calculate the midpoint between two points
#let midpoint(a, b) = {
  (
    (a.at(0) + b.at(0)) / 2,
    (a.at(1) + b.at(1)) / 2,
    a.at(2, default: 0),
  )
}

/// Calculate angle from point a to point b (in degrees)
#let angle-to(a, b) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  calc.atan2(dx, dy)
}

/// Project point p onto line defined by points a and b
/// Returns the foot of perpendicular from p to line ab
#let project-point-on-line(p, a, b) = {
  let ax = a.at(0)
  let ay = a.at(1)
  let bx = b.at(0)
  let by = b.at(1)
  let px = p.at(0)
  let py = p.at(1)

  // Vector from a to p
  let apx = px - ax
  let apy = py - ay

  // Vector from a to b
  let abx = bx - ax
  let aby = by - ay

  // Squared length of ab
  let ab-sq = abx * abx + aby * aby

  if approx-zero(ab-sq) {
    // a and b are the same point
    return (ax, ay, a.at(2, default: 0))
  }

  // Project ap onto ab: t = (ap . ab) / |ab|^2
  let t = (apx * abx + apy * aby) / ab-sq

  // Foot of perpendicular
  (
    ax + t * abx,
    ay + t * aby,
    a.at(2, default: 0),
  )
}

/// Rotate a point around a center by given angle
#let rotate-point(p, center, angle) = {
  let px = p.at(0) - center.at(0)
  let py = p.at(1) - center.at(1)

  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)

  (
    center.at(0) + px * cos-a - py * sin-a,
    center.at(1) + px * sin-a + py * cos-a,
    p.at(2, default: 0),
  )
}

/// Calculate the perpendicular bisector of segment ab
/// Returns two points on the bisector
#let perpendicular-bisector(a, b) = {
  let mid = midpoint(a, b)

  // Direction perpendicular to ab
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)

  // Perpendicular direction: (-dy, dx)
  let perp-x = -dy
  let perp-y = dx

  // Two points on the bisector
  let p1 = (mid.at(0) + perp-x, mid.at(1) + perp-y, mid.at(2))
  let p2 = (mid.at(0) - perp-x, mid.at(1) - perp-y, mid.at(2))

  (p1, p2, mid)
}

/// Calculate the angle bisector from vertex v between points a and c
/// Returns a point on the bisector (not the vertex itself)
#let angle-bisector-point(a, v, c) = {
  // Normalize vectors va and vc
  let va-x = a.at(0) - v.at(0)
  let va-y = a.at(1) - v.at(1)
  let vc-x = c.at(0) - v.at(0)
  let vc-y = c.at(1) - v.at(1)

  let va-len = calc.sqrt(va-x * va-x + va-y * va-y)
  let vc-len = calc.sqrt(vc-x * vc-x + vc-y * vc-y)

  if approx-zero(va-len) or approx-zero(vc-len) {
    return v
  }

  // Normalize
  va-x = va-x / va-len
  va-y = va-y / va-len
  vc-x = vc-x / vc-len
  vc-y = vc-y / vc-len

  // Bisector direction is sum of unit vectors
  let bis-x = va-x + vc-x
  let bis-y = va-y + vc-y

  (
    v.at(0) + bis-x,
    v.at(1) + bis-y,
    v.at(2, default: 0),
  )
}

// =============================================================================
// POINT CONSTRUCTIONS
// =============================================================================

/// Calculate the third vertex of an equilateral triangle given two vertices
/// Returns the point on the left side (counterclockwise)
#let equilateral-point(a, b) = {
  rotate-point(b, a, 60deg)
}

/// Calculate the third and fourth vertices of a square given two adjacent vertices
/// Returns (c, d) where ABCD forms a square counterclockwise
#let square-points(a, b) = {
  let c = rotate-point(a, b, -90deg)
  let d = rotate-point(b, a, 90deg)
  (c, d)
}

/// Calculate the golden ratio division point on segment AB
/// Returns point C such that AC/CB = phi (golden ratio ≈ 1.618)
#let golden-ratio-point(a, b) = {
  let phi = (1 + calc.sqrt(5)) / 2  // ≈ 1.618
  let ratio = 1 / phi  // ≈ 0.618

  (
    a.at(0) + ratio * (b.at(0) - a.at(0)),
    a.at(1) + ratio * (b.at(1) - a.at(1)),
    a.at(2, default: 0),
  )
}

/// Calculate a barycentric point given vertices and weights
#let barycentric-point(a, b, c, wa, wb, wc) = {
  let total = wa + wb + wc

  if approx-zero(total) {
    return a
  }

  (
    (wa * a.at(0) + wb * b.at(0) + wc * c.at(0)) / total,
    (wa * a.at(1) + wb * b.at(1) + wc * c.at(1)) / total,
    a.at(2, default: 0),
  )
}

/// Calculate a point on a circle at given angle
#let point-on-circle(center, radius, angle-deg) = {
  let angle-rad = angle-deg * calc.pi / 180
  (
    center.at(0) + radius * calc.cos(angle-rad),
    center.at(1) + radius * calc.sin(angle-rad),
    center.at(2, default: 0),
  )
}

/// Calculate a linear combination point: P = A + k * (B - A)
#let linear-point(a, b, k) = {
  (
    a.at(0) + k * (b.at(0) - a.at(0)),
    a.at(1) + k * (b.at(1) - a.at(1)),
    a.at(2, default: 0),
  )
}

/// Calculate an orthogonal point: perpendicular from A through B with optional factor
#let orthogonal-point(a, b, k: 1) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)

  // Perpendicular direction: (-dy, dx)
  (
    a.at(0) - k * dy,
    a.at(1) + k * dx,
    a.at(2, default: 0),
  )
}

/// Calculate a point by translation
#let translate-point(p, dx, dy) = {
  (p.at(0) + dx, p.at(1) + dy, p.at(2, default: 0))
}

/// Central symmetry: reflect point P through center O
#let central-symmetry(p, center) = {
  (
    2 * center.at(0) - p.at(0),
    2 * center.at(1) - p.at(1),
    p.at(2, default: 0),
  )
}

/// Inversion of point P through circle (center O, radius r)
/// Returns P' such that OP * OP' = r²
#let circle-inversion(p, center, radius) = {
  let d-sq = dist-sq(p, center)

  if approx-zero(d-sq) {
    // P is at center, undefined
    return p
  }

  let factor = (radius * radius) / d-sq

  (
    center.at(0) + factor * (p.at(0) - center.at(0)),
    center.at(1) + factor * (p.at(1) - center.at(1)),
    p.at(2, default: 0),
  )
}

/// Regular polygon vertices (n-gon with center O and first vertex A)
#let regular-polygon-vertices(center, first-vertex, n) = {
  let angle-step = 360 / n
  let vertices = ()

  for i in range(n) {
    vertices.push(rotate-point(first-vertex, center, i * angle-step * 1deg))
  }

  vertices
}

// =============================================================================
// CALCULATIONS
// =============================================================================

/// Calculate the angle ABC (at vertex B) in degrees
#let angle-at-vertex(a, b, c) = {
  let ba-x = a.at(0) - b.at(0)
  let ba-y = a.at(1) - b.at(1)
  let bc-x = c.at(0) - b.at(0)
  let bc-y = c.at(1) - b.at(1)

  let dot = ba-x * bc-x + ba-y * bc-y
  let ba-len = calc.sqrt(ba-x * ba-x + ba-y * ba-y)
  let bc-len = calc.sqrt(bc-x * bc-x + bc-y * bc-y)

  if approx-zero(ba-len) or approx-zero(bc-len) {
    return 0
  }

  let cos-angle = clamp(dot / (ba-len * bc-len), -1, 1)
  calc.acos(cos-angle) / 1deg
}

/// Calculate the slope angle of line AB (in degrees)
#let slope-angle(a, b) = {
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)

  if approx-zero(dx) and approx-zero(dy) {
    return 0
  }

  calc.atan2(dy, dx) / 1deg
}

/// Calculate the area of triangle ABC
#let triangle-area(a, b, c) = {
  let abx = b.at(0) - a.at(0)
  let aby = b.at(1) - a.at(1)
  let acx = c.at(0) - a.at(0)
  let acy = c.at(1) - a.at(1)

  calc.abs(abx * acy - aby * acx) / 2
}

/// Calculate the area of a polygon given its vertices
#let polygon-area(..vertices) = {
  let pts = vertices.pos()
  let n = pts.len()

  if n < 3 { return 0 }

  let area = 0
  for i in range(n) {
    let j = calc.rem(i + 1, n)
    area = area + pts.at(i).at(0) * pts.at(j).at(1)
    area = area - pts.at(j).at(0) * pts.at(i).at(1)
  }

  calc.abs(area) / 2
}

/// Calculate the ratio AB/AC
#let ratio(a, b, c) = {
  let ab = dist(a, b)
  let ac = dist(a, c)

  if approx-zero(ac) { return 0 }
  ab / ac
}

// =============================================================================
// VALIDATION HELPERS
// =============================================================================

/// Assert that a value is positive, panic otherwise
#let assert-positive(val, name: "value") = {
  assert(val > 0, message: name + " must be positive, got " + str(val))
}

/// Assert that two points are distinct
#let assert-distinct(p1, p2, name1: "p1", name2: "p2") = {
  assert(dist(p1, p2) > eps, message: name1 + " and " + name2 + " must be distinct")
}

/// Assert that three points are not collinear
#let assert-not-collinear(a, b, c) = {
  let cross = (b.at(0) - a.at(0)) * (c.at(1) - a.at(1)) - (b.at(1) - a.at(1)) * (c.at(0) - a.at(0))
  assert(calc.abs(cross) > eps, message: "Points must not be collinear")
}
