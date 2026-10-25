// Rendering of rods, pivots, supports, and pendulums.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, circle, group, line
#import "../../shared/vector.typ"
#import "geometry.typ" as geometry
#import "surfaces.typ" as surfaces
#import "bodies.typ" as bodies
#import "../style.typ": resolve-body-style, resolve-connector-style

#let rod-corners = geometry.rod-corners
#let render-label = geometry.render-label
#let render-angle-marker = geometry.render-angle-marker
#let render-surface-hatching = surfaces.render-surface-hatching
#let body-label = bodies.body-label
#let mass-label = bodies.mass-label
#let mass-symbol-label = bodies.mass-symbol-label

#let render-rod(placed-rod, diagram-style, label-annotation) = {
  let rod-style = resolve-body-style(diagram-style, placed-rod.style)
  group(
    name: placed-rod.name,
    {
      line(
        ..rod-corners(placed-rod),
        close: true,
        fill: rod-style.fill,
        stroke: rod-style.stroke,
      )
      let inside-rod-label = body-label(placed-rod, label-annotation.mode)
      if label-annotation.is-visible and inside-rod-label != none {
        render-label(
          vector.point-along(
            placed-rod.center,
            placed-rod.outward-normal,
            placed-rod.thickness / 2 + 0.18,
          ),
          inside-rod-label,
          rod-style.label-text,
          offset: label-annotation.offset,
          rotation: label-annotation.rotation,
        )
      }
      let should-render-mass-label = (
        label-annotation.is-visible
          and label-annotation.mode in ("symbol", "mass", "both")
      )
      if should-render-mass-label {
        let displayed-mass = if label-annotation.mode == "symbol" {
          mass-symbol-label(placed-rod)
        } else {
          mass-label(placed-rod)
        }
        if displayed-mass != none {
          render-label(
            vector.point-along(
              placed-rod.center-of-mass,
              vector.reversed(placed-rod.outward-normal),
              placed-rod.thickness / 2 + 0.22,
            ),
            displayed-mass,
            rod-style.label-text,
            offset: label-annotation.offset,
            rotation: label-annotation.rotation,
          )
        }
      }
      anchor("start", placed-rod.start)
      anchor("end", placed-rod.end)
      anchor("center", placed-rod.center)
      anchor("center-of-mass", placed-rod.center-of-mass)
      anchor("default", placed-rod.center)
    },
  )
}

#let render-pivot(placed-pivot, diagram-style) = {
  let pivot-style = resolve-connector-style(
    diagram-style,
    placed-pivot.style,
    "pivot",
  )
  circle(
    placed-pivot.center,
    radius: placed-pivot.radius,
    fill: white,
    stroke: pivot-style.stroke,
  )
  circle(
    placed-pivot.center,
    radius: placed-pivot.radius * 0.28,
    fill: pivot-style.stroke.paint,
    stroke: none,
  )
}

#let render-support(placed-support, diagram-style) = {
  let support-style = resolve-connector-style(
    diagram-style,
    placed-support.style,
    "support",
  )
  let support-tangent = vector.direction-from-angle(placed-support.angle)
  let support-normal = vector.left-normal(support-tangent)
  let support-size = placed-support.size
  if placed-support.support-kind == "fixed" {
    let wall-start = vector.point-along(
      placed-support.center,
      vector.reversed(support-tangent),
      support-size / 2,
    )
    let wall-end = vector.point-along(
      placed-support.center,
      support-tangent,
      support-size / 2,
    )
    line(wall-start, wall-end, stroke: support-style.stroke)
    render-surface-hatching(
      wall-start,
      wall-end,
      support-normal,
      (
        hatch-stroke: support-style.stroke,
        hatch-spacing: support-size / 4,
        hatch-length: support-size * 0.28,
      ),
    )
    return
  }

  let support-contact = placed-support.contact
  let base-center = vector.point-along(
    support-contact,
    vector.reversed(support-normal),
    support-size * 0.72,
  )
  let base-start = vector.point-along(
    base-center,
    vector.reversed(support-tangent),
    support-size / 2,
  )
  let base-end = vector.point-along(
    base-center,
    support-tangent,
    support-size / 2,
  )
  line(
    support-contact,
    base-start,
    base-end,
    close: true,
    fill: support-style.fill,
    stroke: support-style.stroke,
  )
  if placed-support.support-kind == "roller" {
    let roller-radius = support-size * 0.11
    let roller-center-offset = support-size * 0.18
    for signed-offset in (-1, 1) {
      circle(
        vector.point-along(
          vector.point-along(
            base-center,
            support-tangent,
            signed-offset * support-size * 0.28,
          ),
          vector.reversed(support-normal),
          roller-center-offset,
        ),
        radius: roller-radius,
        fill: white,
        stroke: support-style.stroke,
      )
    }
    let foundation-center = vector.point-along(
      base-center,
      vector.reversed(support-normal),
      roller-center-offset + roller-radius,
    )
    line(
      vector.point-along(
        foundation-center,
        vector.reversed(support-tangent),
        support-size * 0.65,
      ),
      vector.point-along(
        foundation-center,
        support-tangent,
        support-size * 0.65,
      ),
      stroke: support-style.stroke,
    )
  }
}

