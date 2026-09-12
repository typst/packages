// Placement of bodies on surfaces, beside bodies, or from attachments.

#import "vector.typ"
#import "expression.typ"
#import "placement-anchors.typ" as anchors
#import "placement-quantities.typ" as quantities

#let resolve-attachment-point = anchors.resolve-attachment-point
#let mass-symbol = quantities.mass-symbol

#let _resolve-contact-friction(body-declaration, support-surface) = {
  let declared-friction = if body-declaration.friction != none {
    body-declaration.friction
  } else if support-surface == none {
    none
  } else {
    support-surface.friction
  }
  if declared-friction == none { return none }
  (
    static: expression.declared(declared-friction.static, $mu_s$),
    kinetic: expression.declared(declared-friction.kinetic, $mu_k$),
  )
}

// A number prints as the body's mass symbol and substitutes to itself. Content
// written as the mass is already the symbol, unless `symbol:` names another.
#let declared-mass(body-declaration) = {
  if body-declaration.mass == none { return none }
  let printed-symbol = mass-symbol(
    body-declaration.name,
    body-declaration.symbol,
  )
  if type(body-declaration.mass) in (int, float) {
    return expression.quantity(printed-symbol, value: body-declaration.mass)
  }
  expression.quantity(
    if body-declaration.symbol == auto {
      body-declaration.mass
    } else {
      body-declaration.symbol
    },
  )
}

#let _placed-body(
  body-declaration,
  support-surface,
  contact-position,
  distance-along-surface,
  tangent-direction,
  outward-normal-direction,
  attachment-position,
) = (
  name: body-declaration.name,
  kind: "body",
  shape: body-declaration.shape,
  label: body-declaration.label,
  mass: declared-mass(body-declaration),
  half-extent-along: body-declaration.half-extent-along,
  half-extent-normal: body-declaration.half-extent-normal,
  support: if support-surface == none { none } else { support-surface.name },
  distance: distance-along-surface,
  contact: contact-position,
  center: vector.point-along(
    contact-position,
    outward-normal-direction,
    body-declaration.half-extent-normal,
  ),
  direction: tangent-direction,
  outward-normal: outward-normal-direction,
  inclination: if support-surface == none {
    0deg
  } else { support-surface.inclination },
  inclination-quantity: if support-surface == none {
    expression.number(0)
  } else { support-surface.inclination-quantity },
  friction: _resolve-contact-friction(body-declaration, support-surface),
  touching: body-declaration.touching,
  hangs-from: attachment-position,
  // What the body hangs from, as opposed to where: a rope over a pulley leads
  // somewhere else, and only the declaration still says so.
  hangs-from-element: anchors.attachment-element-name(body-declaration.hanging),
  // Filled in once every declaration has been placed, because an element that
  // reaches this body may be declared after it.
  reached-by: (),
  style: body-declaration.style,
  loads: (),
  velocities: (),
  angular-velocities: (),
  radius-mark: body-declaration.radius-mark,
  orientation: body-declaration.orientation,
  solver-supported: body-declaration.solver-supported,
)

#let _surface-frame-at-distance(support-surface, distance-along-surface) = {
  if support-surface.kind != "arc" {
    return (
      contact: vector.point-along(
        support-surface.start,
        support-surface.direction,
        distance-along-surface,
      ),
      tangent: support-surface.direction,
      outward-normal: support-surface.outward-normal,
      inclination: support-surface.inclination,
      inclination-quantity: support-surface.inclination-quantity,
    )
  }

  let position-ratio = distance-along-surface / support-surface.length
  let position-angle = (
    support-surface.start-angle
      + support-surface.sweep-angle * position-ratio
  )
  let radial-direction = vector.direction-from-angle(position-angle)
  let tangent-direction = if support-surface.sweep-angle > 0deg {
    vector.left-normal(radial-direction)
  } else {
    vector.right-normal(radial-direction)
  }
  let outward-normal-direction = if support-surface.side == "outside" {
    radial-direction
  } else {
    vector.reversed(radial-direction)
  }
  let tangent-inclination = vector.angle-of(tangent-direction)
  (
    contact: vector.point-along(
      support-surface.center,
      radial-direction,
      support-surface.radius,
    ),
    tangent: tangent-direction,
    outward-normal: outward-normal-direction,
    inclination: tangent-inclination,
    inclination-quantity: expression.declared-angle(
      tangent-inclination,
      $theta$,
    ),
  )
}

