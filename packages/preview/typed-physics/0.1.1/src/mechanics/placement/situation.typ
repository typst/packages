// Assembly of validated declarations into one placed scene.

#import "../../shared/vector.typ"
#import "../../shared/expression.typ"
#import "../validation/lib.typ" as validation
#import "quantities.typ" as quantities
#import "anchors.typ" as anchors
#import "surfaces.typ" as surfaces
#import "bodies.typ" as bodies
#import "structures.typ" as structures
#import "connectors.typ" as connectors

#let gravity-quantity = quantities.gravity-quantity
#let resolve-attachment-point = anchors.resolve-attachment-point
#let _resolve-surface-geometry = surfaces.resolve-surface-geometry
#let _horizontal-surface-span = surfaces.horizontal-surface-span
#let _resolve-body-placement = bodies.resolve-body-placement
#let _resolve-structure-geometry = structures.resolve-structure-geometry
#let _point-on-rod = structures.point-on-rod
#let _resolve-torque-geometry = structures.resolve-torque-geometry
#let _resolve-connector-geometry = connectors.resolve-connector-geometry

// Which declared elements reach each body. A connector, a rigid structure, a
// neighbouring body, or an applied torque all put something on a body that the
// body's own declaration does not mention, and a later stage cannot see that in
// the geometry alone because placement resolves every reference to a point.
//
// Loads, velocities, and angular velocities are deliberately absent: they state
// a quantity rather than introducing one, so they never join a body to
// anything else.
#let _elements-reaching-bodies(declarations, body-names) = {
  let reaching-elements = (:)
  for body-name in body-names { reaching-elements.insert(body-name, ()) }
  for declaration in declarations {
    let declaration-kind = declaration.kind
    let references = if declaration-kind in ("rope", "spring", "rod") {
      (declaration.from, declaration.to)
    } else if declaration-kind in ("pivot", "support") {
      (declaration.at,)
    } else if declaration-kind == "pendulum" {
      (declaration.from,)
    } else if declaration-kind == "torque" {
      (declaration.on,)
    } else if declaration-kind == "body" {
      (declaration.touching, declaration.hanging)
    } else {
      ()
    }
    let declared-name = if "name" in declaration { declaration.name } else {
      none
    }
    // A connector spans two attachments, and which one is at its far end
    // decides whether the force it carries is shared. A connector that runs
    // over a pulley reaches whatever is on the other side of the wheel, so the
    // pulley is the far end that matters.
    let connector-endpoints = if declaration-kind in ("rope", "spring") {
      if "over" in declaration and declaration.over != none {
        (declaration.over, declaration.over)
      } else {
        (
          anchors.attachment-element-name(declaration.to),
          anchors.attachment-element-name(declaration.from),
        )
      }
    } else { none }
    for (reference-index, reference) in references.enumerate() {
      if reference == none { continue }
      let referenced-name = anchors.attachment-element-name(reference)
      if referenced-name == none { continue }
      if referenced-name not in reaching-elements { continue }
      if referenced-name == declared-name { continue }
      reaching-elements.at(referenced-name).push((
        kind: declaration-kind,
        name: declared-name,
        far-end: if connector-endpoints == none { none } else {
          connector-endpoints.at(reference-index)
        },
      ))
    }
  }
  reaching-elements
}

