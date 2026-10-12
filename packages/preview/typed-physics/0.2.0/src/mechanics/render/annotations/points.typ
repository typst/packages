// Where an annotation attaches, and which way an element it names points.
//
// An annotation resolves against a finished scene rather than against a partly
// placed one, so it reaches every element including the connectors, and a raw
// (x, y) point is allowed here because an annotation may name a place the
// situation never gave a name to.

#import "../../../shared/vector.typ"
#import "../../placement/lib.typ" as placement

#let _is-raw-coordinate(endpoint-reference) = (
  type(endpoint-reference) == array
    and endpoint-reference.len() == 2
    and endpoint-reference.all(coordinate => type(coordinate) in (int, float))
)

#let annotation-point(scene, endpoint-reference, declared-by) = {
  if _is-raw-coordinate(endpoint-reference) { return endpoint-reference }
  placement.resolve-attachment-point(
    endpoint-reference,
    scene.surfaces,
    scene.bodies,
    scene.pulleys,
    declared-by,
    placed-structures: scene.structures,
    placed-connectors: scene.connectors,
  )
}

// The direction an element points along, together with the line it lies on so
// two of them can be intersected. A body reports the frame it was placed in,
// which is what makes an inclined block's own axes available to an annotation.
#let annotation-direction(scene, direction-reference, declared-by) = {
  if type(direction-reference) == std.angle {
    return (
      direction: vector.direction-from-angle(direction-reference),
      line: none,
      described-as: repr(direction-reference),
    )
  }
  let element-name = if type(direction-reference) == dictionary {
    direction-reference.on
  } else {
    direction-reference
  }
  let is-reversed = (
    type(direction-reference) == dictionary
      and direction-reference.at("reversed", default: false)
  )

  let element-line = if element-name in scene.surfaces {
    let surface = scene.surfaces.at(element-name)
    assert(
      surface.kind != "arc",
      message: (
        "typed-physics: "
          + declared-by
          + " names curved surface \""
          + element-name
          + "\", which has no single direction; give the angle instead"
      ),
    )
    (origin: surface.start, direction: surface.direction)
  } else if element-name in scene.bodies {
    let body = scene.bodies.at(element-name)
    (origin: body.center, direction: body.direction)
  } else if element-name in scene.structures {
    let placed-structure = scene.structures.at(element-name)
    assert(
      placed-structure.kind in ("rod", "pendulum"),
      message: (
        "typed-physics: "
          + declared-by
          + " names \""
          + element-name
          + "\", which has no direction; name a surface, body, rod, pendulum, or connector"
      ),
    )
    if placed-structure.kind == "rod" {
      (origin: placed-structure.start, direction: placed-structure.direction)
    } else {
      (
        origin: placed-structure.pivot,
        direction: vector.normalized(
          vector.subtract(placed-structure.bob, placed-structure.pivot),
        ),
      )
    }
  } else {
    let placed-connector = scene.connectors.find(
      connector => connector.name == element-name,
    )
    assert(
      placed-connector != none,
      message: (
        "typed-physics: "
          + declared-by
          + " names \""
          + element-name
          + "\", which is not an element of this situation"
      ),
    )
    (
      origin: placed-connector.start,
      direction: vector.normalized(
        vector.subtract(placed-connector.end, placed-connector.start),
      ),
    )
  }

  (
    direction: if is-reversed {
      vector.reversed(element-line.direction)
    } else {
      element-line.direction
    },
    line: element-line,
    described-as: "\"" + element-name + "\"",
  )
}

// Where two element lines cross, which is the corner an angle between them is
// measured at.
#let lines-intersection(first-line, second-line, declared-by) = {
  let direction-cross = vector.cross-product(
    first-line.direction,
    second-line.direction,
  )
  assert(
    calc.abs(direction-cross) > 0.000001,
    message: (
      "typed-physics: "
        + declared-by
        + " measures between two parallel directions, which never meet; give `at:` the point to mark"
    ),
  )
  let origin-separation = vector.subtract(
    second-line.origin,
    first-line.origin,
  )
  vector.point-along(
    first-line.origin,
    first-line.direction,
    vector.cross-product(origin-separation, second-line.direction)
      / direction-cross,
  )
}
