// Public electricity namespace: semantic DC declarations and drawing views.

#import "@preview/cetz:0.5.2"
#import "../validation-core.typ" as validation
#import "declarations.typ": (
  capacitor, dc-circuit, parallel, resistor, series, validate-circuit,
  voltage-source,
)
#import "derivation.typ"
#import "layout.typ" as placement
#import "render.typ"
#import "report.typ"
#import "style.typ": (
  capacitor-style, resistor-style, resolve-style, scaled-diagram, theme,
  voltage-source-style,
)

#let _resolved-view-style(circuit, overrides) = {
  resolve-style(circuit.style + overrides)
}

#let draw(
  circuit,
  labels: "both",
  fold: auto,
  style: (:),
) = {
  validate-circuit(circuit, "draw()")
  validation.validate-enum(
    labels,
    ("name", "value", "both", "none"),
    "electricity.draw()",
    "labels",
  )
  validation.validate-boolean(
    fold,
    "electricity.draw()",
    "fold",
    allow-auto: true,
  )
  let diagram-style = _resolved-view-style(circuit, style)
  let placed-circuit = placement.circuit-layout(
    circuit,
    diagram-style,
    fold: fold,
  )
  render.render-circuit(
    placed-circuit,
    diagram-style,
    labels: labels,
  )
}

#let diagram(
  circuit,
  labels: "both",
  fold: auto,
  style: (:),
) = {
  validate-circuit(circuit, "diagram()")
  let diagram-style = _resolved-view-style(circuit, style)
  scaled-diagram(
    diagram-style,
    cetz.canvas(draw(circuit, labels: labels, fold: fold, style: style)),
  )
}

// ── Answers ──────────────────────────────────────────────────────────────────
//
// Reduction is total over every network `series` and `parallel` can compose, so
// these views never decline a circuit. They decline a quantity a circuit does
// not have, which is a different thing and is always said by name.

// The component a view means. A circuit is asked about as a whole unless one of
// its components is named.
#let _chosen-component(circuit, arguments, public-function) = {
  assert(
    arguments.named().len() == 0,
    message: (
      "typed-physics: electricity."
        + public-function
        + " has unknown named argument"
        + if arguments.named().len() == 1 { " " } else { "s " }
        + arguments.named().keys().map(key => "`" + key + ":`").join(", ")
        + "; pass the component name positionally"
    ),
  )
  let positional-names = arguments.pos()
  assert(
    positional-names.len() <= 1,
    message: (
      "typed-physics: electricity."
        + public-function
        + " takes at most one positional argument, the name of a component"
    ),
  )
  if positional-names.len() == 0 { return none }
  let component-name = positional-names.first()
  let declared-names = circuit.components.map(component => component.name)
  assert(
    type(component-name) == str and component-name in declared-names,
    message: (
      "typed-physics: electricity."
        + public-function
        + " names component "
        + repr(component-name)
        + ", which this circuit does not declare; its components are "
        + declared-names.join(", ")
    ),
  )
  component-name
}

// One quantity, typeset. `find: auto` asks a circuit for the resistance it
// presents, or for its capacitance when no steady current passes, and asks a
// named component for the voltage across it.
#let solve(circuit, ..name, find: auto) = {
  validate-circuit(circuit, "solve()")
  validation.validate-enum(
    find,
    (auto, "resistance", "capacitance", "voltage", "current"),
    "electricity.solve()",
    "find",
  )
  let component-name = _chosen-component(circuit, name, "solve()")
  let derived = derivation.dc-steady-state(circuit, public-function: "solve()")
  let asked-for = if find != auto {
    find
  } else if component-name == none {
    report.default-circuit-quantity(derived)
  } else {
    report.default-component-quantity
  }
  report.typeset-quantity(derived, component-name, asked-for)
}

// Everything the circuit settles to, as plain data.
#let results(circuit) = {
  validate-circuit(circuit, "results()")
  derivation.dc-steady-state(circuit, public-function: "results()")
}

// Every component with what it was declared as and what it settles to.
#let component-table(circuit) = {
  validate-circuit(circuit, "component-table()")
  report.typeset-component-table(
    derivation.dc-steady-state(circuit, public-function: "component-table()"),
  )
}
