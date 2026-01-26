// ctz-euclide/src/transform.typ
// Point transformations (rotation, reflection, translation, etc.)

#import "util.typ"

/// Rotate a point around a center by a given angle (in degrees or angle type)
#let rotation-raw(point, center, angle-deg) = {
  let ang = util.to-angle(angle-deg)
  util.rotate-point(point, center, ang)
}

/// Reflect a point across a line defined by two points
#let reflection-raw(point, line-a, line-b) = {
  // Project point onto line
  let foot = util.project-point-on-line(point, line-a, line-b)

  // Reflect: point' = 2*foot - point
  (
    2 * foot.at(0) - point.at(0),
    2 * foot.at(1) - point.at(1),
    point.at(2, default: 0),
  )
}

/// Translate a point by a vector
#let translation-raw(point, vector) = {
  (
    point.at(0) + vector.at(0),
    point.at(1) + vector.at(1),
    point.at(2, default: 0),
  )
}

/// Scale a point from a center by a factor
#let homothety-raw(point, center, factor) = {
  (
    center.at(0) + factor * (point.at(0) - center.at(0)),
    center.at(1) + factor * (point.at(1) - center.at(1)),
    point.at(2, default: 0),
  )
}

/// Project a point onto a line (foot of perpendicular)
#let projection-raw(point, line-a, line-b) = {
  util.project-point-on-line(point, line-a, line-b)
}

/// Get point on circle at given angle (in degrees or angle type)
#let point-on-circle-raw(center, radius, angle-deg) = {
  util.point-on-circle(center, radius, util.to-degrees(angle-deg))
}
