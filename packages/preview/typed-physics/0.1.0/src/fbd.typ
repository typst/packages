// Free-body diagrams and component decompositions.
//
// Both views draw the same body the scene draws, in the same orientation, from
// the same enumeration of forces. The only thing they leave behind is the
// body's position in the world, which is exactly what a free-body diagram is
// for.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, group, line
#import "vector.typ"
#import "expression.typ"
#import "forces.typ"
#import "render.typ"
#import "style.typ": resolve-body-style, resolve-force-style

#let _body-centered-at-origin(body) = body + (
  center: (0, 0),
  contact: vector.scale(body.outward-normal, -body.half-extent-normal),
)

// Arrows are drawn in proportion to the forces they stand for, so a free-body
// diagram reads as a comparison. That is only honest when every magnitude is
// known; as soon as one is symbolic, they all fall back to one length.
#let force-arrow-lengths(acting-forces, diagram-style) = {
  let force-magnitude-values = acting-forces.map(
    force => if force.magnitude == none {
      none
    } else {
      expression.value-of(force.magnitude)
    },
  )
  let known-positive-magnitudes = force-magnitude-values.filter(
    magnitude => magnitude != none and magnitude > 0,
  )
  let every-force-has-a-known-positive-magnitude = (
    known-positive-magnitudes.len() == force-magnitude-values.len()
      and known-positive-magnitudes.len() > 0
  )
  let full-length-of(force) = resolve-force-style(
    diagram-style,
    force.style,
    force.role,
  ).length
  if not every-force-has-a-known-positive-magnitude {
    return acting-forces.map(full-length-of)
  }
  let largest-force-magnitude = calc.max(..known-positive-magnitudes)
  acting-forces
    .zip(force-magnitude-values)
    .map(((force, force-magnitude)) => calc.max(
      diagram-style.force-floor,
      full-length-of(force) * force-magnitude / largest-force-magnitude,
    ))
}

// Names the surface's axes without drawing them. A letter set beside the
// direction it stands for says which way is positive; a line through the force
// arrows would only compete with them.
#let render-surface-axis-labels(body, diagram-style) = {
  let surface-axes = (
    (body.direction, $x$, vector.reversed(body.outward-normal)),
    (body.outward-normal, $y$, body.direction),
  )
  for (axis-direction, axis-label, label-offset-direction) in surface-axes {
    render.render-label(
      vector.point-along(
        vector.scale(
          axis-direction,
          render.body-boundary-distance(body, axis-direction) + 0.42,
        ),
        label-offset-direction,
        0.32,
      ),
      text(fill: rgb("#868E96"), axis-label),
      diagram-style.force-text,
    )
  }
}

#let render-free-body-diagram(
  scene,
  name,
  diagram-style,
  solution: none,
  axes: auto,
  outline: true,
) = {
  let body = _body-centered-at-origin(scene.bodies.at(name))
  let acting-forces = forces.enumerate-forces(
    scene,
    name,
    solution: solution,
  )
  assert(
    acting-forces.len() > 0,
    message: "typed-physics: block \"" + name + "\" has no forces on it — give it a `mass:` or a surface to rest on",
  )
  let arrow-lengths = force-arrow-lengths(
    acting-forces,
    diagram-style,
  )
  let should-render-axes = if axes == auto {
    body.inclination != 0deg
  } else {
    axes
  }

  group(
    name: name,
    {
      if should-render-axes {
        render-surface-axis-labels(body, diagram-style)
      }
      let body-style = resolve-body-style(diagram-style, body.style)
      let inside-body-label = if body.label != auto {
        body.label
      } else {
        body.name
      }

      for (force-index, acting-force) in acting-forces.enumerate() {
        let force-style = resolve-force-style(
          diagram-style,
          acting-force.style,
          acting-force.role,
        )
        let arrow-start-distance = if outline {
          render.body-visible-boundary-distance(
            body,
            acting-force.direction,
            body-style.stroke,
          )
        } else {
          0
        }
        let arrow-tail-position = (0, 0)
        let arrow-tip-position = vector.scale(
          acting-force.direction,
          arrow-start-distance + arrow-lengths.at(force-index),
        )
        render.render-force-arrow(
          arrow-tail-position,
          arrow-tip-position,
          force-style.color,
          force-style.stroke,
        )
        render.render-label(
          vector.point-along(
            arrow-tip-position,
            acting-force.direction,
            0.3,
          ),
          text(fill: force-style.color, acting-force.symbol),
          force-style.text,
        )
        anchor(acting-force.role, arrow-tip-position)
      }
      if outline { render.render-body-outline(body, body-style) }
      render.render-label(
        (0, 0),
        inside-body-label,
        body-style.label-text,
      )
      anchor("center", (0, 0))
      anchor("default", (0, 0))
    },
  )
}

