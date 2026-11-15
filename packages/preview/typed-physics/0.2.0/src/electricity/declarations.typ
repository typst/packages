// Electrical declarations describe connectivity and physical quantities without
// choosing coordinates. Layout and rendering consume this two-terminal tree.

#import "../shared/validation-core.typ" as validation
#import "style.typ" as styles

#let _network-validation-kind = "typed-physics-electrical-network"
#let _circuit-validation-kind = "typed-physics-dc-circuit"

#let _validate-network(network, source-description) = {
  assert(
    type(network) == dictionary
      and network.at("validation-kind", default: none)
        == _network-validation-kind,
    message: (
      "typed-physics: "
        + source-description
        + " needs a resistor, capacitor, series(...), or parallel(...) declaration"
    ),
  )
  none
}

// A branch of a parallel network travels between the split and join nodes
// either along its own horizontal baseline or around one side of the frame.
#let _validate-route(route, source-description) = {
  validation.validate-enum(
    route,
    (auto, "direct", "over", "under"),
    source-description,
    "route",
  )
  route
}

#let _validate-component-style(
  component-style,
  source-description,
  component-kind,
) = {
  styles.validate-component-style(
    component-style,
    source-description,
    component-kind,
  )
}

#let _validate-unit(unit, source-description) = {
  assert(
    unit == auto
      or unit == none
      or type(unit) in (str, content),
    message: (
      "typed-physics: "
        + source-description
        + " `unit:` must be auto, none, a non-empty string, or content such as $mu Omega$"
    ),
  )
  assert(
    type(unit) != str or unit.len() > 0,
    message: (
      "typed-physics: "
        + source-description
        + " `unit:` cannot be an empty string; use auto for the default unit or none to hide it"
    ),
  )
  unit
}

#let resistor(
  name,
  resistance: none,
  unit: auto,
  label: auto,
  route: auto,
  style: (:),
) = {
  validation.validate-name(name, source-description: "electricity.resistor()")
  validation.validate-physical-scalar(
    resistance,
    "electricity.resistor(\"" + name + "\")",
    "resistance",
    allow-none: true,
  )
  assert(
    label == auto or label == none or type(label) in (str, content),
    message: (
      "typed-physics: electricity.resistor(\""
        + name
        + "\") `label:` must be auto, none, a string, or content"
    ),
  )
  (
    validation-kind: _network-validation-kind,
    kind: "component",
    component-kind: "resistor",
    name: name,
    resistance: resistance,
    route: _validate-route(
      route,
      "electricity.resistor(\"" + name + "\")",
    ),
    unit: _validate-unit(
      unit,
      "electricity.resistor(\"" + name + "\")",
    ),
    label: label,
    style: _validate-component-style(
      style,
      "electricity resistor \"" + name + "\"",
      "resistor",
    ),
  )
}

#let capacitor(
  name,
  capacitance: none,
  unit: auto,
  label: auto,
  route: auto,
  style: (:),
) = {
  validation.validate-name(
    name,
    source-description: "electricity.capacitor()",
  )
  validation.validate-physical-scalar(
    capacitance,
    "electricity.capacitor(\"" + name + "\")",
    "capacitance",
    allow-none: true,
  )
  assert(
    label == auto or label == none or type(label) in (str, content),
    message: (
      "typed-physics: electricity.capacitor(\""
        + name
        + "\") `label:` must be auto, none, a string, or content"
    ),
  )
  (
    validation-kind: _network-validation-kind,
    kind: "component",
    component-kind: "capacitor",
    name: name,
    capacitance: capacitance,
    route: _validate-route(
      route,
      "electricity.capacitor(\"" + name + "\")",
    ),
    unit: _validate-unit(
      unit,
      "electricity.capacitor(\"" + name + "\")",
    ),
    label: label,
    style: _validate-component-style(
      style,
      "electricity capacitor \"" + name + "\"",
      "capacitor",
    ),
  )
}

#let voltage-source(
  name,
  voltage: none,
  unit: auto,
  label: auto,
  style: (:),
) = {
  validation.validate-name(
    name,
    source-description: "electricity.voltage-source()",
  )
  validation.validate-physical-scalar(
    voltage,
    "electricity.voltage-source(\"" + name + "\")",
    "voltage",
    allow-none: true,
  )
  assert(
    label == auto or label == none or type(label) in (str, content),
    message: (
      "typed-physics: electricity.voltage-source(\""
        + name
        + "\") `label:` must be auto, none, a string, or content"
    ),
  )
  (
    validation-kind: _network-validation-kind,
    kind: "component",
    component-kind: "voltage-source",
    name: name,
    voltage: voltage,
    route: auto,
    unit: _validate-unit(
      unit,
      "electricity.voltage-source(\"" + name + "\")",
    ),
    label: label,
    style: _validate-component-style(
      style,
      "electricity voltage source \"" + name + "\"",
      "voltage-source",
    ),
  )
}

