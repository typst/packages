/// Add two 2D vectors.
#let add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))

/// Subtract two 2D vectors.
#let sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))

/// Multiply a 2D vector by a scalar.
#let scale(v, factor) = (v.at(0) * factor, v.at(1) * factor)

/// Midpoint between two coordinates.
#let midpoint(a, b) = scale(add(a, b), 0.5)

/// Euclidean magnitude of a 2D vector.
#let magnitude(v) = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))

/// Normalize a 2D vector.
#let normalize(v) = {
  let length = magnitude(v)
  assert(length != 0, message: "Cannot normalize a zero vector")
  scale(v, 1 / length)
}

/// Rotate a vector counterclockwise.
#let rotate(v, angle) = (
  v.at(0) * calc.cos(angle) - v.at(1) * calc.sin(angle),
  v.at(0) * calc.sin(angle) + v.at(1) * calc.cos(angle),
)

/// Convert local polar coordinates to a canvas coordinate.
#let polar(origin, radius, angle) = add(
  origin,
  (radius * calc.cos(angle), radius * calc.sin(angle)),
)

/// Linear interpolation between two coordinates.
#let lerp(a, b, position) = add(a, scale(sub(b, a), position / 100%))

/// Unit tangent from `start` to `end`.
#let tangent(start, end) = normalize(sub(end, start))

/// Left-hand unit normal from `start` to `end`.
#let normal(start, end) = {
  let t = tangent(start, end)
  (-t.at(1), t.at(0))
}

/// Angle of a vector relative to the positive x axis.
#let angle-of(v) = calc.atan2(v.at(0), v.at(1))
