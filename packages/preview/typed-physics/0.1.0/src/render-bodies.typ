// Rendering of bodies and the labels owned by them.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, circle, group, line
#import "vector.typ"
#import "expression.typ"
#import "render-geometry.typ" as geometry
#import "style.typ": resolve-body-style

#let body-corners = geometry.body-corners
#let body-top-height = geometry.body-top-height
#let body-radius-mark-direction = geometry.body-radius-mark-direction
#let body-radius-mark-label-direction = geometry.body-radius-mark-label-direction
#let render-label = geometry.render-label

#let render-body-outline(body, body-style) = {
  if body.shape == "block" {
    line(
      ..body-corners(body),
      close: true,
      fill: body-style.fill,
      stroke: body-style.stroke,
    )
  } else if body.shape in ("ball", "disk", "ring") {
    circle(
      body.center,
      radius: body.half-extent-along,
      fill: body-style.fill,
      stroke: body-style.stroke,
    )
    if body.shape == "ring" {
      circle(
        body.center,
        radius: body.half-extent-along * 0.62,
        fill: white,
        stroke: body-style.stroke,
      )
    }
    if body.shape in ("disk", "ring") and body.radius-mark {
      let radial-mark-direction = body-radius-mark-direction(body)
      line(
        body.center,
        vector.point-along(
          body.center,
          radial-mark-direction,
          body.half-extent-along,
        ),
        stroke: body-style.stroke,
      )
      circle(
        body.center,
        radius: body.half-extent-along * 0.08,
        fill: body-style.stroke.paint,
        stroke: none,
      )
    }
  } else {
    circle(
      body.center,
      radius: body.half-extent-along,
      fill: body-style.point-mass-fill,
      stroke: none,
    )
  }
}

#let body-label(body, labels) = {
  if body.label != auto { return body.label }
  if labels == "name" or labels == "both" { return body.name }
  if labels == "mass" { return none }
  none
}

// The mass as the author declared it: a number is named by the symbol the rest
// of the package prints for it, a symbol alone stands on its own.
#let mass-label(body) = {
  if body.mass == none { return none }
  if body.mass.value == none { return body.mass.symbol }
  let mass-value = body.mass.value
  let displayed-mass = if mass-value == calc.round(mass-value) {
    str(int(mass-value))
  } else {
    expression.format-number(mass-value)
  }
  $#body.mass.symbol = #displayed-mass "kg"$
}

#let mass-symbol-label(body) = if body.mass == none {
  none
} else {
  body.mass.symbol
}

// A rough contact names both coefficients, or one when they are equal.
#let friction-label(friction-coefficients) = {
  if friction-coefficients == none { return none }
  let static-coefficient = friction-coefficients.static
  let kinetic-coefficient = friction-coefficients.kinetic
  let printed-coefficient(coefficient) = expression.math-of(
    coefficient,
    substitute: true,
  )
  let coefficients-are-the-same = (
    static-coefficient.value != none
      and static-coefficient.value == kinetic-coefficient.value
  )
  if coefficients-are-the-same {
    return $mu = #printed-coefficient(static-coefficient)$
  }
  $mu_s = #printed-coefficient(static-coefficient),
    mu_k = #printed-coefficient(kinetic-coefficient)$
}

#let render-body(
  body,
  diagram-style,
  label-annotation: (
    mode: "name",
    is-visible: true,
    offset: (0, 0),
    rotation: 0deg,
  ),
) = {
  let body-style = resolve-body-style(diagram-style, body.style)
  let half-along = body.half-extent-along
  let half-normal = body.half-extent-normal
  group(
    name: body.name,
    {
      render-body-outline(body, body-style)
      let inside-body-label = body-label(body, label-annotation.mode)
      if label-annotation.is-visible and inside-body-label != none {
        // A point has no inside to write in, so its name sits beside the dot.
        let body-is-a-point = body.shape == "point"
        let body-has-radius-mark = (
          body.shape in ("disk", "ring") and body.radius-mark
        )
        let automatic-label-position = if body-is-a-point {
          vector.point-along(body.center, (1, 0), half-along + 0.16)
        } else if body-has-radius-mark {
          vector.point-along(
            body.center,
            body-radius-mark-label-direction(body),
            half-along * 0.42,
          )
        } else {
          body.center
        }
        render-label(
          automatic-label-position,
          inside-body-label,
          body-style.label-text,
          side: if body-is-a-point { "west" } else { "center" },
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
          mass-symbol-label(body)
        } else {
          mass-label(body)
        }
        if displayed-mass != none {
          render-label(
            (body.center.at(0), body-top-height(body) + 0.3),
            displayed-mass,
            body-style.label-text,
            offset: label-annotation.offset,
            rotation: label-annotation.rotation,
          )
        }
      }
      anchor("center", body.center)
      anchor("contact", body.contact)
      anchor(
        "uphill",
        vector.point-along(body.center, body.direction, half-along),
      )
      anchor(
        "downhill",
        vector.point-along(
          body.center,
          vector.reversed(body.direction),
          half-along,
        ),
      )
      anchor(
        "outward",
        vector.point-along(body.center, body.outward-normal, half-normal),
      )
      anchor("top", (body.center.at(0), body.center.at(1) + half-normal))
      anchor("bottom", (body.center.at(0), body.center.at(1) - half-normal))
      anchor("left", (body.center.at(0) - half-along, body.center.at(1)))
      anchor("right", (body.center.at(0) + half-along, body.center.at(1)))
      anchor("default", body.center)
    },
  )
}

// ── Rigid structures and constraints ─────────────────────────────────────────
