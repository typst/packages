// What a DC circuit settles to.
//
// A series/parallel network reduces: series resistances add, parallel
// resistances add as reciprocals, and capacitances do the opposite. The
// declaration is already that tree, so nothing here has to discover a topology
// the author did not write, and reduction is total over everything `series` and
// `parallel` can compose. There is no model to match, because there is no
// network in this grammar that reduction cannot finish.
//
// One physical decision is made rather than assumed. In the steady state a
// capacitor carries no current, so a chain a capacitor sits in carries none
// either, and the voltage that chain does not drop across its resistors stands
// across its capacitors instead. Every quantity here is the steady state, and
// the result says so rather than leaving a reader to guess when it holds.
//
// A `unit:` is display text on a declaration and the number beside it is
// measured in that unit, so quantities may only be combined across components
// declared alike, and a current is only named in amperes when the resistances
// are in ohms and the source in volts.

#import "../expression.typ"

// A declared value as an expression. A component with no value still has a
// name, and carrying it as a symbol is what lets a circuit be reduced in closed
// form before any number is chosen.
#let _declared-quantity(value, symbol) = {
  if value == none { return expression.quantity(symbol) }
  expression.declared(value, symbol)
}

// A component prints as the name the figure labels it with, so an equation and
// the diagram it came from name the same thing.
#let component-symbol(component) = $#component.name$

#let _resistance-of(component) = _declared-quantity(
  component.resistance,
  component-symbol(component),
)

#let _capacitance-of(component) = _declared-quantity(
  component.capacitance,
  component-symbol(component),
)

// The combination that adds as reciprocals: resistances in parallel, and
// capacitances in series. Written as the product of the parts over the sum of
// what each one leaves out, which is `R_1 R_2 slash (R_1 + R_2)` for the pair a
// reader expects and extends to any number of them. A sum of reciprocals would
// say the same thing while carrying a literal one into every equation built on
// it.
#let _combined-inversely(terms) = {
  if terms.len() == 1 { return terms.first() }
  let complementary-products = ()
  for index in range(0, terms.len()) {
    complementary-products.push(
      expression.product(..terms.slice(0, index), ..terms.slice(index + 1)),
    )
  }
  expression.ratio(
    expression.product(..terms),
    expression.sum(..complementary-products.rev()),
  )
}

// Whether a steady current can pass. A capacitor blocks, a chain passes only if
// every part of it does, and a group passes if any branch does.
#let conducts(network) = {
  if network.kind == "component" {
    return network.component-kind == "resistor"
  }
  if network.kind == "series" { return network.branches.all(conducts) }
  network.branches.any(conducts)
}

// The resistance a steady current would meet, or `none` where no steady current
// passes at all.
#let network-resistance(network) = {
  if network.kind == "component" {
    if network.component-kind != "resistor" { return none }
    return _resistance-of(network)
  }
  if network.kind == "series" {
    let branch-resistances = ()
    for branch in network.branches {
      let branch-resistance = network-resistance(branch)
      if branch-resistance == none { return none }
      branch-resistances.push(branch-resistance)
    }
    return expression.sum(..branch-resistances)
  }
  let conducting-resistances = network.branches
    .map(network-resistance)
    .filter(branch-resistance => branch-resistance != none)
  if conducting-resistances.len() == 0 { return none }
  _combined-inversely(conducting-resistances)
}

// The capacitance of a network carrying no current, or `none` where it holds no
// charge. A resistor with no current across it drops no voltage, so it joins
// its chain as a connection rather than as a capacitance.
#let network-capacitance(network) = {
  if network.kind == "component" {
    if network.component-kind != "capacitor" { return none }
    return _capacitance-of(network)
  }
  let branch-capacitances = network.branches
    .map(network-capacitance)
    .filter(branch-capacitance => branch-capacitance != none)
  if branch-capacitances.len() == 0 { return none }
  if network.kind == "series" { return _combined-inversely(branch-capacitances) }
  expression.sum(..branch-capacitances)
}

#let _contains-component-kind(network, component-kind) = {
  if network.kind == "component" {
    return network.component-kind == component-kind
  }
  network.branches.any(branch => _contains-component-kind(
    branch,
    component-kind,
  ))
}

#let _merged(dictionaries) = {
  let combined = (:)
  for dictionary in dictionaries { combined += dictionary }
  combined
}