// The weight resolved into the surface's own axes, with the construction lines
// and the right angle that make the two components readable as one rectangle.
#let render-weight-component-vectors(
  scene,
  body,
  diagram-style,
  weight-arrow-length,
  should-render-weight-arrow: true,
) = {
  assert(
    body.mass != none,
    message: "typed-physics: block \"" + body.name + "\" needs a `mass:` before its weight can be resolved",
  )
  let weight-vector = (0, -weight-arrow-length)
  let weight-tangent-component-vector = vector.scale(
    body.direction,
    vector.dot-product(weight-vector, body.direction),
  )
  let weight-outward-normal-component-vector = vector.scale(
    body.outward-normal,
    vector.dot-product(weight-vector, body.outward-normal),
  )
  let weight-force-magnitude = expression.product(body.mass, scene.gravity)
  let surface-inclination = body.inclination-quantity
  let body-center = body.center
  let weight-tip-position = vector.add(body-center, weight-vector)
  let weight-tangent-component-tip = vector.add(
    body-center,
    weight-tangent-component-vector,
  )
  let weight-outward-normal-component-tip = vector.add(
    body-center,
    weight-outward-normal-component-vector,
  )

  line(
    weight-tangent-component-tip,
    weight-tip-position,
    stroke: diagram-style.construction-stroke,
  )
  line(
    weight-outward-normal-component-tip,
    weight-tip-position,
    stroke: diagram-style.construction-stroke,
  )

  let component-color = diagram-style.force-colors.component
  render.render-force-arrow(
    body-center,
    weight-tangent-component-tip,
    component-color,
    diagram-style.force-stroke,
  )
  render.render-force-arrow(
    body-center,
    weight-outward-normal-component-tip,
    component-color,
    diagram-style.force-stroke,
  )
  if should-render-weight-arrow {
    render.render-force-arrow(
      body-center,
      weight-tip-position,
      diagram-style.force-colors.weight,
      diagram-style.force-stroke,
    )
    render.render-label(
      vector.point-along(weight-tip-position, (0, -1), 0.18),
      text(fill: diagram-style.force-colors.weight, $W$),
      diagram-style.force-text,
      side: "north",
    )
  }

  // Each component is labelled just past its own tip and grows outward from
  // the construction, which is the only way all three labels fit.
  render.render-label(
    vector.point-along(
      weight-tangent-component-tip,
      vector.normalized(weight-tangent-component-vector),
      0.16,
    ),
    text(
      fill: component-color,
      expression.math-of(
        expression.product(
          weight-force-magnitude,
          expression.sine(surface-inclination),
        ),
      ),
    ),
    diagram-style.force-text,
    side: "east",
  )
  render.render-label(
    vector.point-along(
      weight-outward-normal-component-tip,
      vector.normalized(weight-outward-normal-component-vector),
      0.16,
    ),
    text(
      fill: component-color,
      expression.math-of(
        expression.product(
          weight-force-magnitude,
          expression.cosine(surface-inclination),
        ),
      ),
    ),
    diagram-style.force-text,
    side: "west",
  )
  if body.inclination != 0deg {
    // Marked at the corner of the construction rectangle rather than at the
    // body, where the two components meet under the body's own fill.
    render.render-right-angle-marker(
      weight-tangent-component-tip,
      vector.reversed(
        vector.normalized(weight-tangent-component-vector),
      ),
      vector.normalized(weight-outward-normal-component-vector),
      diagram-style,
    )
    render.render-angle-marker(
      body-center,
      vector.normalized(weight-outward-normal-component-vector),
      (0, -1),
      surface-inclination.symbol,
      diagram-style,
      radius: weight-arrow-length * 0.34,
    )
  }
}

#let render-component-decomposition(
  scene,
  name,
  diagram-style,
  of: "weight",
) = {
  assert(
    of == "weight",
    message: "typed-physics 0.1.0 resolves the weight into components; `of: \"" + of + "\"` is not available yet",
  )
  let body = _body-centered-at-origin(scene.bodies.at(name))
  // Longer than a free-body arrow: the construction has to clear the body it
  // is drawn from before the two components can be labelled apart.
  let weight-arrow-length = diagram-style.force-length * 1.5

  group(
    name: name,
    {
      render.render-body-outline(
        body,
        resolve-body-style(diagram-style, body.style),
      )
      render-weight-component-vectors(
        scene,
        body,
        diagram-style,
        weight-arrow-length,
      )
      anchor("center", (0, 0))
      anchor("default", (0, 0))
    },
  )
}

#let render-component-decomposition-on-body(
  scene,
  name,
  diagram-style,
  weight-arrow-length: auto,
  should-render-weight-arrow: true,
) = {
  let body = scene.bodies.at(name)
  let resolved-weight-arrow-length = if weight-arrow-length == auto {
    diagram-style.force-length * 1.5
  } else {
    weight-arrow-length
  }
  group(
    name: "components-" + name,
    {
      render-weight-component-vectors(
        scene,
        body,
        diagram-style,
        resolved-weight-arrow-length,
        should-render-weight-arrow: should-render-weight-arrow,
      )
      anchor("center", body.center)
      anchor("default", body.center)
    },
  )
}