#let _components-in(network) = {
  if network.kind == "component" { return (network,) }
  let components = ()
  for branch in network.branches {
    components += _components-in(branch)
  }
  components
}

// A routed branch is drawn along one or two straight legs of the frame, so its
// components must form a flat chain rather than a nested composition.
#let _routed-branch-components(branch) = {
  if branch.kind == "component" { return (branch,) }
  if (
    branch.kind == "series"
      and branch.branches.all(item => item.kind == "component")
  ) {
    return branch.branches
  }
  none
}

#let _validate-frame-routes(branches) = {
  let routed-branches = branches.filter(branch => branch.route != auto)
  if routed-branches.len() == 0 { return none }
  assert(
    routed-branches.len() == branches.len(),
    message: "typed-physics: when one branch of electricity.parallel(...) declares `route:`, every branch must declare one, because the routed branches together describe the shape of the frame",
  )
  for route-name in ("direct", "over", "under") {
    assert(
      branches.filter(branch => branch.route == route-name).len() <= 1,
      message: (
        "typed-physics: electricity.parallel(...) can place at most one branch on the \""
          + route-name
          + "\" route; the other branches need a different route or none at all"
      ),
    )
  }
  for branch in branches {
    let chain = _routed-branch-components(branch)
    assert(
      chain != none,
      message: (
        "typed-physics: a branch routed \""
          + branch.route
          + "\" must be one component or a flat series(...) of components, because it is drawn along the straight legs of the frame"
      ),
    )
    // Over and under branches turn at a single corner, so a leg can hold at
    // most one component.
    assert(
      branch.route == "direct" or chain.len() <= 2,
      message: (
        "typed-physics: the branch routed \""
          + branch.route
          + "\" holds "
          + str(chain.len())
          + " components, but that route turns at one corner and can hold at most two"
      ),
    )
  }
  none
}

#let _composition(kind, items, route) = {
  assert(
    items.named().len() == 0,
    message: (
      "typed-physics: electricity."
        + kind
        + "(...) takes circuit declarations positionally; `route:` is its only named argument"
    ),
  )
  let branches = items.pos()
  assert(
    branches.len() >= 2,
    message: (
      "typed-physics: electricity."
        + kind
        + "(...) needs at least two circuit declarations"
    ),
  )
  for (index, branch) in branches.enumerate() {
    _validate-network(
      branch,
      "electricity." + kind + "(...) item " + str(index + 1),
    )
  }
  if kind == "parallel" { _validate-frame-routes(branches) }
  (
    validation-kind: _network-validation-kind,
    kind: kind,
    branches: branches,
    route: _validate-route(route, "electricity." + kind + "(...)"),
  )
}

#let series(..branches, route: auto) = _composition("series", branches, route)

#let parallel(..branches, route: auto) = _composition(
  "parallel",
  branches,
  route,
)

// A route describes how one branch of a parallel network travels between the
// split and join nodes, so it has no meaning anywhere else.
#let _validate-routed-branches(network, inside-parallel) = {
  assert(
    network.route == auto or inside-parallel,
    message: (
      "typed-physics: `route:` describes how one branch of electricity.parallel(...) travels between the split and join nodes, so it has no meaning on a network that is not such a branch"
    ),
  )
  if network.kind == "component" { return none }
  for branch in network.branches {
    _validate-routed-branches(branch, network.kind == "parallel")
  }
  none
}

#let _validate-load-network(network) = {
  _validate-routed-branches(network, false)
  for component in _components-in(network) {
    assert(
      component.component-kind in ("resistor", "capacitor"),
      message: (
        "typed-physics: dc-circuit() accepts voltage-source(...) only as its first argument and resistor/capacitor networks as its second; move \""
          + component.name
          + "\" out of the load network"
      ),
    )
  }
  none
}

#let dc-circuit(source, network, style: (:)) = {
  _validate-network(source, "electricity.dc-circuit() first argument")
  assert(
    source.kind == "component" and source.component-kind == "voltage-source",
    message: "typed-physics: electricity.dc-circuit() first argument must be voltage-source(...)",
  )
  _validate-network(network, "electricity.dc-circuit() second argument")
  _validate-load-network(network)
  styles.resolve-style(style)

  let components = (source,) + _components-in(network)
  let component-names = ()
  for component in components {
    assert(
      component.name not in component-names,
      message: (
        "typed-physics: electrical component name \""
          + component.name
          + "\" is declared twice; give every source, resistor, and capacitor a unique name"
      ),
    )
    component-names.push(component.name)
  }

  (
    validation-kind: _circuit-validation-kind,
    source: source,
    network: network,
    components: components,
    style: style,
  )
}

#let validate-circuit(circuit, public-function) = {
  assert(
    type(circuit) == dictionary
      and circuit.at("validation-kind", default: none)
        == _circuit-validation-kind,
    message: (
      "typed-physics: electricity."
        + public-function
        + " needs the value returned by electricity.dc-circuit()"
    ),
  )
  none
}
