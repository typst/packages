// =====================================================
// INTERSECT - Intersection operations between geometry objects
// =====================================================

#import "point.typ": is-point, point
#import "line.typ": is-line, is-ray, is-segment
#import "circle.typ": is-circle

// =====================================================
// Generic Intersection Dispatcher
// =====================================================

/// Find intersection between two geometry objects
/// Returns: Point, array of points, or none
#let intersect(obj1, obj2) = {
  let t1 = obj1.type
  let t2 = obj2.type

  if (t1 == "line" or t1 == "segment" or t1 == "ray") and (t2 == "line" or t2 == "segment" or t2 == "ray") {
    intersect-linear-linear(obj1, obj2)
  } else if (t1 == "line" or t1 == "segment" or t1 == "ray") and t2 == "circle" {
    intersect-linear-circle(obj1, obj2)
  } else if t1 == "circle" and (t2 == "line" or t2 == "segment" or t2 == "ray") {
    intersect-linear-circle(obj2, obj1)
  } else if t1 == "circle" and t2 == "circle" {
    intersect-circle-circle(obj1, obj2)
  } else {
    panic("intersect: unsupported types " + t1 + " and " + t2)
  }
}

// =====================================================
// Line-Line Intersection
// =====================================================

/// Intersection of two linear objects (line, segment, or ray)
/// Uses parametric form and checks bounds for segments/rays
#let intersect-linear-linear(l1, l2) = {
  // Get endpoints/points
  let p1 = if l1.type == "ray" { l1.origin } else { l1.p1 }
  let p2 = if l1.type == "ray" { l1.through } else { l1.p2 }
  let p3 = if l2.type == "ray" { l2.origin } else { l2.p1 }
  let p4 = if l2.type == "ray" { l2.through } else { l2.p2 }

  let x1 = p1.x
  let y1 = p1.y
  let x2 = p2.x
  let y2 = p2.y
  let x3 = p3.x
  let y3 = p3.y
  let x4 = p4.x
  let y4 = p4.y

  // Denominator of parametric form
  let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

  if calc.abs(denom) < 0.0001 {
    // Lines are parallel (or coincident)
    return none
  }

  // Parameters t and u for the intersection point
  let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
  let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom

  // Check if intersection is within bounds for segments/rays
  let valid-t = if l1.type == "segment" {
    t >= 0 and t <= 1
  } else if l1.type == "ray" {
    t >= 0
  } else {
    true // line extends infinitely
  }

  let valid-u = if l2.type == "segment" {
    u >= 0 and u <= 1
  } else if l2.type == "ray" {
    u >= 0
  } else {
    true
  }

  if valid-t and valid-u {
    point(x1 + t * (x2 - x1), y1 + t * (y2 - y1))
  } else {
    none
  }
}

/// Convenience alias for line-line intersection with labeling
#let intersect-ll(l1, l2, label: none) = {
  let p = intersect-linear-linear(l1, l2)
  if p != none {
    point(p.x, p.y, label: label)
  } else {
    none
  }
}

// =====================================================
// Line-Circle Intersection
// =====================================================

/// Intersection of a linear object with a circle
/// Returns array of 0, 1, or 2 points
#let intersect-linear-circle(linear, circ) = {
  let p1 = if linear.type == "ray" { linear.origin } else { linear.p1 }
  let p2 = if linear.type == "ray" { linear.through } else { linear.p2 }

  let cx = circ.center.x
  let cy = circ.center.y
  let r = circ.radius

  // Direction vector
  let dx = p2.x - p1.x
  let dy = p2.y - p1.y

  // Vector from circle center to line start
  let fx = p1.x - cx
  let fy = p1.y - cy

  // Quadratic coefficients: a*t^2 + b*t + c = 0
  let a = dx * dx + dy * dy
  let b = 2 * (fx * dx + fy * dy)
  let c = fx * fx + fy * fy - r * r

  let discriminant = b * b - 4 * a * c

  if discriminant < 0 {
    // No intersection
    ()
  } else if discriminant == 0 {
    // Tangent - one point
    let t = -b / (2 * a)

    // Check bounds
    let valid = if linear.type == "segment" {
      t >= 0 and t <= 1
    } else if linear.type == "ray" {
      t >= 0
    } else {
      true
    }

    if valid {
      (point(p1.x + t * dx, p1.y + t * dy),)
    } else {
      ()
    }
  } else {
    // Two intersection points
    let sqrt-disc = calc.sqrt(discriminant)
    let t1 = (-b - sqrt-disc) / (2 * a)
    let t2 = (-b + sqrt-disc) / (2 * a)

    let results = ()

    for t in (t1, t2) {
      let valid = if linear.type == "segment" {
        t >= 0 and t <= 1
      } else if linear.type == "ray" {
        t >= 0
      } else {
        true
      }

      if valid {
        results = results + (point(p1.x + t * dx, p1.y + t * dy),)
      }
    }

    results
  }
}

/// Convenience alias for line-circle intersection with labeling
#let intersect-lc(l, c, labels: none) = {
  let pts = intersect-linear-circle(l, c)
  let res = ()

  if type(labels) == array {
    for (i, p) in pts.enumerate() {
      let lbl = if i < labels.len() { labels.at(i) } else { none }
      res.push(point(p.x, p.y, label: lbl))
    }
  } else {
    // If not array, don't label individually (or apply same label?)
    for p in pts {
      res.push(p)
    }
  }
  res
}

