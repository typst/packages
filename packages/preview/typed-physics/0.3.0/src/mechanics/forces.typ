// Enumerating the forces on a body.
//
// A declaration already says everything needed to know which forces act: a
// body with a mass has a weight, a body resting on a surface has a normal
// force, a rough contact has friction, and the problem statement's own loads
// are named where they were declared. Nothing here is drawn — a free-body
// diagram is the enumeration rendered, which is why it cannot disagree with
// the scene it came from.

#import "../shared/vector.typ"
#import "../shared/expression.typ"

// The component of a load along and out of the surface its body rests on.
//
// The angle is measured in the surface's own frame rather than against the
// horizontal, so one pair of expressions covers a slope that climbs either way,
// a wall, and a ceiling. A load that lies on one of the surface's own axes
// contributes exactly, not through a cosine of zero, so a horizontal push on
// level ground stays `F`.
#let resolve-load-components-in-surface-frame(applied-load, body) = {
  let tangent-projection = vector.dot-product(
    applied-load.direction,
    body.direction,
  )
  let outward-normal-projection = vector.dot-product(
    applied-load.direction,
    body.outward-normal,
  )
  let load-is-axis-aligned = (
    calc.abs(tangent-projection) < 1e-9
      or calc.abs(outward-normal-projection) < 1e-9
  )
  if load-is-axis-aligned {
    return (
      along: expression.product(
        applied-load.magnitude,
        expression.number(calc.round(tangent-projection, digits: 6)),
      ),
      normal: expression.product(
        applied-load.magnitude,
        expression.number(calc.round(outward-normal-projection, digits: 6)),
      ),
    )
  }
  let relative-angle-quantity = expression.declared-angle(
    calc.atan2(tangent-projection, outward-normal-projection),
    $phi$,
  )
  (
    along: expression.product(
      applied-load.magnitude,
      expression.cosine(relative-angle-quantity),
    ),
    normal: expression.product(
      applied-load.magnitude,
      expression.sine(relative-angle-quantity),
    ),
  )
}

// The weight resolved into the axes of the surface a body rests on.
//
// The incline family states its frame through an angle the author declared, so
// its weight keeps the `sin theta` and `cos theta` a reader expects, and level
// ground folds them away against its exact zero. Every other supported surface
// stands at a fixed attitude with no angle worth printing, and its frame is
// read from the placed axes instead — which is also the only way a ceiling,
// whose outward normal points down, reaches the right sign.
#let weight-components-in-surface-frame(
  body,
  support-surface,
  weight-force-magnitude,
) = {
  let surface-states-its-frame-as-an-angle = (
    support-surface.kind in ("ground", "ramp")
  )
  let tangent-rise = if surface-states-its-frame-as-an-angle {
    expression.sine(body.inclination-quantity)
  } else {
    expression.number(calc.round(body.direction.at(1), digits: 6))
  }
  let outward-normal-rise = if surface-states-its-frame-as-an-angle {
    expression.cosine(body.inclination-quantity)
  } else {
    expression.number(calc.round(body.outward-normal.at(1), digits: 6))
  }
  (
    along: expression.negated(
      expression.product(weight-force-magnitude, tangent-rise),
    ),
    normal: expression.negated(
      expression.product(weight-force-magnitude, outward-normal-rise),
    ),
  )
}

// The share of a body's weight that acts along its rope, positive toward the
// pulley. A hanging body's rope is vertical, so its whole weight stands along it.
// A body on a surface only feels the component down the slope, and the sign of
// its rope's direction along the surface says whether that is up or down it.
#let weight-component-toward-pulley(
  body,
  weight-force-magnitude,
  toward-pulley-direction,
) = {
  let rope-rise = if body.support == none {
    expression.number(calc.round(toward-pulley-direction.at(1), digits: 6))
  } else {
    expression.product(
      expression.number(calc.round(
        vector.dot-product(toward-pulley-direction, body.direction),
        digits: 6,
      )),
      expression.sine(body.inclination-quantity),
    )
  }
  expression.negated(expression.product(weight-force-magnitude, rope-rise))
}

#let applied-load-symbol(applied-load, load-index, applied-load-count) = {
  if applied-load.label != auto { return applied-load.label }
  if applied-load-count <= 1 { $F$ } else { $F_#(load-index + 1)$ }
}

// The unit direction a rope pulls its end in. From the attachment on the body
// it runs to the tangent point where it leaves the wheel, or to the far end when
// it runs straight between the two.
#let rope-direction-leaving(placed-rope, body-is-at-start) = {
  let attachment-position = if body-is-at-start { placed-rope.start } else { placed-rope.end }
  let next-rope-position = if placed-rope.over != none {
    if body-is-at-start { placed-rope.start-tangent } else { placed-rope.end-tangent }
  } else {
    if body-is-at-start { placed-rope.end } else { placed-rope.start }
  }
  vector.normalized(vector.subtract(next-rope-position, attachment-position))
}

