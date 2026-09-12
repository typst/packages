// Typesetting a quantity a model determined.
//
// The package states quantities; the argument around them is the author's to
// write. Nothing here composes a sentence that a document in another language
// would have to fight.

#import "../shared/expression.typ"
#import "forces.typ" as force-enumeration
#import "models.typ"

#let newtons = $"N"$
#let metres-per-second-squared = $"m/s"^2$

#let _typeset-stated-value = expression.stated-value

// Where the body goes, said the way the figure reads: a slope has an uphill and
// a downhill, a wall has an up and a down, and level ground only has a left and
// a right. Written in English, so `direction: false` is how a document in
// another language leaves it out.
#let _motion-direction-words(scene, solution) = {
  let support-surface = scene.surfaces.at(solution.surface)
  let motion-is-vertical = (
    calc.abs(solution.motion.at(1)) > calc.abs(solution.motion.at(0))
  )
  if support-surface.kind == "ramp" {
    if solution.downhill { "down the incline" } else { "up the incline" }
  } else if motion-is-vertical {
    if solution.motion.at(1) < 0 {
      "down the " + support-surface.kind
    } else { "up the " + support-surface.kind }
  } else if solution.motion.at(0) >= 0 { "to the right" } else { "to the left" }
}

// What a problem asks for when it does not say. A body that stays put has
// already answered the interesting question with its regime, and a hanging body
// was only ever asked one thing.
#let _quantity-asked-for(solution) = {
  if solution.model == "hanging-body" { return "tension" }
  if solution.regime == "static" { "regime" } else { "acceleration" }
}

// A model determines the quantities it was written to determine, and asking it
// for another is answered with the list rather than with a number from
// somewhere else.
#let _validate-requested-quantity(solution, asked-for) = {
  let matched-model = models.model-named(solution.model)
  assert(
    asked-for in matched-model.asks,
    message: (
      "typed-physics: solve(find: "
        + repr(asked-for)
        + ") asks for a quantity the "
        + solution.model
        + " model does not determine; \""
        + solution.body
        + "\" matched that model, which gives "
        + matched-model.asks.map(quantity => repr(quantity)).join(", ")
    ),
  )
}

#let _typeset-hanging-answer(solution) = _typeset-stated-value(
  $T$,
  solution.tension.expression,
  unit: newtons,
)

#let typeset-answer(scene, solution, find: auto, direction: true) = {
  let solution-is-undetermined = solution.status == "undetermined"
  let asked-for = if find == auto {
    if solution-is-undetermined { "regime" } else {
      _quantity-asked-for(solution)
    }
  } else { find }
  _validate-requested-quantity(solution, asked-for)

  if solution.model == "hanging-body" { return _typeset-hanging-answer(solution) }

  // The normal force falls out of the balance across the surface, which does
  // not depend on which way the body is about to go.
  if asked-for == "normal" {
    return _typeset-stated-value($N$, solution.normal.expression, unit: newtons)
  }

  if solution-is-undetermined {
    return [
      typed-physics cannot decide whether *#solution.body* slides, because #solution.reason. Give the coefficients and masses
      as numbers, or state the regime with `assume:`.
    ]
  }

  if asked-for == "regime" { return solution.regime }

  if asked-for == "friction" {
    let friction-symbol = if not solution.rough {
      $f$
    } else if solution.regime == "static" { $f_s$ } else { $f_k$ }
    return _typeset-stated-value(
      friction-symbol,
      solution.friction.expression,
      unit: newtons,
    )
  }

  let stated-acceleration = _typeset-stated-value(
    $a$,
    solution.acceleration.expression,
    unit: metres-per-second-squared,
  )
  if solution.regime == "static" or not direction {
    return stated-acceleration
  }
  [#stated-acceleration, #_motion-direction-words(scene, solution)]
}

// Every force on a body with its components in the axes the body is balanced
// in: the surface's own for a body resting on one, and the world's for a body
// hanging from something. The bookkeeping behind the free-body diagram, in the
// order the diagram draws it, and available whether or not a model gave the
// magnitudes.
#let typeset-force-table(scene, name, solution: none) = {
  let body = scene.bodies.at(name)
  let acting-forces = force-enumeration.enumerate-forces(
    scene,
    name,
    solution: solution,
  )
  let body-rests-on-a-surface = body.support != none
  let first-axis = if body-rests-on-a-surface { body.direction } else { (1, 0) }
  let second-axis = if body-rests-on-a-surface { body.outward-normal } else {
    (0, 1)
  }
  let force-component-cell(force, axis-direction) = {
    if force.magnitude == none { return [—] }
    let force-magnitude = expression.value-of(force.magnitude)
    if force-magnitude == none { return [—] }
    let signed-component = force-magnitude * (
      force.direction.at(0) * axis-direction.at(0)
        + force.direction.at(1) * axis-direction.at(1)
    )
    [#expression.format-number(signed-component)]
  }
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [Force],
      [Magnitude (N)],
      if body-rests-on-a-surface { [Along] } else { [Horizontal] },
      if body-rests-on-a-surface { [Out of surface] } else { [Vertical] },
    ),
    table.hline(),
    ..acting-forces
      .map(force => (
        force.symbol,
        if force.magnitude == none { [—] } else {
          let force-magnitude = expression.value-of(force.magnitude)
          if force-magnitude == none {
            [—]
          } else {
            [#expression.format-number(force-magnitude)]
          }
        },
        force-component-cell(force, first-axis),
        force-component-cell(force, second-axis),
      ))
      .flatten(),
    table.hline(),
  )
}
