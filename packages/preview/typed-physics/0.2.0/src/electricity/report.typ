// Typesetting what a DC circuit settles to.
//
// The package states quantities; the argument around them is the author's to
// write. A quantity a circuit does not have is named and declined rather than
// answered with a number from somewhere else.

#import "../shared/expression.typ"

// What a circuit is asked for when the author does not say. A network that
// passes a current is read for the resistance it presents; one that does not is
// a capacitor network, and its capacitance is the question.
#let default-circuit-quantity(derived) = if derived.conducts {
  "resistance"
} else { "capacitance" }

// A component is asked for the voltage across it, which every component in
// every network has. Current is shared in a chain and voltage in a group, so
// neither is the more interesting answer everywhere.
#let default-component-quantity = "voltage"

#let _unavailable(reason) = panic("typed-physics: " + reason)

#let _circuit-quantity(derived, find) = {
  if find == "voltage" {
    return ($V$, derived.voltage, derived.units.voltage)
  }
  if find == "current" {
    if not derived.conducts {
      _unavailable(
        "this circuit passes no steady current, because a capacitor blocks "
          + "every path through it; every component still has a voltage, and "
          + "the network has a `capacitance`",
      )
    }
    return ($I$, derived.current, derived.units.current)
  }
  if find == "resistance" {
    if derived.resistance == none {
      _unavailable(
        "this circuit presents no resistance to a steady current, because a "
          + "capacitor blocks every path through it; ask for its `capacitance` "
          + "instead",
      )
    }
    return ($R_"eq"$, derived.resistance, derived.units.resistance)
  }
  if derived.capacitance == none {
    if derived.units.capacitance == none {
      _unavailable("this circuit declares no capacitors")
    }
    _unavailable(
      "this circuit holds resistors as well as capacitors, so no single "
        + "capacitance stands for the whole of it; in the steady state each "
        + "capacitor settles at its own voltage, which it can be asked for by "
        + "name",
    )
  }
  ($C_"eq"$, derived.capacitance, derived.units.capacitance)
}

#let _component-quantity(derived, component-name, find) = {
  let component = derived.components.at(component-name)
  if find == "voltage" {
    return (
      $V_#component-name$,
      (
        expression: component.voltage,
        value: expression.value-of(component.voltage),
      ),
      derived.units.voltage,
    )
  }
  if find == "current" {
    return (
      $I_#component-name$,
      (
        expression: component.current,
        value: expression.value-of(component.current),
      ),
      derived.units.current,
    )
  }
  let declared-kind = if find == "resistance" { "resistor" } else {
    "capacitor"
  }
  if component.component-kind != declared-kind {
    _unavailable(
      "\""
        + component-name
        + "\" is a "
        + component.component-kind
        + ", so it has no "
        + find
        + "; ask it for its `voltage` or its `current`",
    )
  }
  (
    $#component-name$,
    (
      expression: component.declared,
      value: expression.value-of(component.declared),
    ),
    if find == "resistance" { derived.units.resistance } else {
      derived.units.capacitance
    },
  )
}

#let typeset-quantity(derived, component-name, find) = {
  let (symbol, quantity, unit) = if component-name == none {
    _circuit-quantity(derived, find)
  } else {
    _component-quantity(derived, component-name, find)
  }
  expression.stated-value(symbol, quantity.expression, unit: unit)
}

#let _column-heading(title, unit) = if unit == none { [#title] } else {
  [#title (#unit)]
}

#let _stated-number(term) = {
  let evaluated-value = expression.value-of(term)
  if evaluated-value == none { return [—] }
  [#expression.format-number(evaluated-value)]
}

// Every component with what it was declared as and what it settles to. The
// bookkeeping behind the derivation, in the order the components were declared.
#let typeset-component-table(derived) = {
  let component-row(component-name) = {
    let component = derived.components.at(component-name)
    (
      [#component-name],
      _stated-number(component.declared),
      _stated-number(component.voltage),
      _stated-number(component.current),
    )
  }
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [Component],
      [Declared],
      _column-heading("Voltage", derived.units.voltage),
      _column-heading("Current", derived.units.current),
    ),
    table.hline(),
    ..derived.component-order.map(component-row).flatten(),
    table.hline(),
  )
}