#let _rope-forces-on-body(scene, body, solution) = {
  let attached-ropes = body.reached-by.filter(element => element.kind == "rope")
  attached-ropes.enumerate().map(((rope-index, attachment)) => {
    let rope = scene.connectors.find(connector => connector.name == attachment.name)
    let body-is-at-start = attachment.endpoint == "start"
    let attachment-position = if body-is-at-start { rope.start } else { rope.end }
    (
      role: "tension",
      symbol: if attached-ropes.len() == 1 { $T$ } else { $T_#(rope-index + 1)$ },
      direction: rope-direction-leaving(rope, body-is-at-start),
      magnitude: if solution == none or "tension" not in solution { none } else {
        solution.tension.expression
      },
      applied-at: attachment-position,
      style: (:),
    )
  })
}

// Without a solution, friction is oriented only by a motion the author declared,
// since friction opposes a velocity along the surface. The loads on a body do
// not decide it: a push up the slope may be smaller than the friction holding
// the body still. With no declared motion the direction is undecided, so the
// function returns none and no friction arrow is drawn.
#let _unsolved-friction-direction(body) = {
  let declared-motion-components = body.velocities.filter(velocity => {
    let speed = if velocity.magnitude == none { none } else {
      expression.value-of(velocity.magnitude)
    }
    speed == none or calc.abs(speed) > 1e-9
  }).map(velocity => vector.dot-product(velocity.direction, body.direction))
    .filter(component => calc.abs(component) > 1e-9)
  if declared-motion-components.len() == 0 { return none }
  if declared-motion-components.all(component => component > 0) {
    vector.reversed(body.direction)
  } else if declared-motion-components.all(component => component < 0) {
    body.direction
  } else {
    none
  }
}

// The forces acting on one body, in the order a reader expects to meet them.
// `solution` fills in the magnitudes and the friction direction that only
// follow from balancing the body; without one the contact forces are still
// enumerated, with their magnitudes left unknown.
#let enumerate-forces(scene, name, solution: none) = {
  let body = scene.bodies.at(name)
  let acting-forces = ()

  if body.mass != none {
    acting-forces.push((
      role: "weight",
      symbol: $W$,
      direction: (0, -1),
      magnitude: expression.product(body.mass, scene.gravity),
      applied-at: body.center,
      style: (:),
    ))
  }

  let rope-forces = _rope-forces-on-body(scene, body, solution)
  acting-forces += rope-forces
  let has-explicit-holding-rope = body.reached-by.any(attachment => (
    attachment.kind == "rope"
      and attachment.far-end == body.hangs-from-element
  ))

  // A hanging attachment implies a supporting force even without a drawn rope.
  if body.hangs-from != none and not has-explicit-holding-rope {
    acting-forces.push((
      role: "tension",
      symbol: $T$,
      direction: vector.normalized(
        vector.subtract(body.hangs-from, body.center),
      ),
      magnitude: if solution == none or "tension" not in solution {
        none
      } else {
        solution.tension.expression
      },
      applied-at: body.center,
      style: (:),
    ))
  }

  if body.support != none {
    let unsolved-friction-direction = if solution == none {
      _unsolved-friction-direction(body)
    } else { none }
    acting-forces.push((
      role: "normal",
      symbol: $N$,
      direction: body.outward-normal,
      magnitude: if solution == none { none } else { solution.normal.expression },
      applied-at: body.contact,
      style: (:),
    ))

    // A contact that turns out to need no friction is not exerting any, so
    // nothing is drawn for it once the body has been balanced.
    let friction-force-acts = (
      body.friction != none
        and (
          solution == none
            or solution.friction.value == none
            or calc.abs(solution.friction.value) > 1e-9
        )
    )
    if friction-force-acts {
      let body-is-sliding = solution != none and solution.regime == "sliding"
      acting-forces.push((
        role: "friction",
        symbol: if solution == none {
          $f$
        } else if body-is-sliding {
          $f_k$
        } else {
          $f_s$
        },
        direction: if solution == none {
          unsolved-friction-direction
        } else {
          solution.friction.direction
        },
        magnitude: if solution == none {
          none
        } else {
          solution.friction.expression
        },
        applied-at: body.contact,
        style: (:),
      ))
    }
  }

  let applied-load-count = body.loads.len()
  for (load-index, applied-load) in body.loads.enumerate() {
    acting-forces.push((
      role: "applied",
      symbol: applied-load-symbol(
        applied-load,
        load-index,
        applied-load-count,
      ),
      direction: applied-load.direction,
      magnitude: applied-load.magnitude,
      applied-at: body.center,
      style: applied-load.style,
    ))
  }

  acting-forces
}
