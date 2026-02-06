// ctz-euclide/src/circle.typ
// Circle definitions and related calculations

#import "util.typ"
#import "triangle.typ"
#import "intersection.typ": line-line-raw

// =============================================================================
// CIRCLE DEFINITIONS
// =============================================================================

/// Define a circle through a point (center + through point)
/// Returns (center, radius)
#let circle-through-raw(center, through) = {
  util.assert-distinct(center, through, name1: "center", name2: "through")
  let radius = util.dist(center, through)
  (center, radius)
}

/// Define a circle by diameter (two endpoints)
/// Returns (center, radius)
#let circle-diameter-raw(a, b) = {
  let center = util.midpoint(a, b)
  let radius = util.dist(a, b) / 2
  (center, radius)
}

/// Define circumcircle of triangle
/// Returns (center, radius)
#let circle-circum-raw(a, b, c) = {
  let center = triangle.circumcenter-raw(a, b, c)
  let radius = triangle.circumradius-raw(a, b, c)
  (center, radius)
}

/// Define incircle of triangle
/// Returns (center, radius)
#let circle-in-raw(a, b, c) = {
  let center = triangle.incenter-raw(a, b, c)
  let radius = triangle.inradius-raw(a, b, c)
  (center, radius)
}

/// Define excircle of triangle opposite to vertex
/// vertex: "a", "b", or "c"
/// Returns (center, radius)
#let circle-ex-raw(a, b, c, vertex: "a") = {
  let center = triangle.excenter-raw(a, b, c, vertex: vertex)
  let radius = triangle.exradius-raw(a, b, c, vertex: vertex)
  (center, radius)
}

/// Define nine-point (Euler) circle of triangle
/// Returns (center, radius)
#let circle-euler-raw(a, b, c) = {
  let center = triangle.euler-center-raw(a, b, c)
  let radius = triangle.euler-radius-raw(a, b, c)
  (center, radius)
}

/// Define Spieker circle (incircle of medial triangle)
/// Returns (center, radius)
#let circle-spieker-raw(a, b, c) = {
  let (ma, mb, mc) = triangle.medial-triangle-raw(a, b, c)
  let center = triangle.incenter-raw(ma, mb, mc)
  let radius = triangle.inradius-raw(ma, mb, mc)
  (center, radius)
}

// =============================================================================
// TANGENT CALCULATIONS
// =============================================================================

/// Calculate tangent points from external point P to circle (center O, radius r)
/// Returns array of tangent points (0, 1, or 2 points)
#let tangent-from-point-raw(external-point, center, radius) = {
  util.assert-positive(radius, name: "radius")
  let d = util.dist(external-point, center)

  // Point inside or on circle - no tangent
  if d <= radius + util.eps {
    if util.approx-eq(d, radius, epsilon: util.eps) {
      // Point on circle - tangent at that point
      return (external-point,)
    }
    return ()
  }

  // Distance from center to tangent point along line to external point
  // Using right triangle: d² = r² + t², where t is tangent length
  let tangent-length = calc.sqrt(d * d - radius * radius)

  // Angle from center to external point
  let angle-to-p = calc.atan2(
    external-point.at(1) - center.at(1),
    external-point.at(0) - center.at(0)
  )

  // Angle offset for tangent points
  let angle-offset = calc.asin(radius / d)

  // Convert to proper angle type
  let angle-deg = util.to-angle(util.to-degrees(angle-to-p))
  let offset-deg = util.to-angle(util.to-degrees(angle-offset))

  // Two tangent points
  let t1 = (
    center.at(0) + radius * calc.cos(angle-deg + offset-deg),
    center.at(1) + radius * calc.sin(angle-deg + offset-deg),
    center.at(2, default: 0),
  )

  let t2 = (
    center.at(0) + radius * calc.cos(angle-deg - offset-deg),
    center.at(1) + radius * calc.sin(angle-deg - offset-deg),
    center.at(2, default: 0),
  )

  (t1, t2)
}

/// Calculate tangent line at point on circle
/// Returns two points defining the tangent line
#let tangent-at-point-raw(point-on-circle, center) = {
  // Tangent is perpendicular to radius
  let dx = point-on-circle.at(0) - center.at(0)
  let dy = point-on-circle.at(1) - center.at(1)

  // Perpendicular direction: (-dy, dx)
  let p1 = (
    point-on-circle.at(0) - dy,
    point-on-circle.at(1) + dx,
    point-on-circle.at(2, default: 0),
  )

  let p2 = (
    point-on-circle.at(0) + dy,
    point-on-circle.at(1) - dx,
    point-on-circle.at(2, default: 0),
  )

  (p1, p2)
}

// =============================================================================
// RADICAL AXIS
// =============================================================================