// Every component's own voltage and current, given what stands across the
// network it belongs to and what passes through it.
#let _distribute(network, voltage-across, current-through) = {
  if network.kind == "component" {
    if network.component-kind == "resistor" {
      let resistance = _resistance-of(network)
      return (
        (network.name): (
          component-kind: "resistor",
          declared: resistance,
          voltage: expression.product(current-through, resistance),
          current: current-through,
        ),
      )
    }
    return (
      (network.name): (
        component-kind: "capacitor",
        declared: _capacitance-of(network),
        voltage: voltage-across,
        current: expression.number(0),
      ),
    )
  }

  if network.kind == "parallel" {
    // One voltage stands across every branch, and each branch draws the current
    // its own resistance allows.
    return _merged(network.branches.map(branch => {
      let branch-resistance = network-resistance(branch)
      let branch-current = if branch-resistance == none {
        expression.number(0)
      } else {
        expression.ratio(voltage-across, branch-resistance)
      }
      _distribute(branch, voltage-across, branch-current)
    }))
  }

  let chain-resistance = network-resistance(network)
  if chain-resistance != none {
    // One current passes through every part of the chain, and each part drops
    // the voltage its own resistance calls for.
    return _merged(network.branches.map(branch => _distribute(
      branch,
      expression.product(current-through, network-resistance(branch)),
      current-through,
    )))
  }

  // No current passes, so the resistors in the chain drop nothing and the whole
  // voltage divides between its capacitors, which all hold the same charge.
  // That charge stands as its own symbol so each capacitor reads `Q slash C`
  // rather than repeating the reduction that produced it.
  let chain-charge = expression.quantity(
    $Q$,
    value: expression.value-of(
      expression.product(network-capacitance(network), voltage-across),
    ),
  )
  _merged(network.branches.map(branch => {
    let branch-capacitance = network-capacitance(branch)
    let branch-voltage = if branch-capacitance == none {
      expression.number(0)
    } else {
      expression.ratio(chain-charge, branch-capacitance)
    }
    _distribute(branch, branch-voltage, expression.number(0))
  }))
}

#let _resolved-unit(component) = {
  if component.unit != auto { return component.unit }
  if component.component-kind == "resistor" { return "Ω" }
  if component.component-kind == "capacitor" { return "F" }
  "V"
}

// The one unit a family of components was declared in. Series and parallel
// combination scales with its inputs, so an equivalent is stated in the same
// unit as the parts — but only when the parts agree, because adding a number of
// kilohms to a number of ohms is adding two different things.
#let _family-unit(circuit, component-kind, public-function) = {
  let family = circuit.components.filter(
    component => component.component-kind == component-kind,
  )
  if family.len() == 0 { return none }
  let declared-units = ()
  for component in family {
    let component-unit = _resolved-unit(component)
    if component-unit not in declared-units {
      declared-units.push(component-unit)
    }
  }
  assert(
    declared-units.len() == 1,
    message: (
      "typed-physics: electricity."
        + public-function
        + " cannot combine "
        + component-kind
        + "s declared in different units ("
        + declared-units.map(repr).join(", ")
        + "); a value is measured in the unit beside it, so give every "
        + component-kind
        + " in this circuit the same `unit:`"
    ),
  )
  declared-units.first()
}

#let _value-and-expression(term) = if term == none { none } else {
  (expression: term, value: expression.value-of(term))
}

// Everything the circuit settles to. A plain dictionary, so a caller can
// typeset it, tabulate it, or read one number out of it.
#let dc-steady-state(circuit, public-function: "results()") = {
  let resistance-unit = _family-unit(circuit, "resistor", public-function)
  let capacitance-unit = _family-unit(circuit, "capacitor", public-function)
  let voltage-unit = _resolved-unit(circuit.source)

  let source-voltage = _declared-quantity(
    circuit.source.voltage,
    component-symbol(circuit.source),
  )
  let load = circuit.network
  let total-resistance = network-resistance(load)
  let load-conducts = total-resistance != none
  let source-current = if load-conducts {
    expression.ratio(source-voltage, total-resistance)
  } else {
    expression.number(0)
  }
  // Downstream, the current the source drives is a symbol rather than the
  // reduction that found it, so a resistor in the chain reads `I R` the way it
  // would be written by hand.
  let current-through-the-chain = if load-conducts {
    expression.quantity($I$, value: expression.value-of(source-current))
  } else {
    expression.number(0)
  }

  // An equivalent capacitance describes a network of capacitors. A network that
  // also holds resistors settles to a state where each capacitor stands at its
  // own voltage, and no single capacitance stands for the whole of it.
  let load-holds-resistors = _contains-component-kind(load, "resistor")
  let total-capacitance = if load-holds-resistors { none } else {
    network-capacitance(load)
  }

  (
    // Charging has finished: capacitors carry no current and hold a steady
    // charge. Nothing here describes the transient that led to it.
    regime: "dc-steady-state",
    conducts: load-conducts,
    units: (
      resistance: resistance-unit,
      capacitance: capacitance-unit,
      voltage: voltage-unit,
      // A current is amperes only when a volt is divided by an ohm.
      current: if (
        voltage-unit == "V"
          and (resistance-unit == none or resistance-unit == "Ω")
      ) { "A" } else { none },
    ),
    voltage: _value-and-expression(source-voltage),
    resistance: _value-and-expression(total-resistance),
    capacitance: _value-and-expression(total-capacitance),
    current: _value-and-expression(source-current),
    components: (
      (circuit.source.name): (
        component-kind: "voltage-source",
        declared: source-voltage,
        voltage: source-voltage,
        current: source-current,
      ),
    ) + _distribute(load, source-voltage, current-through-the-chain),
    component-order: circuit.components.map(component => component.name),
  )
}
