// Placing labels clear of what is drawn around them.
//
// A label is drawn at a preferred point and moves only when something would
// cross it: a rope, a force arrow, the line to a neighbouring body, a surface,
// or the rim of a pulley. The candidates keep the preferred point first, so a
// body with nothing around it is labelled exactly where it always was.
//
// Obstacles are rays that leave a point, segments of a known length, circles,
// and boxes. A label is treated as a box, which is coarse but enough to tell a
// label that a line runs through from one that clears it.

#import "../../shared/vector.typ"
#import "geometry.typ" as geometry
#import "../forces.typ" as force-enumeration

// How far a ray from a body's centre reaches. Ropes, force arrows, and the lines
// to neighbours all leave a body within this distance of its centre.
#let ray-reach = 2.0

// Spacing of the samples taken along a segment when testing it against a box.
#let _sampling-step = 0.05

// Room kept between a label box and the rim of a pulley.
#let _rim-gap = 0.12

// Half the width and height of a label box, in world units. A mass label is a
// short "m = 4 kg" line, measured at the diagram's default scale; a force symbol
// is a single letter.
#let mass-label-half-size = (0.75, 0.22)
#let force-label-half-size = (0.14, 0.14)

// Gap kept between a mass label and the outline of its own body or of a
// neighbouring one.
#let _beside-label-gap = 0.3

// Directions a mass label may sit in, as angles measured from the x axis. The
// preferred top comes first; the others are ordered by how far they lie from it,
// so an unobstructed choice stays close to the top.
#let _beside-label-angles = (
  67.5deg, 112.5deg, 45deg, 135deg, 22.5deg, 157.5deg, 0deg, 180deg,
  -22.5deg, 202.5deg, -45deg, 225deg, -67.5deg, 247.5deg, -90deg,
)

#let _box-contains(box-center, half-size, point) = (
  calc.abs(point.at(0) - box-center.at(0)) <= half-size.at(0)
    and calc.abs(point.at(1) - box-center.at(1)) <= half-size.at(1)
)

// Whether a segment leaving `start` along `direction` passes through a box.
#let _segment-crosses-box(start, direction, length, box-center, half-size) = {
  let sample-count = calc.max(1, calc.ceil(length / _sampling-step))
  range(0, sample-count + 1).any(sample-index => _box-contains(
    box-center,
    half-size,
    vector.point-along(start, direction, length * sample-index / sample-count),
  ))
}

// Whether a circle comes within the rim gap of a box.
#let _circle-reaches-box(circle-center, radius, box-center, half-size) = {
  let nearest-point = (
    calc.clamp(
      circle-center.at(0),
      box-center.at(0) - half-size.at(0),
      box-center.at(0) + half-size.at(0),
    ),
    calc.clamp(
      circle-center.at(1),
      box-center.at(1) - half-size.at(1),
      box-center.at(1) + half-size.at(1),
    ),
  )
  vector.magnitude(vector.subtract(nearest-point, circle-center)) < radius + _rim-gap
}

#let _boxes-overlap(first-center, first-size, second-center, second-size) = (
  calc.abs(first-center.at(0) - second-center.at(0))
      < first-size.at(0) + second-size.at(0)
    and calc.abs(first-center.at(1) - second-center.at(1))
      < first-size.at(1) + second-size.at(1)
)

// How many obstacles a label box would sit on. The obstacles are a list of
// `segments` (start, direction, length), `circles` (center, radius), and
// `boxes` (center, half-size), so a caller can add any of the three.
#let _collision-count(box-center, half-size, obstacles) = {
  let crossed-segments = obstacles.segments.filter(segment => (
    _segment-crosses-box(
      segment.start,
      segment.direction,
      segment.length,
      box-center,
      half-size,
    )
  )).len()
  let reached-circles = obstacles.circles.filter(circle => (
    _circle-reaches-box(circle.center, circle.radius, box-center, half-size)
  )).len()
  let overlapped-boxes = obstacles.boxes.filter(box => (
    _boxes-overlap(box-center, half-size, box.center, box.half-size)
  )).len()
  crossed-segments + reached-circles + overlapped-boxes
}

#let no-obstacles = (segments: (), circles: (), boxes: ())

// The first candidate point that collides with the fewest obstacles. Candidates
// are ordered by preference, so ties keep the earlier one.
#let choose-label-point(candidate-points, half-size, obstacles) = {
  let collision-counts = candidate-points.map(candidate-point => (
    _collision-count(candidate-point, half-size, obstacles)
  ))
  let fewest-collisions = calc.min(..collision-counts)
  candidate-points.at(collision-counts.position(count => count == fewest-collisions))
}

// The straight pieces of every rope and spring in the scene. A rope over a
// pulley is two pieces, one on each side of the wheel; the arc in between is
// bounded by the pulley's rim, which is already an obstacle.
#let connector-segments(scene) = {
  let segments = ()
  for connector in scene.connectors {
    let pieces = if connector.over != none {
      (
        (connector.start, connector.start-tangent),
        (connector.end-tangent, connector.end),
      )
    } else {
      ((connector.start, connector.end),)
    }
    for (piece-start, piece-end) in pieces {
      let piece-length = vector.magnitude(vector.subtract(piece-end, piece-start))
      if piece-length > 1e-9 {
        segments.push((
          start: piece-start,
          direction: vector.normalized(vector.subtract(piece-end, piece-start)),
          length: piece-length,
        ))
      }
    }
  }
  segments
}

