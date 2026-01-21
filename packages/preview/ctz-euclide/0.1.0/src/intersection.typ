// ctz-euclide/src/intersection.typ
// Intersection algorithms for geometric constructions

#import "util.typ"

/// Line-line intersection using Cramer's rule
/// Returns none if lines are parallel, otherwise the intersection point
///
/// Algorithm (from ctz-euclide):
/// det = Δx₁·Δy₂ - Δy₁·Δx₂
/// x = (c₁·Δx₂ - Δx₁·c₂) / det
/// y = (c₁·Δy₂ - Δy₁·c₂) / det
#let line-line-raw(p1, p2, p3, p4, ray: true, epsilon: util.eps) = {
  let x1 = p1.at(0)
  let y1 = p1.at(1)
  let x2 = p2.at(0)
  let y2 = p2.at(1)
  let x3 = p3.at(0)
  let y3 = p3.at(1)
  let x4 = p4.at(0)
  let y4 = p4.at(1)

  // Direction vectors
  let dx1 = x2 - x1
  let dy1 = y2 - y1
  let dx2 = x4 - x3
  let dy2 = y4 - y3

  // Determinant
  let det = dx1 * dy2 - dy1 * dx2

  if util.approx-zero(det, epsilon: epsilon) {
    // Lines are parallel
    return none
  }

  // Cross products for line equations
  let c1 = x1 * y2 - y1 * x2
  let c2 = x3 * y4 - y3 * x4

  // Intersection point
  let x = (dx1 * c2 - c1 * dx2) / det
  let y = (dy1 * c2 - c1 * dy2) / det

  // Check if intersection is within segments (if not ray mode)
  if not ray {
    // Parameter t for first line: p1 + t*(p2-p1)
    let t1 = if util.approx-zero(dx1) {
      if util.approx-zero(dy1) { 0 } else { (y - y1) / dy1 }
    } else {
      (x - x1) / dx1
    }

    // Parameter t for second line: p3 + t*(p4-p3)
    let t2 = if util.approx-zero(dx2) {
      if util.approx-zero(dy2) { 0 } else { (y - y3) / dy2 }
    } else {
      (x - x3) / dx2
    }

    // Check if within [0, 1] for both segments
    if t1 < -epsilon or t1 > 1 + epsilon or t2 < -epsilon or t2 > 1 + epsilon {
      return none
    }
  }

  (x, y, p1.at(2, default: 0))
}

/// Line-circle intersection
/// Returns array of 0, 1, or 2 intersection points
///
/// Algorithm:
/// 1. Project circle center onto line → H
/// 2. d = distance(center, H)
/// 3. If d > r: no intersection
/// 4. If d ≈ r: tangent (one point)
/// 5. Otherwise: half_chord = sqrt(r² - d²), two points at H ± half_chord * unit_dir
#let line-circle-raw(la, lb, center, radius, epsilon: util.eps) = {
  let ax = la.at(0)
  let ay = la.at(1)
  let bx = lb.at(0)
  let by = lb.at(1)
  let cx = center.at(0)
  let cy = center.at(1)

  // Direction vector of line
  let dx = bx - ax
  let dy = by - ay
  let line-len-sq = dx * dx + dy * dy

  if util.approx-zero(line-len-sq) {
    // Degenerate line (single point)
    let d = util.dist(la, center)
    if util.approx-eq(d, radius, epsilon: epsilon) {
      return (la,)
    }
    return ()
  }

  // Project center onto line: H = A + t*(B-A) where t = dot(AC, AB) / |AB|²
  let t = ((cx - ax) * dx + (cy - ay) * dy) / line-len-sq
  let hx = ax + t * dx
  let hy = ay + t * dy
  let h = (hx, hy, la.at(2, default: 0))

  // Distance from center to projection point
  let d-sq = (hx - cx) * (hx - cx) + (hy - cy) * (hy - cy)
  let d = calc.sqrt(d-sq)
  let r-sq = radius * radius

  if d > radius + epsilon {
    // No intersection
    return ()
  }

  if util.approx-eq(d, radius, epsilon: epsilon) {
    // Tangent - one intersection point
    return (h,)
  }

  // Two intersections
  // half_chord = sqrt(r² - d²)
  let half-chord = calc.sqrt(r-sq - d-sq)

  // Unit direction vector
  let line-len = calc.sqrt(line-len-sq)
  let ux = dx / line-len
  let uy = dy / line-len

  let i1 = (hx - half-chord * ux, hy - half-chord * uy, la.at(2, default: 0))
  let i2 = (hx + half-chord * ux, hy + half-chord * uy, la.at(2, default: 0))

  (i1, i2)
}

/// Circle-circle intersection using Tim Voght's algorithm
/// Returns array of 0, 1, or 2 intersection points
///
/// Algorithm:
/// 1. d = distance between centers
/// 2. Check: d > r0+r1 (no intersection), d < |r0-r1| (one inside other)
/// 3. a = (r0² - r1² + d²) / (2d)
/// 4. P2 = O0 + (O1-O0) * (a/d)
/// 5. h = sqrt(r0² - a²)
/// 6. Intersections = P2 ± perpendicular * (h/d)
#let circle-circle-raw(c0, r0, c1, r1, epsilon: util.eps) = {
  let x0 = c0.at(0)
  let y0 = c0.at(1)
  let x1 = c1.at(0)
  let y1 = c1.at(1)

  // Distance between centers
  let dx = x1 - x0
  let dy = y1 - y0
  let d-sq = dx * dx + dy * dy
  let d = calc.sqrt(d-sq)

  // Check for special cases
  if d < epsilon {
    // Concentric circles - no intersection (or infinite if same radius)
    return ()
  }

  let sum-r = r0 + r1
  let diff-r = calc.abs(r0 - r1)

  if d > sum-r + epsilon {
    // Circles too far apart
    return ()
  }

  if d < diff-r - epsilon {
    // One circle inside the other
    return ()
  }

  // Tim Voght algorithm
  // a = (r0² - r1² + d²) / (2d)
  let a = (r0 * r0 - r1 * r1 + d-sq) / (2 * d)

  // P2 is on the line between centers, at distance 'a' from c0
  let p2x = x0 + (dx * a) / d
  let p2y = y0 + (dy * a) / d

  // Handle tangent case
  let h-sq = r0 * r0 - a * a

  if h-sq < epsilon * epsilon {
    // Tangent - one point
    return ((p2x, p2y, c0.at(2, default: 0)),)
  }

  let h = calc.sqrt(calc.abs(h-sq))

  // Perpendicular to the line between centers
  // perp = (-dy, dx) normalized, scaled by h/d
  let perp-x = -dy * h / d
  let perp-y = dx * h / d

  let i1 = (p2x + perp-x, p2y + perp-y, c0.at(2, default: 0))
  let i2 = (p2x - perp-x, p2y - perp-y, c0.at(2, default: 0))

  (i1, i2)
}
