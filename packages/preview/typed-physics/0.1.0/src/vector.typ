// Plane vectors as `(x, y)` pairs, which is also what CeTZ accepts as a
// coordinate, so a computed position can be handed straight to a draw call.

#let add(first-vector, second-vector) = (
  first-vector.at(0) + second-vector.at(0),
  first-vector.at(1) + second-vector.at(1),
)

#let subtract(minuend-vector, subtrahend-vector) = (
  minuend-vector.at(0) - subtrahend-vector.at(0),
  minuend-vector.at(1) - subtrahend-vector.at(1),
)

#let scale(vector-value, scalar) = (
  vector-value.at(0) * scalar,
  vector-value.at(1) * scalar,
)

#let dot-product(first-vector, second-vector) = (
  first-vector.at(0) * second-vector.at(0)
    + first-vector.at(1) * second-vector.at(1)
)

#let cross-product(first-vector, second-vector) = (
  first-vector.at(0) * second-vector.at(1)
    - first-vector.at(1) * second-vector.at(0)
)

#let magnitude(vector-value) = calc.sqrt(dot-product(vector-value, vector-value))

#let normalized(vector-value) = {
  let vector-magnitude = magnitude(vector-value)
  if vector-magnitude == 0 {
    vector-value
  } else {
    scale(vector-value, 1 / vector-magnitude)
  }
}

#let reversed(vector-value) = scale(vector-value, -1)

// Rotations by a quarter turn. `left-normal` of a surface direction points out
// of the body that surface belongs to when the body lies to its right.
#let left-normal(vector-value) = (-vector-value.at(1), vector-value.at(0))

#let right-normal(vector-value) = (vector-value.at(1), -vector-value.at(0))

#let direction-from-angle(direction-angle) = (
  calc.cos(direction-angle),
  calc.sin(direction-angle),
)

#let angle-of(vector-value) = calc.atan2(
  vector-value.at(0),
  vector-value.at(1),
)

#let point-along(origin, direction, distance) = add(
  origin,
  scale(direction, distance),
)

#let midpoint(first-point, second-point) = scale(
  add(first-point, second-point),
  0.5,
)

// The point a given fraction of the way from one point to another.
#let lerp(start-point, end-point, fraction) = add(
  start-point,
  scale(subtract(end-point, start-point), fraction),
)
