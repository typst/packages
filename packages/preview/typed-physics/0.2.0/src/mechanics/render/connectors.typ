// Rendering of pulleys, ropes, and springs.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, arc, circle, group, line
#import "../../shared/vector.typ"
#import "../style.typ": resolve-connector-style

#let render-pulley(placed-pulley, diagram-style) = {
  let wheel-style = resolve-connector-style(
    diagram-style,
    placed-pulley.style,
    "pulley",
  )
  let wheel-centre = placed-pulley.center
  let wheel-radius = placed-pulley.radius
  group(
    name: placed-pulley.name,
    {
      circle(
        wheel-centre,
        radius: wheel-radius,
        fill: wheel-style.fill,
        stroke: diagram-style.pulley-stroke,
      )
      circle(
        wheel-centre,
        radius: wheel-radius * 0.16,
        fill: diagram-style.pulley-stroke.paint,
        stroke: none,
      )
      anchor("center", wheel-centre)
      anchor("top", (wheel-centre.at(0), wheel-centre.at(1) + wheel-radius))
      anchor("bottom", (wheel-centre.at(0), wheel-centre.at(1) - wheel-radius))
      anchor("left", (wheel-centre.at(0) - wheel-radius, wheel-centre.at(1)))
      anchor("right", (wheel-centre.at(0) + wheel-radius, wheel-centre.at(1)))
      anchor("default", wheel-centre)
    },
  )
}

// The zigzag of a spring: a straight lead at each end so the attachment reads
// clearly, and an even coil between them.
#let spring-path(start-position, end-position, coil-count, coil-width) = {
  let spring-axis = vector.subtract(end-position, start-position)
  let spring-length = vector.magnitude(spring-axis)
  if spring-length == 0 { return (start-position, end-position) }

  let axis-direction = vector.normalized(spring-axis)
  let coil-offset-direction = vector.left-normal(axis-direction)
  let lead-length = spring-length * 0.18
  let coiled-length = spring-length - 2 * lead-length
  let coil-start = vector.point-along(
    start-position,
    axis-direction,
    lead-length,
  )
  let zigzag-count = 2 * coil-count
  let path-points = (start-position, coil-start)
  for zigzag-index in range(1, zigzag-count) {
    path-points.push(
      vector.point-along(
        vector.point-along(
          coil-start,
          axis-direction,
          coiled-length * zigzag-index / zigzag-count,
        ),
        coil-offset-direction,
        (if calc.rem(zigzag-index, 2) == 1 { 1 } else { -1 })
          * coil-width
          / 2,
      ),
    )
  }
  path-points.push(
    vector.point-along(coil-start, axis-direction, coiled-length),
  )
  path-points.push(end-position)
  path-points
}

// A rope that runs over a pulley leaves each end at a tangent and wraps the
// side of the wheel its two ends do not face.
#let _render-rope-over-pulley(
  placed-connector,
  placed-pulley,
  connector-stroke,
) = {
  line(
    placed-connector.start,
    placed-connector.start-tangent,
    stroke: connector-stroke,
  )
  line(
    placed-connector.end-tangent,
    placed-connector.end,
    stroke: connector-stroke,
  )
  let angle-at(position) = vector.angle-of(
    vector.subtract(position, placed-pulley.center),
  )
  let start-angle = angle-at(placed-connector.start-tangent)
  let end-angle = angle-at(placed-connector.end-tangent)
  let direction-the-ends-face = vector.normalized(
    vector.add(
      vector.normalized(
        vector.subtract(placed-connector.start, placed-pulley.center),
      ),
      vector.normalized(
        vector.subtract(placed-connector.end, placed-pulley.center),
      ),
    ),
  )
  let shorter-arc-faces-the-ends = (
    vector.dot-product(
      vector.direction-from-angle((start-angle + end-angle) / 2),
      direction-the-ends-face,
    )
      > 0
  )
  arc(
    placed-pulley.center,
    start: start-angle,
    stop: if not shorter-arc-faces-the-ends {
      end-angle
    } else if end-angle > start-angle {
      end-angle - 360deg
    } else { end-angle + 360deg },
    radius: placed-pulley.radius,
    anchor: "origin",
    stroke: connector-stroke,
  )
}

#let render-connector(placed-connector, scene, diagram-style) = {
  let connector-style = resolve-connector-style(
    diagram-style,
    placed-connector.style,
    placed-connector.kind,
  )
  group(
    name: placed-connector.name,
    {
      if placed-connector.kind == "spring" {
        line(
          ..spring-path(
            placed-connector.start,
            placed-connector.end,
            placed-connector.coils,
            placed-connector.width,
          ),
          stroke: connector-style.stroke,
        )
      } else if placed-connector.over == none {
        line(
          placed-connector.start,
          placed-connector.end,
          stroke: connector-style.stroke,
        )
      } else {
        _render-rope-over-pulley(
          placed-connector,
          scene.pulleys.at(placed-connector.over),
          connector-style.stroke,
        )
      }
      anchor("start", placed-connector.start)
      anchor("end", placed-connector.end)
      anchor(
        "default",
        vector.midpoint(placed-connector.start, placed-connector.end),
      )
    },
  )
}

// ── Loads and motion ─────────────────────────────────────────────────────────

// An applied load is drawn arriving at the face it acts on, so the arrow
// points the way the force does and ends where it is applied.
