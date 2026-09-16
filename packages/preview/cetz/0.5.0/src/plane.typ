#import "vector.typ"

/// Construct a new plane from a point and a normal vector.
///
/// - pt (vector): The point
/// - n (vector): The plane normal
/// -> Plane
#let from-point-normal(pt, n) = {
  assert.eq(pt.len(), n.len())
  n = vector.norm(n).slice(0, 3)
  return (..n, -vector.dot(pt, n))
}

/// Construct a new plane from three points.
///
/// - a (vector): Point a
/// - b (vector): Point a
/// - c (vector): Point a
/// -> Plane
#let from-points(a, b, c) = {
  let p = (0.0, 0.0, 0.0, 0.0)
  let n = vector.cross(b, c)
  return from-point-normal(a, n)
}

/// Returns plane-line intersection point.
///
/// - p (Plane):
/// - a (vector): Line start
/// - b (vector): Line end
/// -> vector Intersection point
/// -> auto Line is on the plane
/// -> none No intersection
#let intersect-line(p, la, lb) = {
  let (a, b, c, d) = p
  let (dx, dy, dz, ..) = vector.sub(lb, la)
  let denom = a * dx + b * dy + c * dz
  if denom == 0 {
    return auto
  }
  let u = (a * la.at(0) + b * la.at(1) + c * la.at(2) + d) / denom
  return vector.add(la, vector.scale((dx, dy, dz), u))
}
