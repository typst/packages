#import "../core/model.typ": find-object
#import "../geometry/lib.typ" as geometry
#import "../primitives/lib.typ" as p
#import "solver.typ": resolve, surface-point
#import "anchors.typ": object-anchor

#let _anchor(objects, reference) = {
  let object = find-object(objects, reference.object)
  object-anchor(object, reference.anchor)
}

#let _render-surface(object, theme) = {
  if object.kind == "inclined-plane" {
    p.polygon(
      object.start,
      object.base-end,
      object.end,
      fill: theme.surface-fill,
      stroke: theme.surface-ink + 0.75pt,
    )
    p.arc(object.start, 0.7, 0deg, object.angle, stroke: theme.surface-ink + 0.55pt)
    p.label(p.polar(object.start, 1.02, object.angle / 2),
      str(calc.round(object.angle / 1deg)) + "°")
  } else {
    p.surface(
      object.start,
      object.end,
      hatch-side: -object.free-side,
      hatch: object.hatch,
      color: theme.surface-ink,
    )
  }
  if object.label != none {
    p.label(
      p.midpoint(object.start, object.end),
      object.label,
      anchor: object.label-anchor,
      offset: object.label-offset,
    )
  }
}

#let _render-object(object, theme) = {
  if object.kind == "box" {
    p.rectangle(
      object.at,
      width: object.width,
      height: object.height,
      angle: object.angle,
      fill: if object.fill == none { theme.body-fill } else { object.fill },
      stroke: theme.ink + 0.75pt,
    )
    if object.label != none {
      p.label(
        object.at,
        object.label,
        anchor: object.label-anchor,
        offset: object.label-offset,
      )
    }
  } else if object.kind == "pulley" {
    p.circle(object.at, radius: object.radius, fill: white, stroke: theme.ink + 0.8pt)
    p.circle(object.at, radius: 2.3pt, fill: theme.ink, stroke: none)
    if object.label != none {
      let offset = if object.label-offset == none {
        (0, object.radius + 0.28)
      } else {
        object.label-offset
      }
      p.label(object.at, object.label,
        anchor: object.label-anchor, offset: offset)
    }
  }
}

#let _render-rope(connection, objects, theme) = {
  let color = if connection.color == none { theme.rope-ink } else { connection.color }
  let previous = none
  let label-point = none

  for (index, item) in connection.path.enumerate() {
    if item.kind == "anchor" {
      let point = _anchor(objects, item)
      if previous != none {
        p.line(previous, point, stroke: color + connection.stroke)
        if label-point == none {
          label-point = p.add(
            previous,
            p.scale(
              p.sub(point, previous),
              connection.label-position / 100%,
            ),
          )
        }
      }
      previous = point
    } else if item.kind == "wrap" {
      let pulley = find-object(objects, item.object)
      assert(pulley.kind == "pulley", message: "wrap requires a pulley object")
      assert(previous != none, message: "A pulley wrap requires a preceding connection")
      assert(index + 1 < connection.path.len(),
        message: "A pulley wrap requires a following connection")

      let next-reference = connection.path.at(index + 1)
      assert(next-reference.kind == "anchor",
        message: "A pulley wrap must be followed by an object anchor")
      let next-point = _anchor(objects, next-reference)
      let next-object = find-object(objects, next-reference.object)

      let constrained-entry = pulley.at("rope-entry", default: none)
      let entry = if item.entry != auto {
        p.circle-anchor(pulley.at, pulley.radius, anchor: item.entry)
      } else if constrained-entry != none {
        constrained-entry.position
      } else {
        geometry.select-tangent(
          geometry.circle-tangent-points(previous, pulley.at, pulley.radius),
          if item.side == "upper" { "upper" } else { "lower" },
        )
      }

      let suspension = next-object.at("suspension", default: none)
      let exit = if item.exit != auto {
        p.circle-anchor(pulley.at, pulley.radius, anchor: item.exit)
      } else if suspension != none and suspension.pulley == pulley.id {
        suspension.port.position
      } else {
        geometry.select-tangent(
          geometry.circle-tangent-points(next-point, pulley.at, pulley.radius),
          if item.side == "upper" { "upper" } else { "lower" },
        )
      }

      p.line(previous, entry, stroke: color + connection.stroke)
      let start-angle = geometry.angle-of(geometry.sub(entry, pulley.at))
      let stop-angle = geometry.angle-of(geometry.sub(exit, pulley.at))
      if item.side == "upper" and stop-angle >= start-angle { stop-angle -= 360deg }
      if item.side == "lower" and stop-angle <= start-angle { stop-angle += 360deg }
      p.arc(pulley.at, pulley.radius, start-angle, stop-angle,
        stroke: color + connection.stroke)
      previous = exit
    } else {
      panic("Unknown rope path item: " + item.kind)
    }
  }
  if connection.label != none and label-point != none {
    p.label(
      label-point,
      connection.label,
      anchor: connection.label-anchor,
      offset: connection.label-offset,
    )
  }
}

#let _render-constraint(constraint, objects, theme) = {
  if constraint.kind == "fixed-to" or constraint.kind == "align-rope-parallel" {
    let object = find-object(objects, constraint.object)
    let support = find-object(objects, constraint.support)
    let position = if constraint.kind == "fixed-to" {
      constraint.position
    } else {
      constraint.support-position
    }
    let attachment = surface-point(support, position: position)
    p.line(attachment, object.at, stroke: theme.ink + 0.9pt)
  }
}

#let _render-force(force, objects, theme) = {
  let object = find-object(objects, force.object)
  let origin = _anchor(objects, (
    kind: "anchor",
    object: force.object,
    anchor: force.anchor,
  ))
  let direction = p.normalize(force.direction)
  let end = p.add(origin, p.scale(direction, force.magnitude))
  p.arrow(
    origin,
    end,
    label: force.label,
    color: if force.color == none { theme.force-ink } else { force.color },
    label-position: force.label-position,
    label-offset: force.label-offset,
  )
}

/// Resolve and render a mechanics diagram.
#let diagram(
  objects: (),
  constraints: (),
  connections: (),
  forces: (),
  theme: p.default-theme,
) = {
  let resolved = resolve(objects, constraints)
  p.canvas(theme: theme, {
    for object in resolved {
      if object.kind == "surface" or object.kind == "inclined-plane" {
        _render-surface(object, theme)
      }
    }
    for constraint in constraints { _render-constraint(constraint, resolved, theme) }
    for connection in connections { _render-rope(connection, resolved, theme) }
    for object in resolved {
      if object.kind != "surface" and object.kind != "inclined-plane" {
        _render-object(object, theme)
      }
    }
    for force in forces { _render-force(force, resolved, theme) }
  })
}