// The line from a body's centre to the point it hangs from, for a body with no
// rope between itself and that point.
#let hanging-attachment-segments(body) = if body.hangs-from == none { () } else {
  ((
    start: body.center,
    direction: vector.normalized(vector.subtract(body.hangs-from, body.center)),
    length: ray-reach,
  ),)
}

// Every straight line of every surface in the scene, which no label may sit on.
// A ramp is drawn as a triangle on the ground, so its base and its vertical edge
// count as well as its slope. A curved surface has no straight line to test.
#let _segment-between(start, end) = (
  start: start,
  direction: vector.normalized(vector.subtract(end, start)),
  length: vector.magnitude(vector.subtract(end, start)),
)

#let surface-segments(scene) = scene.surface-order.map(surface-name => {
  let surface = scene.surfaces.at(surface-name)
  if surface.kind == "arc" {
    ()
  } else if surface.kind == "ramp" {
    (
      (
        start: surface.start,
        direction: surface.direction,
        length: surface.length,
      ),
      _segment-between(surface.foot, surface.base-corner),
      _segment-between(surface.base-corner, surface.apex),
    )
  } else {
    ((
      start: surface.start,
      direction: surface.direction,
      length: surface.length,
    ),)
  }
}).flatten().filter(segment => segment.length > 1e-9)

// Pulley rims, which every label keeps clear of.
#let pulley-circles(scene) = scene.pulleys.values().map(pulley => (
  center: pulley.center,
  radius: pulley.radius,
))

// Half the width and height of a body's footprint on world axes, which is what
// a label beside it has to clear.
#let world-half-extents(body) = if body.shape == "block" {
  let corners = geometry.body-corners(body)
  (
    calc.max(..corners.map(corner => calc.abs(corner.at(0) - body.center.at(0)))),
    calc.max(..corners.map(corner => calc.abs(corner.at(1) - body.center.at(1)))),
  )
} else {
  (body.half-extent-along, body.half-extent-normal)
}

// Every body's footprint as a box, except the one named when it is given. A
// label may not overlap any of them.
#let body-boxes(scene, excluded-body-name) = scene.body-order.filter(
  body-name => body-name != excluded-body-name,
).map(body-name => {
  let other-body = scene.bodies.at(body-name)
  (center: other-body.center, half-size: world-half-extents(other-body))
})

// The obstacles a body's mass label must avoid: the force arrows drawn on it,
// every rope and surface in the scene, the pulley rims, and the other bodies.
#let body-label-obstacles(scene, body, drawn-directions) = {
  let arrow-segments = drawn-directions.map(direction => (
    start: body.center,
    direction: direction,
    length: ray-reach,
  ))
  (
    segments: arrow-segments
      + hanging-attachment-segments(body)
      + connector-segments(scene)
      + surface-segments(scene),
    circles: pulley-circles(scene),
    boxes: body-boxes(scene, body.name),
  )
}

// The point a label sits at in a direction from the body's centre. It is at
// least the body's own outline away, and far enough that the label box clears
// the body's footprint on whichever axis the direction leans toward.
#let _beside-label-point(body, direction) = {
  let body-half-size = world-half-extents(body)
  let clear-distances = (
    (
      mass-label-half-size.at(0) + body-half-size.at(0) + _beside-label-gap,
      direction.at(0),
    ),
    (
      mass-label-half-size.at(1) + body-half-size.at(1) + _beside-label-gap,
      direction.at(1),
    ),
  ).filter(((required-separation, component)) => calc.abs(component) > 1e-9).map(
    ((required-separation, component)) => required-separation / calc.abs(component),
  )
  let distance = calc.max(
    geometry.body-boundary-distance(body, direction) + _beside-label-gap,
    calc.min(..clear-distances),
  )
  vector.point-along(body.center, direction, distance)
}

// Where a body's mass label can sit. The preferred place is above the body, as
// it always was; the other sides follow in `_beside-label-angles` order.
#let mass-label-candidates(body) = {
  let preferred-point = (
    body.center.at(0),
    geometry.body-top-height(body) + 0.3,
  )
  (preferred-point,) + _beside-label-angles.map(angle => _beside-label-point(
    body,
    vector.direction-from-angle(angle),
  ))
}

// Where a force's symbol sits beside its arrow. The preferred place is just past
// the tip along the arrow; the rest step to either side of the tip, then to the
// side of the shaft, and then further along. A shaft is what keeps a symbol clear
// of a surface an arrow ends on.
#let force-label-candidates(tip-position, direction) = {
  let side = (-direction.at(1), direction.at(0))
  let past-tip = vector.point-along(tip-position, direction, 0.28)
  let shaft-point = vector.point-along(tip-position, direction, -0.55)
  (
    past-tip,
    vector.point-along(past-tip, side, 0.42),
    vector.point-along(past-tip, side, -0.42),
    vector.point-along(shaft-point, side, 0.42),
    vector.point-along(shaft-point, side, -0.42),
    vector.point-along(tip-position, direction, 0.55),
    vector.point-along(past-tip, side, 0.84),
    vector.point-along(past-tip, side, -0.84),
  )
}

// The centre of a body's mass label, chosen against what is drawn near it.
#let mass-label-point(scene, body, drawn-directions) = choose-label-point(
  mass-label-candidates(body),
  mass-label-half-size,
  body-label-obstacles(scene, body, drawn-directions),
)