#let render-pendulum(placed-pendulum, diagram-style, label-annotation) = {
  let pendulum-style = resolve-body-style(
    diagram-style,
    placed-pendulum.style,
  )
  let connector-style = resolve-connector-style(diagram-style, (:), "rope")
  group(
    name: placed-pendulum.name,
    {
      if placed-pendulum.angle != 0deg {
        line(
          placed-pendulum.pivot,
          vector.point-along(
            placed-pendulum.pivot,
            (0, -1),
            placed-pendulum.length * 0.46,
          ),
          stroke: diagram-style.construction-stroke,
        )
        let pendulum-angle-label = if placed-pendulum.angle-label == none {
          none
        } else if placed-pendulum.angle-label == auto {
          $theta$
        } else {
          placed-pendulum.angle-label
        }
        render-angle-marker(
          placed-pendulum.pivot,
          (0, -1),
          placed-pendulum.direction,
          pendulum-angle-label,
          diagram-style,
          radius: calc.min(
            diagram-style.angle-radius,
            placed-pendulum.length * 0.28,
          ),
        )
      }
      line(
        placed-pendulum.pivot,
        placed-pendulum.bob,
        stroke: connector-style.stroke,
      )
      circle(
        placed-pendulum.pivot,
        radius: placed-pendulum.radius * 0.16,
        fill: diagram-style.body-stroke.paint,
        stroke: none,
      )
      circle(
        placed-pendulum.bob,
        radius: placed-pendulum.radius,
        fill: pendulum-style.fill,
        stroke: pendulum-style.stroke,
      )
      let bob-label = body-label(placed-pendulum, label-annotation.mode)
      if label-annotation.is-visible and bob-label != none {
        render-label(
          placed-pendulum.bob,
          bob-label,
          pendulum-style.label-text,
          offset: label-annotation.offset,
          rotation: label-annotation.rotation,
        )
      }
      let should-render-mass-label = (
        label-annotation.is-visible
          and label-annotation.mode in ("symbol", "mass", "both")
      )
      if should-render-mass-label {
        let displayed-mass = if label-annotation.mode == "symbol" {
          mass-symbol-label(placed-pendulum)
        } else {
          mass-label(placed-pendulum)
        }
        if displayed-mass != none {
          render-label(
            vector.point-along(
              placed-pendulum.bob,
              if placed-pendulum.angle >= 0deg { (1, 0) } else { (-1, 0) },
              placed-pendulum.radius + 0.22,
            ),
            displayed-mass,
            pendulum-style.label-text,
            side: if placed-pendulum.angle >= 0deg { "west" } else { "east" },
            offset: label-annotation.offset,
            rotation: label-annotation.rotation,
          )
        }
      }
      anchor("pivot", placed-pendulum.pivot)
      anchor("bob", placed-pendulum.bob)
      anchor("center", placed-pendulum.bob)
      anchor("default", placed-pendulum.bob)
    },
  )
}

// ── Connectors ───────────────────────────────────────────────────────────────
