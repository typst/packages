#import "vectors.typ": add, sub, scale, dot, normalize, perpendicular

/// Construct an orthonormal 2D coordinate frame.
#let frame(origin: (0, 0), x-axis: (1, 0), y-axis: none) = {
  let ex = normalize(x-axis)
  let ey = if y-axis == none { perpendicular(ex) } else { normalize(y-axis) }
  assert(calc.abs(dot(ex, ey)) < 0.000001,
    message: "Frame axes must be perpendicular")
  (origin: origin, x-axis: ex, y-axis: ey)
}

/// Convert a local coordinate into the global frame.
#let local-to-world(reference, point) = add(
  reference.origin,
  add(
    scale(reference.x-axis, point.at(0)),
    scale(reference.y-axis, point.at(1)),
  ),
)

/// Convert a global coordinate into a local frame.
#let world-to-local(reference, point) = {
  let relative = sub(point, reference.origin)
  (dot(relative, reference.x-axis), dot(relative, reference.y-axis))
}

/// Frame whose x axis follows a finite surface.
#let surface-frame(surface) = frame(
  origin: surface.start,
  x-axis: sub(surface.end, surface.start),
  y-axis: scale(perpendicular(normalize(sub(surface.end, surface.start))), surface.free-side),
)