#let _place-body-on-surface(
  body-declaration,
  support-surface,
  distance-along-surface,
) = {
  if support-surface.kind == "arc" and support-surface.side == "inside" {
    assert(
      body-declaration.half-extent-normal < support-surface.radius,
      message: (
        "typed-physics: \""
          + body-declaration.name
          + "\" is too large for the inside of arc \""
          + support-surface.name
          + "\"; reduce its radius/size below "
          + expression.format-number(support-surface.radius)
          + " or increase the arc radius"
      ),
    )
  }
  let overhang-past-start = (
    body-declaration.half-extent-along - distance-along-surface
  )
  let overhang-past-end = (
    distance-along-surface
      + body-declaration.half-extent-along
      - support-surface.length
  )
  assert(
    overhang-past-start <= 1e-9,
    message: (
      "typed-physics: \""
        + body-declaration.name
        + "\" hangs off the start of \""
        + support-surface.name
        + "\" by "
        + expression.format-number(overhang-past-start)
        + " — move it along with `at:` or shrink it with `size:`"
    ),
  )
  assert(
    overhang-past-end <= 1e-9,
    message: (
      "typed-physics: \""
        + body-declaration.name
        + "\" hangs off the end of \""
        + support-surface.name
        + "\" by "
        + expression.format-number(overhang-past-end)
        + " — move it back with `at:` or shrink it with `size:`"
    ),
  )
  let local-surface-frame = _surface-frame-at-distance(
    support-surface,
    distance-along-surface,
  )
  let local-support-surface = support-surface + (
    direction: local-surface-frame.tangent,
    outward-normal: local-surface-frame.outward-normal,
    inclination: local-surface-frame.inclination,
    inclination-quantity: local-surface-frame.inclination-quantity,
  )
  _placed-body(
    body-declaration,
    local-support-surface,
    local-surface-frame.contact,
    distance-along-surface,
    local-surface-frame.tangent,
    local-surface-frame.outward-normal,
    none,
  )
}

// A hanging body rests on nothing: it sits `drop:` below whatever holds it, and
// is upright because no surface is there to tilt it.
#let _place-hanging-body(
  body-declaration,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
) = {
  let attachment-position = resolve-attachment-point(
    body-declaration.hanging,
    placed-surfaces,
    placed-bodies,
    placed-pulleys,
    "\"" + body-declaration.name + "\"",
  )
  let body-top-position = (
    attachment-position.at(0),
    attachment-position.at(1) - body-declaration.drop,
  )
  _placed-body(
    body-declaration,
    none,
    (
      body-top-position.at(0),
      body-top-position.at(1) - 2 * body-declaration.half-extent-normal,
    ),
    none,
    (1, 0),
    (0, 1),
    attachment-position,
  )
}

#let resolve-body-placement(
  body-declaration,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
) = {
  if body-declaration.hanging != none {
    return _place-hanging-body(
      body-declaration,
      placed-surfaces,
      placed-bodies,
      placed-pulleys,
    )
  }

  if body-declaration.touching != none {
    assert(
      body-declaration.touching in placed-bodies,
      message: (
        "typed-physics: \""
          + body-declaration.name
          + "\" touches \""
          + body-declaration.touching
          + "\", which is not a body declared before it"
      ),
    )
    let neighbouring-body = placed-bodies.at(body-declaration.touching)
    assert(
      neighbouring-body.support != none,
      message: "typed-physics: \"" + body-declaration.name + "\" touches \"" + neighbouring-body.name + "\", which does not rest on a surface",
    )
    let support-surface = placed-surfaces.at(neighbouring-body.support)
    let centre-to-centre-distance = (
      neighbouring-body.half-extent-along + body-declaration.half-extent-along
    )
    let signed-distance-from-neighbour = if body-declaration.side == "right" {
      centre-to-centre-distance
    } else {
      -centre-to-centre-distance
    }
    return _place-body-on-surface(
      body-declaration,
      support-surface,
      neighbouring-body.distance + signed-distance-from-neighbour,
    )
  }

  assert(
    body-declaration.on in placed-surfaces,
    message: (
      "typed-physics: \""
        + body-declaration.name
        + "\" rests on \""
        + body-declaration.on
        + "\", which is not a surface in this situation"
    ),
  )
  let support-surface = placed-surfaces.at(body-declaration.on)
  _place-body-on-surface(
    body-declaration,
    support-surface,
    support-surface.length * (body-declaration.at / 100%),
  )
}

// ── Rigid structures and constraints ─────────────────────────────────────────
