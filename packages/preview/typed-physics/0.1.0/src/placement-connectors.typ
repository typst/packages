// Placement of ropes and springs between resolved attachments.

#import "vector.typ"
#import "placement-anchors.typ" as anchors

#let resolve-attachment-point = anchors.resolve-attachment-point

#let _tangent-point-on-pulley(placed-pulley, external-position, wrap-side) = {
  let centre-to-point = vector.subtract(external-position, placed-pulley.center)
  let distance-to-point = vector.magnitude(centre-to-point)
  if distance-to-point <= placed-pulley.radius {
    return placed-pulley.center
  }
  let tangent-offset-angle = calc.asin(placed-pulley.radius / distance-to-point)
  let angle-to-point = vector.angle-of(centre-to-point)
  let tangent-direction = vector.direction-from-angle(
    angle-to-point + wrap-side * (90deg - tangent-offset-angle),
  )
  vector.point-along(
    placed-pulley.center,
    tangent-direction,
    placed-pulley.radius,
  )
}

#let resolve-connector-geometry(
  connector-declaration,
  placed-surfaces,
  placed-bodies,
  placed-pulleys,
  placed-structures: (:),
) = {
  let declared-by = (
    connector-declaration.kind + " \"" + connector-declaration.name + "\""
  )
  let resolve-end(attachment) = resolve-attachment-point(
    attachment,
    placed-surfaces,
    placed-bodies,
    placed-pulleys,
    declared-by,
    placed-structures: placed-structures,
  )
  let start-position = resolve-end(connector-declaration.from)
  let end-position = resolve-end(connector-declaration.to)
  let connector-span = vector.subtract(end-position, start-position)
  assert(
    vector.magnitude(connector-span) > 0.000001,
    message: (
      "typed-physics: "
        + declared-by
        + " has coincident `from:` and `to:` endpoints; choose two distinct attachment points"
    ),
  )

  let placed-connector = (
    name: connector-declaration.name,
    kind: connector-declaration.kind,
    start: start-position,
    end: end-position,
    over: none,
    style: connector-declaration.style,
  )
  if connector-declaration.kind == "spring" {
    return placed-connector + (
      coils: connector-declaration.coils,
      width: connector-declaration.width,
    )
  }

  let pulley-name = connector-declaration.over
  if pulley-name == none { return placed-connector }
  assert(
    pulley-name in placed-pulleys,
    message: "typed-physics: " + declared-by + " runs over \"" + pulley-name + "\", which is not a pulley declared before it",
  )
  let placed-pulley = placed-pulleys.at(pulley-name)
  let start-distance-from-pulley = vector.magnitude(
    vector.subtract(start-position, placed-pulley.center),
  )
  let end-distance-from-pulley = vector.magnitude(
    vector.subtract(end-position, placed-pulley.center),
  )
  assert(
    start-distance-from-pulley > placed-pulley.radius
      and end-distance-from-pulley > placed-pulley.radius,
    message: (
      "typed-physics: "
        + declared-by
        + " runs over pulley \""
        + pulley-name
        + "\" but an endpoint lies on or inside the wheel; move both endpoints outside its radius"
    ),
  )
  // The rope leaves each end on the side that carries it over the wheel rather
  // than under it.
  let start-is-left-of-pulley = (
    start-position.at(0) <= placed-pulley.center.at(0)
  )
  placed-connector + (
    over: pulley-name,
    start-tangent: _tangent-point-on-pulley(
      placed-pulley,
      start-position,
      if start-is-left-of-pulley { -1 } else { 1 },
    ),
    end-tangent: _tangent-point-on-pulley(
      placed-pulley,
      end-position,
      if start-is-left-of-pulley { 1 } else { -1 },
    ),
  )
}

// ── The situation ────────────────────────────────────────────────────────────
