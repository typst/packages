// Shared drawing geometry used by scenes, dimensions, and free-body diagrams.

#import "@preview/cetz:0.5.2"
#import cetz.draw: arc, content, line
#import "../../shared/vector.typ"

#let render-label(
  position,
  label-content,
  text-style,
  side: "center",
  offset: (0, 0),
  rotation: 0deg,
) = {
  let styled-label = text(..text-style, label-content)
  content(
    vector.add(position, offset),
    if rotation == 0deg {
      styled-label
    } else {
      rotate(rotation, reflow: false, styled-label)
    },
    anchor: side,
  )
}

#let render-force-arrow(
  tail-position,
  tip-position,
  force-color,
  force-stroke,
) = line(
  tail-position,
  tip-position,
  stroke: force-stroke + force-color,
  mark: (end: "stealth", fill: force-color, scale: 0.5),
)

#let stroke-thickness(stroke-value) = {
  if stroke-value == none { return 0pt }
  if type(stroke-value) == type(1pt) { return stroke-value }
  if type(stroke-value) == dictionary {
    return stroke-value.at("thickness", default: 1pt)
  }
  1pt
}

// A stroked outline extends half its thickness beyond its geometric path.
// CeTZ canvas coordinates use centimetres as world units.
#let stroke-outset(stroke-value) = (
  stroke-thickness(stroke-value) / 2 / 1cm
)

#let render-angle-marker(
  corner-position,
  start-direction,
  end-direction,
  label,
  diagram-style,
  radius: auto,
  label-side: "center",
  label-offset: (0, 0),
  label-rotation: 0deg,
) = {
  let marker-radius = if radius == auto {
    diagram-style.angle-radius
  } else {
    radius
  }
  let start-angle = vector.angle-of(start-direction)
  let end-angle = vector.angle-of(end-direction)
  arc(
    corner-position,
    start: start-angle,
    stop: end-angle,
    radius: marker-radius,
    anchor: "origin",
    stroke: diagram-style.angle-stroke,
  )
  if label != none {
    render-label(
      vector.point-along(
        corner-position,
        vector.direction-from-angle((start-angle + end-angle) / 2),
        marker-radius * 1.4,
      ),
      label,
      diagram-style.angle-text,
      side: label-side,
      offset: label-offset,
      rotation: label-rotation,
    )
  }
}

// A square corner drawn where two perpendicular directions meet.
#let render-right-angle-marker(
  corner-position,
  first-direction,
  second-direction,
  diagram-style,
) = {
  let first-marker-corner = vector.point-along(
    corner-position,
    first-direction,
    diagram-style.right-angle-size,
  )
  let second-marker-corner = vector.point-along(
    corner-position,
    second-direction,
    diagram-style.right-angle-size,
  )
  let outer-marker-corner = vector.add(
    first-marker-corner,
    vector.subtract(second-marker-corner, corner-position),
  )
  line(
    first-marker-corner,
    outer-marker-corner,
    second-marker-corner,
    stroke: diagram-style.angle-stroke,
  )
}

// ── Surfaces ─────────────────────────────────────────────────────────────────


#let body-corners(body) = {
  let half-tangent-span = vector.scale(body.direction, body.half-extent-along)
  let half-normal-span = vector.scale(
    body.outward-normal,
    body.half-extent-normal,
  )
  (
    vector.subtract(
      vector.subtract(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.subtract(
      vector.add(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.add(
      vector.add(body.center, half-tangent-span),
      half-normal-span,
    ),
    vector.add(
      vector.subtract(body.center, half-tangent-span),
      half-normal-span,
    ),
  )
}

// How far a body's own outline reaches in a direction, so an arrow can start
// where the body ends instead of crossing whatever is drawn inside it. A round
// body reaches its radius whichever way you look.
#let body-boundary-distance(body, direction) = {
  if body.shape != "block" { return body.half-extent-along }
  let tangent-reach = (
    calc.abs(vector.dot-product(direction, body.direction))
      / body.half-extent-along
  )
  let normal-reach = (
    calc.abs(vector.dot-product(direction, body.outward-normal))
      / body.half-extent-normal
  )
  1 / calc.max(tangent-reach, normal-reach)
}

#let body-visible-boundary-distance(
  body,
  direction,
  body-stroke,
) = {
  let outline-outset = if body.shape == "point" {
    0
  } else {
    stroke-outset(body-stroke)
  }
  if body.shape != "block" {
    return body.half-extent-along + outline-outset
  }
  let visible-half-tangent-span = body.half-extent-along + outline-outset
  let visible-half-normal-span = body.half-extent-normal + outline-outset
  let tangent-reach = (
    calc.abs(vector.dot-product(direction, body.direction))
      / visible-half-tangent-span
  )
  let normal-reach = (
    calc.abs(vector.dot-product(direction, body.outward-normal))
      / visible-half-normal-span
  )
  1 / calc.max(tangent-reach, normal-reach)
}

// The highest point of a body in the world, which is what a label above it has
// to clear: a tilted square reaches up on a corner.
#let body-top-height(body) = if body.shape == "block" {
  calc.max(..body-corners(body).map(corner => corner.at(1)))
} else {
  body.center.at(1) + body.half-extent-normal
}

#let body-radius-mark-direction(body) = vector.direction-from-angle(
  body.inclination + body.orientation,
)

#let body-radius-mark-label-direction(body) = {
  let direction-away-from-mark = vector.reversed(
    body-radius-mark-direction(body),
  )
  let horizontal-component = direction-away-from-mark.at(0)
  let vertical-component = direction-away-from-mark.at(1)
  if calc.abs(horizontal-component) >= calc.abs(vertical-component) {
    (if horizontal-component < 0 { -1 } else { 1 }, 0)
  } else {
    (0, if vertical-component < 0 { -1 } else { 1 })
  }
}


#let rod-corners(placed-rod) = {
  let half-normal-span = vector.scale(
    placed-rod.outward-normal,
    placed-rod.thickness / 2,
  )
  (
    vector.subtract(placed-rod.start, half-normal-span),
    vector.subtract(placed-rod.end, half-normal-span),
    vector.add(placed-rod.end, half-normal-span),
    vector.add(placed-rod.start, half-normal-span),
  )
}

#let rod-boundary-distance-from(
  placed-rod,
  application-position,
  direction-away-from-rod,
  rod-stroke,
) = {
  let position-from-center = vector.subtract(
    application-position,
    placed-rod.center,
  )
  let position-along-rod = vector.dot-product(
    position-from-center,
    placed-rod.direction,
  )
  let direction-along-rod = vector.dot-product(
    direction-away-from-rod,
    placed-rod.direction,
  )
  let direction-normal-to-rod = vector.dot-product(
    direction-away-from-rod,
    placed-rod.outward-normal,
  )
  let outline-outset = stroke-outset(rod-stroke)
  let half-rod-length = placed-rod.length / 2 + outline-outset
  let half-rod-thickness = placed-rod.thickness / 2 + outline-outset
  let boundary-distances = ()

  if calc.abs(direction-along-rod) > 0.000001 {
    let signed-end-position = if direction-along-rod > 0 {
      half-rod-length
    } else {
      -half-rod-length
    }
    boundary-distances.push(
      (signed-end-position - position-along-rod) / direction-along-rod,
    )
  }
  if calc.abs(direction-normal-to-rod) > 0.000001 {
    let signed-face-position = if direction-normal-to-rod > 0 {
      half-rod-thickness
    } else {
      -half-rod-thickness
    }
    boundary-distances.push(
      signed-face-position / direction-normal-to-rod,
    )
  }

  calc.min(..boundary-distances.filter(distance => distance >= 0))
}