// =====================================================
// Circle-Circle Intersection
// =====================================================

/// Intersection of two circles
/// Returns array of 0, 1, or 2 points
#let intersect-circle-circle(c1, c2) = {
  let x1 = c1.center.x
  let y1 = c1.center.y
  let r1 = c1.radius
  let x2 = c2.center.x
  let y2 = c2.center.y
  let r2 = c2.radius

  let dx = x2 - x1
  let dy = y2 - y1
  let d = calc.sqrt(dx * dx + dy * dy)

  // Check for no intersection cases
  if d > r1 + r2 {
    // Circles too far apart
    return ()
  }
  if d < calc.abs(r1 - r2) {
    // One circle inside the other
    return ()
  }
  if d == 0 and r1 == r2 {
    // Circles are identical
    return ()
  }

  // Distance from c1 center to radical line
  let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)

  // Height from radical line to intersection points
  let h-sq = r1 * r1 - a * a
  if h-sq < 0 { return () }
  let h = calc.sqrt(h-sq)

  // Point on line between centers
  let px = x1 + a * dx / d
  let py = y1 + a * dy / d

  if h == 0 {
    // Tangent - one point
    (point(px, py),)
  } else {
    // Two points
    (
      point(px + h * dy / d, py - h * dx / d),
      point(px - h * dy / d, py + h * dx / d),
    )
  }
}

/// Convenience alias for circle-circle intersection with labeling
#let intersect-cc(c1, c2, labels: none) = {
  let pts = intersect-circle-circle(c1, c2)
  let res = ()

  if type(labels) == array {
    for (i, p) in pts.enumerate() {
      let lbl = if i < labels.len() { labels.at(i) } else { none }
      res.push(point(p.x, p.y, label: lbl))
    }
  } else {
    for p in pts {
      res.push(p)
    }
  }
  res
}

// =====================================================
// Utility Functions
// =====================================================

/// Check if a point lies on a linear object
#let point-on-linear(pt, linear) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }

  let p1 = if linear.type == "ray" { linear.origin } else { linear.p1 }
  let p2 = if linear.type == "ray" { linear.through } else { linear.p2 }

  let dx = p2.x - p1.x
  let dy = p2.y - p1.y

  // Check collinearity using cross product
  let cross = (p.x - p1.x) * dy - (p.y - p1.y) * dx
  if calc.abs(cross) > 0.0001 { return false }

  // Check parameter bounds
  if dx != 0 {
    let t = (p.x - p1.x) / dx
    if linear.type == "segment" { t >= 0 and t <= 1 } else if linear.type == "ray" { t >= 0 } else { true }
  } else if dy != 0 {
    let t = (p.y - p1.y) / dy
    if linear.type == "segment" { t >= 0 and t <= 1 } else if linear.type == "ray" { t >= 0 } else { true }
  } else {
    // Degenerate line (single point)
    calc.abs(p.x - p1.x) < 0.0001 and calc.abs(p.y - p1.y) < 0.0001
  }
}

/// Check if a point lies on a circle
#let point-on-circle(pt, circ) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }

  let dx = p.x - circ.center.x
  let dy = p.y - circ.center.y
  let dist = calc.sqrt(dx * dx + dy * dy)

  calc.abs(dist - circ.radius) < 0.0001
}

// =====================================================
// Function Intersection (Newton's Method)
// =====================================================

#let intersect-function-function(f1, f2, x0: 0, max-iter: 200, tolerance: 1e-6, label: none, label-anchor: "north", label-padding: 0.2) = {
  let h = 0.00001
  let g(x) = f1(x) - f2(x)
  // Use central difference to approximate the derivative of g
  let g-prime(x) = (g(x + h) - g(x - h)) / (2 * h)

  let x = float(x0)
  for i in range(max-iter) {
    let gx = g(x)
    if calc.abs(gx) < tolerance {
      return point(x, f1(x), label: label, label-anchor: label-anchor, label-padding: label-padding)
    }
    let gpx = g-prime(x)
    if gpx == 0 {
      // Avoid division by zero (occurs at local extremum).
      return none
    }
    x = x - gx / gpx
  }
  // Did not converge within max-iter.
  return none
}

#let intersect-function-line(f, linear, x0: 0, max-iter: 200, tolerance: 1e-6, label: none, label-anchor: "north", label-padding: 0.2) = {
  let p1 = if linear.type == "ray" { linear.origin } else { linear.p1 }
  let p2 = if linear.type == "ray" { linear.through } else { linear.p2 }

  // Handle vertical line case
  if calc.abs(p1.x - p2.x) < 1e-9 {
    let x = p1.x
    let p = point(x, f(x), label: label, label-padding: label-padding, label-anchor: label-anchor)
    if point-on-linear(p, linear) {
      return p
    } else {
      return none
    }
  }

  let m = (p2.y - p1.y) / (p2.x - p1.x)
  let c = p1.y - m * p1.x
  let line-func(x) = m * x + c

  let p = intersect-function-function(f, line-func, x0: x0, max-iter: max-iter, tolerance: tolerance, label: label, label-anchor: label-anchor, label-padding: label-padding)

  if p != none and point-on-linear(p, linear) {
    p
  } else {
    none
  }
}