/// Calculate two points on the radical axis of two circles
/// The radical axis is the locus of points with equal power wrt both circles
/// Returns (p1, p2) two points on the radical axis
#let radical-axis-raw(c1, r1, c2, r2) = {
  let dx = c2.at(0) - c1.at(0)
  let dy = c2.at(1) - c1.at(1)
  let d = calc.sqrt(dx * dx + dy * dy)

  if util.approx-zero(d) {
    // Concentric circles - no radical axis (or infinite)
    return none
  }

  // Distance from c1 to radical axis along c1-c2 line
  // Using: k = (d² + r1² - r2²) / (2d)
  let k = (d * d + r1 * r1 - r2 * r2) / (2 * d)

  // Point on radical axis (on the line c1-c2)
  let px = c1.at(0) + k * dx / d
  let py = c1.at(1) + k * dy / d

  // Radical axis is perpendicular to c1-c2
  // Direction perpendicular: (-dy, dx)
  let perp-x = -dy / d
  let perp-y = dx / d

  let p1 = (px + perp-x, py + perp-y, c1.at(2, default: 0))
  let p2 = (px - perp-x, py - perp-y, c1.at(2, default: 0))

  (p1, p2)
}

// =============================================================================
// APOLLONIUS CIRCLE
// =============================================================================

/// Calculate Apollonius circle - locus of points with constant ratio of distances to two points
/// k = ratio PA/PB
/// Returns (center, radius)
#let apollonius-circle-raw(a, b, k) = {
  if util.approx-eq(k, 1, epsilon: util.eps) {
    // k = 1 gives perpendicular bisector (infinite radius)
    return none
  }

  let k-sq = k * k

  // Center divides AB in ratio k²:1 (externally if k > 1, internally if k < 1)
  // Internal division point: (A + k²B) / (1 + k²)
  // External division point: (A - k²B) / (1 - k²) when k ≠ 1

  // For Apollonius circle:
  // Center = (k² * A - B) / (k² - 1) when k > 1
  // or use the formula directly

  let denom = k-sq - 1

  let cx = (k-sq * b.at(0) - a.at(0)) / denom
  let cy = (k-sq * b.at(1) - a.at(1)) / denom

  let center = (cx, cy, a.at(2, default: 0))

  // Radius = k * |AB| / |k² - 1|
  let ab = util.dist(a, b)
  let radius = k * ab / calc.abs(denom)

  (center, radius)
}

// =============================================================================
// ORTHOGONAL CIRCLES
// =============================================================================

/// Check if two circles are orthogonal (intersect at right angles)
#let circles-orthogonal(c1, r1, c2, r2) = {
  let d-sq = util.dist-sq(c1, c2)
  let r-sq-sum = r1 * r1 + r2 * r2

  util.approx-eq(d-sq, r-sq-sum, epsilon: util.eps)
}

/// Calculate a circle orthogonal to given circle passing through a point
/// Returns (center, radius) or none if impossible
#let orthogonal-circle-through-raw(circle-center, circle-radius, through-point) = {
  // The center of any orthogonal circle lies on the radical axis
  // For a circle through P orthogonal to C(O, r), the center lies on
  // the perpendicular bisector of OP shifted by r²/(2*OP) towards O

  let d = util.dist(circle-center, through-point)

  if util.approx-zero(d) {
    // Point at center - infinite solutions
    return none
  }

  // For orthogonality: d² = r1² + r², where d is center distance
  // and r1 is the new circle's radius

  // The locus of centers of circles through P orthogonal to C(O,r)
  // is a line perpendicular to OP

  // For simplicity, return the circle with center on line OP
  // extended beyond P
  let dx = through-point.at(0) - circle-center.at(0)
  let dy = through-point.at(1) - circle-center.at(1)

  // New radius: we want orthogonality
  // If new center is at distance D from O, and passes through P at distance d,
  // we need D² = r² + R² (orthogonality) and |center - P| = R

  // One solution: center is on ray from O through P, beyond P
  // Let center = P + t*(P-O)/|P-O| for some t > 0
  // Then D = d + t, R = t
  // Orthogonality: (d+t)² = r² + t²
  // d² + 2dt + t² = r² + t²
  // d² + 2dt = r²
  // t = (r² - d²) / (2d)

  let t = (circle-radius * circle-radius - d * d) / (2 * d)

  if t <= 0 {
    // Point outside or on circle - different construction needed
    // Use tangent from point instead
    let tangent-len-sq = d * d - circle-radius * circle-radius
    if tangent-len-sq < 0 { return none }
    let tangent-len = calc.sqrt(tangent-len-sq)

    // Center on perpendicular at P, at distance tangent-len
    let perp-x = -dy / d
    let perp-y = dx / d

    let center = (
      through-point.at(0) + tangent-len * perp-x,
      through-point.at(1) + tangent-len * perp-y,
      through-point.at(2, default: 0),
    )

    return (center, tangent-len)
  }

  let center = (
    through-point.at(0) + t * dx / d,
    through-point.at(1) + t * dy / d,
    through-point.at(2, default: 0),
  )

  (center, t)
}
