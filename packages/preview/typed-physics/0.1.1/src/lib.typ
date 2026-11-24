// typed-physics — declare a mechanics situation once and derive everything
// else from it.
//
// `situation(...)` takes the problem statement as elements that read like the
// sentence they came from and resolves them into geometry. Every view is a
// function taking that situation first: the scene, a free-body diagram of any
// body, the weight resolved into the surface's axes, and the solution. They
// cannot disagree with each other, because there is only one situation
// underneath.

#import "@preview/cetz:0.5.2"
#import "mechanics/placement/lib.typ" as placement
#import "mechanics/render/lib.typ" as scene-rendering
#import "mechanics/fbd.typ" as free-body-rendering
#import "mechanics/solver.typ"
#import "mechanics/models.typ"
#import "mechanics/report.typ"
#import "mechanics/forces.typ" as force-enumeration
#import "mechanics/annotations.typ": dimension
#import "mechanics/validation/lib.typ" as validation
#import "electricity/lib.typ" as electricity

#import "mechanics/elements.typ": (
  angular-velocity, arc, ball, block, ceiling, disk, force, ground, pendulum,
  pivot, point-mass, pulley, ramp, ring, rod, rope, spring, support, torque,
  velocity, wall,
)
#import "mechanics/style.typ": (
  block-style, connector-style, force-style, resolve-body-style, resolve-style,
  scaled-diagram, surface-style, theme,
)

#let situation(..declarations, gravity: 9.81, style: (:)) = {
  let validated-style = resolve-style(style)
  placement.resolve-situation-geometry(
    declarations.pos(),
    gravity: gravity,
  ) + (
    style: style,
    validation-kind: "typed-physics-situation",
  )
}

#let _validate-situation(s, public-function) = {
  assert(
    type(s) == dictionary
      and s.at("validation-kind", default: none)
        == "typed-physics-situation",
    message: (
      "typed-physics: "
        + public-function
        + " needs the value returned by situation() as its first argument"
    ),
  )
  let required-fields = (
    "gravity", "surfaces", "bodies", "pulleys", "structures", "torques",
    "connectors", "surface-order", "body-order", "structure-order", "span",
    "style",
  )
  let missing-fields = required-fields.filter(field => field not in s)
  assert(
    missing-fields.len() == 0,
    message: (
      "typed-physics: "
        + public-function
        + " received a malformed situation missing "
        + missing-fields.join(", ")
        + "; pass the unchanged value returned by situation()"
    ),
  )
}

// A situation's own style is the floor every view builds on; a view's overrides
// are merged over it and apply to that view alone.
#let _view-style(s, view-style, public-function: "view") = {
  _validate-situation(s, public-function)
  validation.validate-style-dictionary(view-style, public-function)
  resolve-style(s.style + view-style)
}

#let _canvas(diagram-style, canvas-elements) = scaled-diagram(
  diagram-style,
  cetz.canvas(canvas-elements),
)

// A situation with one body needs no name; naming it is how a situation with
// several says which one it means.
#let _chosen-body(s, arguments, public-function) = {
  let positional-body-names = arguments.pos()
  assert(
    arguments.named().len() == 0,
    message: (
      "typed-physics: "
        + public-function
        + " has unknown named argument"
        + if arguments.named().len() == 1 { " " } else { "s " }
        + arguments.named().keys().map(key => "`" + key + ":`").join(", ")
        + "; pass the body name positionally"
    ),
  )
  assert(
    positional-body-names.len() <= 1,
    message: "typed-physics: this view takes at most one positional argument, the name of a body",
  )
  if positional-body-names.len() == 1 {
    let body-name = positional-body-names.first()
    validation.validate-body-name(s, body-name, public-function)
    body-name
  } else {
    auto
  }
}

#let _solved-body(s, name, assume) = solver.solve-situation(
  s,
  body: name,
  assume: assume,
)

// ── Figures ──────────────────────────────────────────────────────────────────

// A body whose forces are drawn in place is solved the same way it would be in
// a diagram of its own, so the arrows agree with `fbd` and with `solve`.
#let _solution-for-arrows(s, body-name) = {
  if not solver.body-can-be-balanced(s, body-name) { return none }
  let solution = solver.solve-body(s, body-name)
  if solution.status == "solved" { solution } else { none }
}

