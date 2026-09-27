// Rendering of applied loads, torques, motion, and selected body forces.

#import "@preview/cetz:0.5.2"
#import cetz.draw: arc
#import "vector.typ"
#import "forces.typ" as force-enumeration
#import "render-geometry.typ" as geometry
#import "style.typ": resolve-body-style, resolve-force-style, resolve-velocity-style

#let body-visible-boundary-distance = geometry.body-visible-boundary-distance
#let rod-boundary-distance-from = geometry.rod-boundary-distance-from
#let render-force-arrow = geometry.render-force-arrow
#let render-label = geometry.render-label

#let render-applied-load(
  body,
  applied-load,
  force-symbol,
  diagram-style,
) = {
  let load-style = resolve-force-style(
    diagram-style,
    applied-load.style,
    "applied",
  )
  let body-style = resolve-body-style(diagram-style, body.style)
  let direction-away-from-body = vector.reversed(applied-load.direction)
  let arrow-tip-position = vector.point-along(
    body.center,
    direction-away-from-body,
    body-visible-boundary-distance(
      body,
      direction-away-from-body,
      body-style.stroke,
    ),
  )
  let arrow-tail-position = vector.point-along(
    arrow-tip-position,
    direction-away-from-body,
    load-style.length,
  )
  render-force-arrow(
    arrow-tail-position,
    arrow-tip-position,
    load-style.color,
    load-style.stroke,
  )
  render-label(
    vector.point-along(arrow-tail-position, direction-away-from-body, 0.3),
    text(fill: load-style.color, force-symbol),
    load-style.text,
  )
}

#let render-applied-load-on-rod(
  placed-rod,
  applied-load,
  force-symbol,
  diagram-style,
) = {
  let load-style = resolve-force-style(
    diagram-style,
    applied-load.style,
    "applied",
  )
  let rod-style = resolve-body-style(diagram-style, placed-rod.style)
  let direction-away-from-rod = vector.reversed(applied-load.direction)
  let distance-to-visible-rod-border = rod-boundary-distance-from(
    placed-rod,
    applied-load.application-position,
    direction-away-from-rod,
    rod-style.stroke,
  )
  let arrow-tip-position = vector.point-along(
    applied-load.application-position,
    direction-away-from-rod,
    distance-to-visible-rod-border,
  )
  let arrow-tail-position = vector.point-along(
    arrow-tip-position,
    direction-away-from-rod,
    load-style.length,
  )
  render-force-arrow(
    arrow-tail-position,
    arrow-tip-position,
    load-style.color,
    load-style.stroke,
  )
  render-label(
    vector.point-along(
      arrow-tail-position,
      vector.reversed(applied-load.direction),
      0.26,
    ),
    text(fill: load-style.color, force-symbol),
    load-style.text,
  )
}

#let render-torque(placed-torque, diagram-style) = {
  let torque-style = resolve-force-style(
    diagram-style,
    placed-torque.style,
    "applied",
  )
  let turns-counterclockwise = (
    placed-torque.direction == "counterclockwise"
  )
  let start-angle = if turns-counterclockwise { -55deg } else { 235deg }
  let stop-angle = if turns-counterclockwise { 235deg } else { -55deg }
  arc(
    placed-torque.center,
    start: start-angle,
    stop: stop-angle,
    radius: placed-torque.radius,
    anchor: "origin",
    stroke: torque-style.stroke + torque-style.color,
    mark: (
      end: "stealth",
      fill: torque-style.color,
      scale: 0.5,
    ),
  )
  let torque-label = if placed-torque.label != auto {
    placed-torque.label
  } else {
    $tau$
  }
  render-label(
    vector.point-along(
      placed-torque.center,
      (0, 1),
      placed-torque.radius + 0.24,
    ),
    text(fill: torque-style.color, torque-label),
    torque-style.text,
  )
}

