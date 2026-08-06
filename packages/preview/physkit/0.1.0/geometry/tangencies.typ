#import "vectors.typ": add, sub, scale, magnitude, perpendicular, distance

/// Return the two tangent points from an external point to a circle.
#let circle-tangent-points(point, center, radius) = {
  let d = sub(point, center)
  let d2 = d.at(0) * d.at(0) + d.at(1) * d.at(1)
  assert(d2 > radius * radius,
    message: "A tangent requires a point strictly outside the circle")
  let base = scale(d, radius * radius / d2)
  let offset = scale(
    perpendicular(d),
    radius * calc.sqrt(d2 - radius * radius) / d2,
  )
  (
    add(center, add(base, offset)),
    add(center, sub(base, offset)),
  )
}

/// Select one of two tangent points by a geometric preference.
#let select-tangent(points, preference) = {
  let a = points.at(0)
  let b = points.at(1)
  if preference == "upper" {
    if a.at(1) >= b.at(1) { a } else { b }
  } else if preference == "lower" {
    if a.at(1) <= b.at(1) { a } else { b }
  } else if preference == "right" {
    if a.at(0) >= b.at(0) { a } else { b }
  } else if preference == "left" {
    if a.at(0) <= b.at(0) { a } else { b }
  } else {
    panic("Unknown tangent preference: " + preference)
  }
}

/// Select the candidate closest to a target coordinate.
#let nearest(points, target) = {
  if distance(points.at(0), target) <= distance(points.at(1), target) {
    points.at(0)
  } else {
    points.at(1)
  }
}