#let _weight-arrow-distance-from-body-center(
  s,
  body-name,
  arrow-lengths,
  solution,
  diagram-style,
) = {
  let acting-forces = force-enumeration.enumerate-forces(
    s,
    body-name,
    solution: solution,
  )
  let weight-force-index = acting-forces.position(
    acting-force => acting-force.role == "weight",
  )
  assert(
    weight-force-index != none,
    message: "typed-physics: components: body \"" + body-name + "\" needs a `mass:` before its weight can be resolved",
  )
  let weight-force = acting-forces.at(weight-force-index)
  let body = s.bodies.at(body-name)
  let body-style = resolve-body-style(diagram-style, body.style)
  scene-rendering.body-visible-boundary-distance(
    body,
    weight-force.direction,
    body-style.stroke,
  ) + arrow-lengths.at(weight-force-index)
}

#let _validate-weight-components(s, body-name, public-function) = {
  validation.validate-body-name(s, body-name, public-function)
  let body = s.bodies.at(body-name)
  assert(
    body.mass != none,
    message: (
      "typed-physics: "
        + public-function
        + " needs body \""
        + body-name
        + "\" to declare `mass:` before its weight can be resolved"
    ),
  )
  assert(
    body.support != none,
    message: (
      "typed-physics: "
        + public-function
        + " cannot resolve weight for body \""
        + body-name
        + "\" because it has no supporting surface frame; use a body placed with `on:`/`touching:`"
    ),
  )
}

#let draw(
  s,
  labels: "name",
  angles: "value",
  loads: true,
  frictions: false,
  lengths: false,
  dimensions: (),
  forces: none,
  components: none,
  style: (:),
) = {
  _validate-situation(s, "draw()")
  validation.validate-boolean(loads, "draw()", "loads")
  validation.validate-boolean(frictions, "draw()", "frictions")
  validation.validate-boolean(lengths, "draw()", "lengths")
  let diagram-style = _view-style(s, style, public-function: "draw()")
  let bodies-showing-forces = scene-rendering.bodies-named-by(s, forces)
  let bodies-showing-components = scene-rendering.bodies-named-by(
    s,
    components,
    argument-name: "components",
  )
  let solutions = (:)
  let arrow-lengths = (:)
  for body-name in bodies-showing-forces {
    let solution = _solution-for-arrows(s, body-name)
    solutions.insert(body-name, solution)
    arrow-lengths.insert(
      body-name,
      free-body-rendering.force-arrow-lengths(
        force-enumeration.enumerate-forces(s, body-name, solution: solution),
        diagram-style,
      ),
    )
  }
  for body-name in bodies-showing-components {
    _validate-weight-components(s, body-name, "draw(components:)")
  }
  scene-rendering.render-scene(
    s,
    diagram-style,
    labels: labels,
    angles: angles,
    loads: loads,
    frictions: frictions,
    lengths: lengths,
    dimensions: dimensions,
    forces: forces,
    force-arrow-lengths: arrow-lengths,
    solutions: solutions,
  )
  for body-name in bodies-showing-components {
    let forces-already-show-weight = bodies-showing-forces.contains(body-name)
    let component-weight-arrow-length = if forces-already-show-weight {
      _weight-arrow-distance-from-body-center(
        s,
        body-name,
        arrow-lengths.at(body-name),
        solutions.at(body-name),
        diagram-style,
      )
    } else {
      auto
    }
    free-body-rendering.render-component-decomposition-on-body(
      s,
      body-name,
      diagram-style,
      weight-arrow-length: component-weight-arrow-length,
      should-render-weight-arrow: not forces-already-show-weight,
    )
  }
}

#let scene(
  s,
  ..unexpected-arguments,
  labels: "name",
  angles: "value",
  loads: true,
  frictions: false,
  lengths: false,
  dimensions: (),
  forces: none,
  components: none,
  style: (:),
) = {
  _validate-situation(s, "scene()")
  assert(
    unexpected-arguments.pos().len() == 0,
    message: "typed-physics: scene() takes no positional arguments after the situation",
  )
  assert(
    unexpected-arguments.named().len() == 0,
    message: (
      "typed-physics: scene() has unknown argument"
        + if unexpected-arguments.named().len() == 1 { " " } else { "s " }
        + unexpected-arguments.named().keys().map(
          argument-name => "`" + argument-name + ":`",
        ).join(", ")
        + "; accepted arguments are labels, angles, loads, frictions, lengths, dimensions, forces, components, style"
    ),
  )
  let diagram-style = _view-style(
    s,
    style,
    public-function: "scene()",
  )
  _canvas(
    diagram-style,
    draw(
      s,
      labels: labels,
      angles: angles,
      loads: loads,
      frictions: frictions,
      lengths: lengths,
      dimensions: dimensions,
      forces: forces,
      components: components,
      style: style,
    ),
  )
}

