// Placement of ropes and springs between resolved attachments.

#import "../../shared/vector.typ"
#import "anchors.typ" as anchors

#let resolve-attachment-point = anchors.resolve-attachment-point

#let _should-infer-wall-height-from-body(
  attachment,
  opposite-attachment,
  placed-surfaces,
  placed-bodies,
) = {
  if type(attachment) != dictionary or "at" in attachment { return false }
  let surface-name = anchors.attachment-element-name(attachment)
  let opposite-element-name = anchors.attachment-element-name(
    opposite-attachment,
  )
  (
    surface-name in placed-surfaces
      and placed-surfaces.at(surface-name).kind == "wall"
      and opposite-element-name in placed-bodies
  )
}

#let _wall-position-at-body-anchor-height(
  wall-attachment,
  body-anchor-position,
  placed-surfaces,
  declared-by,
) = {
  let wall-name = anchors.attachment-element-name(wall-attachment)
  let placed-wall = placed-surfaces.at(wall-name)
  let inferred-height = body-anchor-position.at(1)
  let lowest-wall-position = calc.min(
    placed-wall.start.at(1),
    placed-wall.end.at(1),
  )
  let highest-wall-position = calc.max(
    placed-wall.start.at(1),
    placed-wall.end.at(1),
  )
  assert(
    inferred-height >= lowest-wall-position - 0.000001
      and inferred-height <= highest-wall-position + 0.000001,
    message: (
      "typed-physics: "
        + declared-by
        + " cannot infer its attachment on wall \""
        + wall-name
        + "\" because the opposite body anchor falls outside the wall; "
        + "add `at:` to choose an explicit wall position, or extend or reposition the wall"
    ),
  )
  (placed-wall.start.at(0), inferred-height)
}

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
  if connector-declaration.kind == "spring" {
    let should-infer-start-height-from-body = _should-infer-wall-height-from-body(
      connector-declaration.from,
      connector-declaration.to,
      placed-surfaces,
      placed-bodies,
    )
    let should-infer-end-height-from-body = _should-infer-wall-height-from-body(
      connector-declaration.to,
      connector-declaration.from,
      placed-surfaces,
      placed-bodies,
    )
    if should-infer-start-height-from-body {
      start-position = _wall-position-at-body-anchor-height(
        connector-declaration.from,
        end-position,
        placed-surfaces,
        declared-by,
      )
    } else if should-infer-end-height-from-body {
      end-position = _wall-position-at-body-anchor-height(
        connector-declaration.to,
        start-position,
        placed-surfaces,
        declared-by,
      )
    }
  }
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