// A velocity leaves the body it belongs to, pointing the way it moves. It is
// drawn in its own colour because it is not a force and never belongs in a
// free-body diagram.
#let render-velocity(body, body-velocity, velocity-index, diagram-style) = {
  let motion-style = resolve-velocity-style(diagram-style, body-velocity.style)
  let body-style = resolve-body-style(diagram-style, body.style)
  let visible-boundary-distance = body-visible-boundary-distance(
    body,
    body-velocity.direction,
    body-style.stroke,
  )
  let arrow-tail-position = body.center
  let arrow-tip-position = vector.point-along(
    body.center,
    body-velocity.direction,
    visible-boundary-distance + motion-style.length,
  )
  render-force-arrow(
    arrow-tail-position,
    arrow-tip-position,
    motion-style.color,
    motion-style.stroke,
  )
  let velocity-symbol = if body-velocity.label != auto {
    body-velocity.label
  } else if velocity-index == 0 { $v$ } else { $v_#(velocity-index + 1)$ }
  render-label(
    vector.point-along(arrow-tip-position, body-velocity.direction, 0.28),
    text(fill: motion-style.color, velocity-symbol),
    motion-style.text,
  )
}

#let render-angular-velocity(
  body,
  body-angular-velocity,
  angular-velocity-index,
  diagram-style,
) = {
  let motion-style = resolve-velocity-style(
    diagram-style,
    body-angular-velocity.style,
  )
  arc(
    body.center,
    start: body-angular-velocity.start-angle,
    stop: body-angular-velocity.end-angle,
    radius: body-angular-velocity.radius,
    anchor: "origin",
    stroke: motion-style.stroke + motion-style.color,
    mark: (
      end: "stealth",
      fill: motion-style.color,
      scale: 0.5,
    ),
  )
  let angular-velocity-symbol = if body-angular-velocity.label != auto {
    body-angular-velocity.label
  } else if angular-velocity-index == 0 {
    $omega$
  } else {
    $omega_#(angular-velocity-index + 1)$
  }
  let label-angle = (
    body-angular-velocity.start-angle
      + body-angular-velocity.end-angle
  ) / 2
  render-label(
    vector.point-along(
      body.center,
      vector.direction-from-angle(label-angle),
      body-angular-velocity.radius + 0.24,
    ),
    text(fill: motion-style.color, angular-velocity-symbol),
    motion-style.text,
  )
}

// ── Scene-only annotations ───────────────────────────────────────────────────


#let bodies-named-by(scene, body-selection, argument-name: "forces") = {
  let named-bodies = if body-selection == none {
    ()
  } else if body-selection == true {
    scene.body-order
  } else if type(body-selection) == str {
    (body-selection,)
  } else {
    assert(
      type(body-selection) == array,
      message: (
        "typed-physics: "
          + argument-name
          + ": must be none, true, a body name, or an array of body names; got "
          + repr(body-selection)
      ),
    )
    body-selection
  }
  assert(
    named-bodies.all(body-name => type(body-name) == str),
    message: "typed-physics: " + argument-name + ": body selections must contain only string names",
  )
  assert(
    named-bodies.dedup().len() == named-bodies.len(),
    message: "typed-physics: " + argument-name + ": names the same body more than once; remove duplicate selections",
  )
  for body-name in named-bodies {
    assert(
      body-name in scene.bodies,
      message: "typed-physics: " + argument-name + ": names \"" + body-name + "\", which is not a body in this situation",
    )
  }
  named-bodies
}

// The forces on a body drawn where that body sits, rather than in a diagram of
// its own. Same enumeration, same lengths, so a scene annotated this way and a
// free-body diagram of the same body cannot show different arrows.
#let render-forces-on-body(
  scene,
  body,
  arrow-lengths,
  diagram-style,
  solution: none,
) = {
  let acting-forces = force-enumeration.enumerate-forces(
    scene,
    body.name,
    solution: solution,
  )
  for (force-index, acting-force) in acting-forces.enumerate() {
    let force-style = resolve-force-style(
      diagram-style,
      acting-force.style,
      acting-force.role,
    )
    let body-style = resolve-body-style(diagram-style, body.style)
    let visible-boundary-distance = body-visible-boundary-distance(
      body,
      acting-force.direction,
      body-style.stroke,
    )
    let arrow-tail-position = body.center
    let arrow-tip-position = vector.point-along(
      body.center,
      acting-force.direction,
      visible-boundary-distance + arrow-lengths.at(force-index),
    )
    render-force-arrow(
      arrow-tail-position,
      arrow-tip-position,
      force-style.color,
      force-style.stroke,
    )
    render-label(
      vector.point-along(arrow-tip-position, acting-force.direction, 0.28),
      text(fill: force-style.color, acting-force.symbol),
      force-style.text,
    )
  }
}

// ── Scene ────────────────────────────────────────────────────────────────────
