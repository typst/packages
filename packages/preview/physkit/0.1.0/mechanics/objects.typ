#import "../core/model.typ": id
#import "../geometry/lib.typ": polar

/// Construct a rectangular body.
#let box(
  object-id,
  at: none,
  width: 1.2,
  height: 0.8,
  angle: 0deg,
  label: none,
  label-offset: (0, 0),
  label-anchor: "center",
  fill: none,
) = {
  assert(width > 0 and height > 0,
    message: "Box width and height must be positive")
  (
    kind: "box",
    id: id(object-id),
    at: at,
    width: width,
    height: height,
    angle: angle,
    label: label,
    label-offset: label-offset,
    label-anchor: label-anchor,
    fill: fill,
  )
}

/// Construct a circular pulley.
#let pulley(
  object-id,
  at: none,
  radius: 0.55,
  label: none,
  label-offset: none,
  label-anchor: "center",
) = {
  assert(radius > 0, message: "Pulley radius must be positive")
  (
    kind: "pulley",
    id: id(object-id),
    at: at,
    radius: radius,
    label: label,
    label-offset: label-offset,
    label-anchor: label-anchor,
  )
}

/// Construct a generic finite surface.
#let surface(
  object-id,
  start,
  end,
  free-side: 1,
  hatch: true,
  label: none,
  label-offset: (0, 0.3),
  label-anchor: "center",
) = {
  assert(start != end, message: "A surface must have non-zero length")
  assert(free-side == 1 or free-side == -1,
    message: "Surface free-side must be 1 or -1")
  (
    kind: "surface",
    id: id(object-id),
    start: start,
    end: end,
    free-side: free-side,
    hatch: hatch,
    label: label,
    label-offset: label-offset,
    label-anchor: label-anchor,
  )
}

/// Construct a horizontal floor.
#let floor(
  object-id,
  y: 0,
  from: 0,
  to: 6,
  label: none,
  label-offset: (0, 0.3),
) = surface(
  object-id,
  (from, y),
  (to, y),
  free-side: 1,
  label: label,
  label-offset: label-offset,
)

/// Construct a horizontal ceiling.
#let ceiling(
  object-id,
  y: 5,
  from: 0,
  to: 6,
  label: none,
  label-offset: (0, -0.3),
) = surface(
  object-id,
  (from, y),
  (to, y),
  free-side: -1,
  label: label,
  label-offset: label-offset,
)

/// Construct a vertical wall.
#let wall(
  object-id,
  x: 0,
  from: 0,
  to: 5,
  free-side: 1,
  label: none,
  label-offset: (0.3, 0),
) = surface(
  object-id,
  (x, from),
  (x, to),
  free-side: free-side,
  label: label,
  label-offset: label-offset,
)

/// Construct a triangular inclined plane whose surface starts at `origin`.
#let inclined-plane(
  object-id,
  origin: (0, 0),
  length: 5,
  angle: 30deg,
  label: none,
  label-offset: (0, 0.3),
  label-anchor: "center",
) = {
  assert(length > 0, message: "Inclined-plane length must be positive")
  let end = polar(origin, length, angle)
  (
    kind: "inclined-plane",
    id: id(object-id),
    start: origin,
    end: end,
    // The base terminates vertically below the end of the hypotenuse,
    // ensuring a right triangle for the standard inclined-plane object.
    base-end: (end.at(0), origin.at(1)),
    length: length,
    angle: angle,
    free-side: 1,
    label: label,
    label-offset: label-offset,
    label-anchor: label-anchor,
  )
}