#let fbd(s, name, axes: auto, outline: true, solve: true, style: (:)) = {
  _validate-situation(s, "fbd()")
  validation.validate-body-name(s, name, "fbd()")
  validation.validate-boolean(axes, "fbd()", "axes", allow-auto: true)
  validation.validate-boolean(outline, "fbd()", "outline")
  validation.validate-boolean(solve, "fbd()", "solve")
  let diagram-style = _view-style(s, style, public-function: "fbd()")
  _canvas(
    diagram-style,
    free-body-rendering.render-free-body-diagram(
      s,
      name,
      diagram-style,
      solution: if solve { _solution-for-arrows(s, name) } else { none },
      axes: axes,
      outline: outline,
    ),
  )
}

#let components(s, name, of: "weight", style: (:)) = {
  _validate-situation(s, "components()")
  _validate-weight-components(s, name, "components()")
  validation.validate-enum(of, ("weight",), "components()", "of")
  let diagram-style = _view-style(s, style, public-function: "components()")
  _canvas(
    diagram-style,
    free-body-rendering.render-component-decomposition(s, name, diagram-style, of: of),
  )
}

// ── Answers ──────────────────────────────────────────────────────────────────

#let solve(s, ..name, find: auto, direction: true, assume: auto) = {
  _validate-situation(s, "solve()")
  validation.validate-enum(
    find,
    (auto, "acceleration", "normal", "friction", "regime", "tension"),
    "solve()",
    "find",
  )
  validation.validate-boolean(direction, "solve()", "direction")
  validation.validate-enum(
    assume,
    (auto, "static", "sliding"),
    "solve()",
    "assume",
  )
  report.typeset-answer(
    s,
    _solved-body(s, _chosen-body(s, name, "solve()"), assume),
    find: find,
    direction: direction,
  )
}

// Which body a view means when the situation has more than one. Views that
// enumerate rather than answer still need to pick a body, and they must do it
// without asking whether that body can be solved.
#let _named-or-only-body(s, arguments, public-function) = {
  let chosen-body-name = _chosen-body(s, arguments, public-function)
  if chosen-body-name != auto { return chosen-body-name }
  let body-names = s.body-order
  assert(
    body-names.len() > 0,
    message: "typed-physics: this situation has no bodies",
  )
  assert(
    body-names.len() == 1,
    message: (
      "typed-physics: "
        + public-function
        + " describes one body at a time; this situation has "
        + str(body-names.len())
        + " ("
        + body-names.join(", ")
        + ") — pass the body name positionally, for example `"
        + public-function.replace("()", "")
        + "(s, \""
        + body-names.first()
        + "\")`"
    ),
  )
  body-names.first()
}

// The forces on a body are enumerated from its declaration, so the table stands
// whether or not a model was able to fill in the magnitudes.
#let force-table(s, ..name, assume: auto) = {
  _validate-situation(s, "force-table()")
  validation.validate-enum(
    assume,
    (auto, "static", "sliding"),
    "force-table()",
    "assume",
  )
  let body-name = _named-or-only-body(s, name, "force-table()")
  let solution = if solver.body-can-be-balanced(s, body-name) {
    solver.solve-body(s, body-name, assume: assume)
  } else {
    none
  }
  report.typeset-force-table(
    s,
    body-name,
    solution: if solution != none and solution.status == "solved" {
      solution
    } else { none },
  )
}

// ── Scope ────────────────────────────────────────────────────────────────────

// Which model a body falls under, or `none`. An author can ask before writing
// `solve()`, and a document can branch on the answer instead of on an error.
#let model-of(s, ..name) = {
  _validate-situation(s, "model-of()")
  models.recognize-model(s, _named-or-only-body(s, name, "model-of()")).id
}

// Every model this release solves, as plain data, so a document can list the
// scope rather than restate it.
#let solved-models() = models.solved-models

#let results(s, ..name, assume: auto) = {
  _validate-situation(s, "results()")
  validation.validate-enum(
    assume,
    (auto, "static", "sliding"),
    "results()",
    "assume",
  )
  _solved-body(s, _chosen-body(s, name, "results()"), assume)
}

#let forces(s, name) = {
  _validate-situation(s, "forces()")
  validation.validate-body-name(s, name, "forces()")
  force-enumeration.enumerate-forces(s, name)
}