#let resolve-situation-geometry(declarations, gravity: 9.81) = {
  validation.validate-situation-declarations(declarations, gravity)
  let declared-element-names = ()
  for declaration in declarations {
    assert(
      type(declaration) == dictionary and "kind" in declaration,
      message: "typed-physics: situation() takes elements such as ramp(...), block(...) or force(...)",
    )
    if "name" in declaration {
      assert(
        declaration.name not in declared-element-names,
        message: "typed-physics: \"" + declaration.name + "\" is declared twice; every element needs its own name",
      )
      declared-element-names.push(declaration.name)
    }
  }

  let declarations-of-kind(..kinds) = declarations.filter(
    declaration => declaration.kind in kinds.pos(),
  )
  let surface-declarations = declarations-of-kind(
    "ground",
    "wall",
    "ceiling",
    "ramp",
    "arc",
  )
  let body-declarations = declarations-of-kind("body")
  let pulley-declarations = declarations-of-kind("pulley")
  let structure-declarations = declarations-of-kind(
    "rod",
    "pivot",
    "support",
    "pendulum",
  )
  let torque-declarations = declarations-of-kind("torque")
  let connector-declarations = declarations-of-kind("rope", "spring")
  let applied-load-declarations = declarations-of-kind("force")
  let velocity-declarations = declarations-of-kind("velocity")
  let angular-velocity-declarations = declarations-of-kind("angular-velocity")

  let ramp-count = surface-declarations.filter(
    declaration => declaration.kind == "ramp",
  ).len()

  // Walls stand at the edges of everything else, so every other surface is
  // placed first and the span they bound is measured from the result.
  let placed-surfaces = (:)
  let spanning-surface-names = ()
  for surface-declaration in surface-declarations.filter(
    declaration => declaration.kind != "wall",
  ) {
    placed-surfaces.insert(
      surface-declaration.name,
      _resolve-surface-geometry(
        surface-declaration,
        (0, 0),
        ramp-count,
        placed-surfaces,
      ),
    )
    spanning-surface-names.push(surface-declaration.name)
  }
  let horizontal-span = _horizontal-surface-span(
    placed-surfaces,
    spanning-surface-names,
  )
  for surface-declaration in surface-declarations.filter(
    declaration => declaration.kind == "wall",
  ) {
    placed-surfaces.insert(
      surface-declaration.name,
      _resolve-surface-geometry(
        surface-declaration,
        horizontal-span,
        ramp-count,
        placed-surfaces,
      ),
    )
  }

  let placed-pulleys = (:)
  for pulley-declaration in pulley-declarations {
    placed-pulleys.insert(
      pulley-declaration.name,
      (
        name: pulley-declaration.name,
        kind: "pulley",
        center: resolve-attachment-point(
          pulley-declaration.at,
          placed-surfaces,
          (:),
          placed-pulleys,
          "pulley \"" + pulley-declaration.name + "\"",
        ),
        radius: pulley-declaration.radius,
        style: pulley-declaration.style,
      ),
    )
  }

  let placed-bodies = (:)
  for body-declaration in body-declarations {
    placed-bodies.insert(
      body-declaration.name,
      _resolve-body-placement(
        body-declaration,
        placed-surfaces,
        placed-bodies,
        placed-pulleys,
      ),
    )
  }
  for (body-index, body-name) in body-declarations.map(
    declaration => declaration.name,
  ).enumerate() {
    let placed-body = placed-bodies.at(body-name)
    if placed-body.support == none or placed-body.distance == none { continue }
    for other-body-name in body-declarations.slice(body-index + 1).map(
      declaration => declaration.name,
    ) {
      let other-body = placed-bodies.at(other-body-name)
      if (
        other-body.support == placed-body.support
          and other-body.distance != none
      ) {
        let center-separation = calc.abs(
          other-body.distance - placed-body.distance,
        )
        let required-separation = (
          placed-body.half-extent-along + other-body.half-extent-along
        )
        assert(
          center-separation + 0.000001 >= required-separation,
          message: (
            "typed-physics: bodies \""
              + placed-body.name
              + "\" and \""
              + other-body.name
              + "\" overlap on surface \""
              + placed-body.support
              + "\"; move one with `at:`/`side:` or reduce its size"
          ),
        )
      }
    }
  }

  let placed-structures = (:)
  for structure-declaration in structure-declarations {
    placed-structures.insert(
      structure-declaration.name,
      _resolve-structure-geometry(
        structure-declaration,
        placed-surfaces,
        placed-bodies,
        placed-pulleys,
        placed-structures,
      ),
    )
  }

  let placed-torques = torque-declarations.map(
    torque-declaration => _resolve-torque-geometry(
      torque-declaration,
      placed-surfaces,
      placed-bodies,
      placed-pulleys,
      placed-structures,
    ),
  )

  let placed-connectors = ()
  for connector-declaration in connector-declarations {
    placed-connectors.push(
      _resolve-connector-geometry(
        connector-declaration,
        placed-surfaces,
        placed-bodies,
        placed-pulleys,
        placed-structures: placed-structures,
      ),
    )
  }

  for applied-load-declaration in applied-load-declarations {
    let loaded-element-name = applied-load-declaration.on
    if loaded-element-name in placed-bodies {
      let loaded-body = placed-bodies.at(loaded-element-name)
      loaded-body.loads.push((
        magnitude: expression.declared(applied-load-declaration.magnitude, $F$),
        inclination: applied-load-declaration.angle,
        direction: vector.direction-from-angle(applied-load-declaration.angle),
        label: applied-load-declaration.label,
        style: applied-load-declaration.style,
      ))
      placed-bodies.at(loaded-element-name) = loaded-body
    } else {
      assert(
        loaded-element-name in placed-structures
          and placed-structures.at(loaded-element-name).kind == "rod",
        message: "typed-physics: force() acts on \"" + loaded-element-name + "\", which is not a body or rod in this situation",
      )
      let loaded-rod = placed-structures.at(loaded-element-name)
      let application-position = if applied-load-declaration.at == auto {
        loaded-rod.center
      } else if type(applied-load-declaration.at) == ratio {
        _point-on-rod(loaded-rod, applied-load-declaration.at)
      } else {
        resolve-attachment-point(
          applied-load-declaration.at,
          placed-surfaces,
          placed-bodies,
          placed-pulleys,
          "force() on \"" + loaded-element-name + "\"",
          placed-structures: placed-structures,
        )
      }
      loaded-rod.loads.push((
        magnitude: expression.declared(applied-load-declaration.magnitude, $F$),
        inclination: applied-load-declaration.angle,
        direction: vector.direction-from-angle(applied-load-declaration.angle),
        application-position: application-position,
        label: applied-load-declaration.label,
        style: applied-load-declaration.style,
      ))
      placed-structures.at(loaded-element-name) = loaded-rod
    }
  }

  for velocity-declaration in velocity-declarations {
    assert(
      velocity-declaration.on in placed-bodies,
      message: "typed-physics: velocity() belongs to \"" + velocity-declaration.on + "\", which is not a body in this situation",
    )
    let moving-body = placed-bodies.at(velocity-declaration.on)
    moving-body.velocities.push((
      magnitude: expression.declared(velocity-declaration.magnitude, $v$),
      direction: vector.direction-from-angle(velocity-declaration.angle),
      label: velocity-declaration.label,
      style: velocity-declaration.style,
    ))
    placed-bodies.at(velocity-declaration.on) = moving-body
  }

  for angular-velocity-declaration in angular-velocity-declarations {
    let body-name = angular-velocity-declaration.on
    assert(
      body-name in placed-bodies,
      message: "typed-physics: angular-velocity() belongs to \"" + body-name + "\", which is not a body in this situation",
    )
    let rotating-body = placed-bodies.at(body-name)
    assert(
      rotating-body.shape in ("ball", "disk", "ring"),
      message: "typed-physics: angular-velocity() needs a ball, disk, or ring; \"" + body-name + "\" is a " + rotating-body.shape,
    )
    let turns-clockwise = (
      angular-velocity-declaration.direction == "clockwise"
    )
    let start-angle = if angular-velocity-declaration.start-angle == auto {
      if turns-clockwise { 220deg } else { 140deg }
    } else {
      angular-velocity-declaration.start-angle
    }
    let raw-end-angle = if angular-velocity-declaration.end-angle == auto {
      if turns-clockwise { 140deg } else { 220deg }
    } else {
      angular-velocity-declaration.end-angle
    }
    let directed-end-angle = if turns-clockwise and raw-end-angle >= start-angle {
      raw-end-angle - 360deg
    } else if not turns-clockwise and raw-end-angle <= start-angle {
      raw-end-angle + 360deg
    } else {
      raw-end-angle
    }
    let arrow-radius = if angular-velocity-declaration.radius == auto {
      rotating-body.half-extent-along + 0.28
    } else {
      angular-velocity-declaration.radius
    }
    assert(
      arrow-radius > rotating-body.half-extent-along,
      message: "typed-physics: angular-velocity() radius: must place the arrow outside \"" + body-name + "\"",
    )
    rotating-body.angular-velocities.push((
      magnitude: angular-velocity-declaration.magnitude,
      direction: angular-velocity-declaration.direction,
      radius: arrow-radius,
      start-angle: start-angle,
      end-angle: directed-end-angle,
      label: angular-velocity-declaration.label,
      style: angular-velocity-declaration.style,
    ))
    placed-bodies.at(body-name) = rotating-body
  }

  let elements-reaching-bodies = _elements-reaching-bodies(
    declarations,
    placed-bodies.keys(),
  )
  for (body-name, reaching-elements) in elements-reaching-bodies {
    placed-bodies.at(body-name).reached-by = reaching-elements
  }

  (
    gravity: gravity-quantity(gravity),
    surfaces: placed-surfaces,
    bodies: placed-bodies,
    pulleys: placed-pulleys,
    structures: placed-structures,
    torques: placed-torques,
    connectors: placed-connectors,
    surface-order: surface-declarations.map(declaration => declaration.name),
    body-order: body-declarations.map(declaration => declaration.name),
    structure-order: structure-declarations.map(
      declaration => declaration.name,
    ),
    span: horizontal-span,
  )
}
