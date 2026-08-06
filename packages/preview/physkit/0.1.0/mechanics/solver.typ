#import "../core/model.typ": find-object, replace-object, validate-objects
#import "../geometry/lib.typ" as geometry
#import "anchors.typ": object-anchor

#let _surface-frame(support) = {
  let reference = geometry.surface-frame(support)
  let length = geometry.distance(support.start, support.end)
  (
    tangent: reference.x-axis,
    normal: reference.y-axis,
    length: length,
    angle: geometry.angle-of(reference.x-axis),
  )
}

#let surface-point(support, distance: none, position: none, offset: 0) = {
  let frame = _surface-frame(support)
  let along = if distance != none { distance } else { frame.length * position / 100% }
  geometry.add(
    geometry.add(support.start, geometry.scale(frame.tangent, along)),
    geometry.scale(frame.normal, offset),
  )
}

#let _resolve-parallel-rope(objects, constraint) = {
  let pulley = find-object(objects, constraint.object)
  let support = find-object(objects, constraint.support)
  let reference = find-object(objects, constraint.reference)
  let source-object = find-object(objects, constraint.source.object)

  assert(pulley.kind == "pulley",
    message: "align-rope-parallel requires a pulley")
  assert(calc.abs(support.start.at(1) - support.end.at(1)) < 0.0001,
    message: "align-rope-parallel currently requires a horizontal support")

  let source = object-anchor(source-object, constraint.source.anchor)
  let reference-frame = _surface-frame(reference)
  let tangent = reference-frame.tangent
  let radial = geometry.scale(
    reference-frame.normal,
    if constraint.wrap-side == "upper" { 1 } else { -1 },
  )
  assert(calc.abs(tangent.at(0)) > 0.0001,
    message: "The reference surface cannot be vertical")

  // The support fixes the pulley's horizontal coordinate; its height is free.
  let candidate = surface-point(
    support,
    position: constraint.support-position,
    offset: constraint.support-distance,
  )
  let along = (
    candidate.at(0) - source.at(0) + pulley.radius * radial.at(0)
  ) / tangent.at(0)
  assert(along > 0,
    message: "The support position puts the pulley behind the rope source")

  let entry = geometry.add(source, geometry.scale(tangent, along))
  let center = geometry.sub(entry, geometry.scale(radial, pulley.radius))
  let vertical-shift = center.at(1) - candidate.at(1)

  let updated-support = support
  updated-support.insert("start", geometry.add(support.start, (0, vertical-shift)))
  updated-support.insert("end", geometry.add(support.end, (0, vertical-shift)))

  let updated-pulley = pulley
  updated-pulley.insert("at", center)
  updated-pulley.insert("rope-entry", geometry.port(
    entry,
    tangent,
    name: "parallel-entry",
    owner: pulley.id,
  ))

  replace-object(replace-object(objects, updated-support), updated-pulley)
}

#let _resolve-one(objects, constraint) = {
  if constraint.kind == "align-rope-parallel" {
    _resolve-parallel-rope(objects, constraint)
  } else {
    let object = find-object(objects, constraint.object)
    let support = find-object(objects, constraint.support)
    let updated = object

    if constraint.kind == "on-surface" {
      let frame = _surface-frame(support)
      assert(object.kind == "box", message: "on-surface currently supports box objects")
      let center = surface-point(
        support,
        distance: constraint.distance,
        position: constraint.position,
        offset: object.height / 2 + constraint.gap,
      )
      updated.insert("at", center)
      updated.insert("angle", frame.angle)
    } else if constraint.kind == "fixed-to" {
      let center = surface-point(
        support,
        position: constraint.position,
        offset: constraint.distance,
      )
      updated.insert("at", center)
    } else if constraint.kind == "suspended-from" {
      assert(object.kind == "box",
        message: "suspended-from currently supports box objects")
      assert(support.kind == "pulley",
        message: "suspended-from requires a pulley support")
      assert(support.at != none,
        message: "Pulley `" + support.id + "` must be positioned before suspended-from")

      let radial = if constraint.side == "right" { (1, 0) } else { (-1, 0) }
      let direction = (0, -1)
      let port-position = geometry.add(
        support.at,
        geometry.scale(radial, support.radius),
      )
      let center = geometry.add(
        port-position,
        geometry.scale(direction, constraint.length + object.height / 2),
      )
      updated.insert("at", center)
      updated.insert("angle", 0deg)
      updated.insert("suspension", (
        pulley: support.id,
        side: constraint.side,
        port: geometry.port(
          port-position,
          direction,
          name: constraint.side,
          owner: support.id,
        ),
      ))
    } else {
      panic("Unknown mechanics constraint: " + constraint.kind)
    }
    replace-object(objects, updated)
  }
}

/// Resolve all supported object positions in declaration order.
#let resolve(objects, constraints) = {
  let resolved = validate-objects(objects)
  for constraint in constraints {
    resolved = _resolve-one(resolved, constraint)
  }
  for object in resolved {
    if object.kind == "box" or object.kind == "pulley" {
      assert(object.at != none,
        message: "Object `" + object.id + "` has no resolved position")
    }
  }
  resolved
}
