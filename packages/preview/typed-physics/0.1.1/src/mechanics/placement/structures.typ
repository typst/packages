// Placement of rods, supports, pivots, pendulums, and torques.

#import "../../shared/vector.typ"
#import "anchors.typ" as anchors
#import "bodies.typ" as bodies

#let resolve-attachment-point = anchors.resolve-attachment-point
#let _split-anchor-reference = anchors.split-anchor-reference
#let _declared-mass = bodies.declared-mass

#let _support-contact-on-attached-rod(
  support-declaration,
  attachment-position,
  placed-structures,
) = {
  if support-declaration.support-kind == "fixed" {
    return attachment-position
  }
  let attached-element-name = if type(support-declaration.at) == dictionary {
    support-declaration.at.at("on")
  } else {
    _split-anchor-reference(support-declaration.at).element
  }
  if attached-element-name not in placed-structures {
    return attachment-position
  }
  let attached-structure = placed-structures.at(attached-element-name)
  if attached-structure.kind != "rod" {
    return attachment-position
  }

  let support-tangent-direction = vector.direction-from-angle(
    support-declaration.angle,
  )
  let support-normal-direction = vector.left-normal(
    support-tangent-direction,
  )
  let rod-normal-alignment = calc.abs(
    vector.dot-product(
      support-normal-direction,
      attached-structure.outward-normal,
    ),
  )
  if rod-normal-alignment < 0.001 {
    return attachment-position
  }

  // Rod anchors lie on the centreline, while a pin or roller physically meets
  // the lower face of the rod.
  let distance-from-centerline-to-contact = (
    attached-structure.thickness / (2 * rod-normal-alignment)
  )
  vector.point-along(
    attachment-position,
    vector.reversed(support-normal-direction),
    distance-from-centerline-to-contact,
  )
}

#let resolve-structure-geometry(
  structure-declaration,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
  placed-structures,
) = {
  let declared-by = (
    structure-declaration.kind
      + " \""
      + structure-declaration.name
      + "\""
  )
  let resolve-point(attachment) = resolve-attachment-point(
    attachment,
    placed-surfaces,
    placed-bodies,
    placed-pulleys,
    declared-by,
    placed-structures: placed-structures,
  )

  if structure-declaration.kind == "rod" {
    let start-position = if structure-declaration.from == none {
      (0, 0)
    } else {
      resolve-point(structure-declaration.from)
    }
    let end-position = if structure-declaration.to == none {
      vector.point-along(
        start-position,
        vector.direction-from-angle(structure-declaration.angle),
        structure-declaration.length,
      )
    } else {
      resolve-point(structure-declaration.to)
    }
    let rod-span = vector.subtract(end-position, start-position)
    let rod-length = vector.magnitude(rod-span)
    assert(
      rod-length > 0,
      message: "typed-physics: rod \"" + structure-declaration.name + "\" has coincident endpoints",
    )
    let rod-direction = vector.normalized(rod-span)
    return (
      name: structure-declaration.name,
      kind: "rod",
      start: start-position,
      end: end-position,
      center: vector.midpoint(start-position, end-position),
      center-of-mass: vector.point-along(
        start-position,
        rod-direction,
        rod-length * (structure-declaration.center-of-mass / 100%),
      ),
      direction: rod-direction,
      outward-normal: vector.left-normal(rod-direction),
      length: rod-length,
      thickness: structure-declaration.thickness,
      mass: _declared-mass(structure-declaration),
      label: structure-declaration.label,
      style: structure-declaration.style,
      loads: (),
    )
  }

  if structure-declaration.kind == "pendulum" {
    let pivot-position = resolve-point(structure-declaration.from)
    let string-direction = vector.direction-from-angle(
      -90deg + structure-declaration.angle,
    )
    return (
      name: structure-declaration.name,
      kind: "pendulum",
      center: vector.point-along(
        pivot-position,
        string-direction,
        structure-declaration.length,
      ),
      pivot: pivot-position,
      bob: vector.point-along(
        pivot-position,
        string-direction,
        structure-declaration.length,
      ),
      direction: string-direction,
      length: structure-declaration.length,
      angle: structure-declaration.angle,
      angle-label: structure-declaration.angle-label,
      radius: structure-declaration.radius,
      mass: _declared-mass(structure-declaration),
      label: structure-declaration.label,
      style: structure-declaration.style,
    )
  }

  let attachment-position = resolve-point(structure-declaration.at)
  let support-contact-position = if structure-declaration.kind == "support" {
    _support-contact-on-attached-rod(
      structure-declaration,
      attachment-position,
      placed-structures,
    )
  } else {
    attachment-position
  }
  (
    name: structure-declaration.name,
    kind: structure-declaration.kind,
    center: attachment-position,
    contact: support-contact-position,
    radius: structure-declaration.at("radius", default: none),
    support-kind: structure-declaration.at("support-kind", default: none),
    angle: structure-declaration.at("angle", default: 0deg),
    size: structure-declaration.at("size", default: none),
    style: structure-declaration.style,
  )
}

#let point-on-rod(placed-rod, at) = if type(at) == ratio {
  vector.point-along(
    placed-rod.start,
    placed-rod.direction,
    placed-rod.length * (at / 100%),
  )
} else {
  none
}

#let resolve-torque-geometry(
  torque-declaration,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
  placed-structures,
) = {
  let target-name = torque-declaration.on
  let target-is-body = target-name in placed-bodies
  let target-is-structure = target-name in placed-structures
  assert(
    target-is-body or target-is-structure,
    message: "typed-physics: torque() turns \"" + target-name + "\", which is not a body or rigid structure in this situation",
  )
  let target = if target-is-body {
    placed-bodies.at(target-name)
  } else {
    placed-structures.at(target-name)
  }
  let torque-center = if torque-declaration.at == auto {
    target.center
  } else if target.kind == "rod" and type(torque-declaration.at) == ratio {
    point-on-rod(target, torque-declaration.at)
  } else {
    resolve-attachment-point(
      torque-declaration.at,
      placed-surfaces,
      placed-bodies,
      placed-pulleys,
      "torque() on \"" + target-name + "\"",
      placed-structures: placed-structures,
    )
  }
  (
    kind: "torque",
    on: target-name,
    center: torque-center,
    magnitude: torque-declaration.magnitude,
    direction: torque-declaration.direction,
    radius: torque-declaration.radius,
    label: torque-declaration.label,
    style: torque-declaration.style,
  )
}

// ── Connectors ───────────────────────────────────────────────────────────────

// The two points at which a rope leaves a pulley it runs over. Each is the
// tangent point from that end of the rope, so the rope meets the wheel where a
// real one would rather than pointing at its centre.
