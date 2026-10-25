/// Exhaustive local preservation of a business observation on successful states.
#import "../semantic.typ"
#import "schema.typ"

// Cartesian powers include repeated states and preserve argument order.
#let arguments(states, count) = range(count).fold(((),), (tuples, _) => (
  tuples.fold((), (next, tuple) => next + states.map(state => tuple + (state,)))
))

#let inspect(definition, observer, contract, inputs, port) = {
  let issues = schema.checked(
    (definition.check)(inputs),
    schema.issues,
    scope: ("check",),
  )
  if issues.len() > 0 { return (admissible: false, issue: none) }
  let output = semantic.checked(contract, (definition.run)(inputs))
  let before = observer(inputs.at(port))
  let after = observer(output)
  (
    admissible: true,
    issue: if before == after { none } else {
      (
        kind: "observation-changed",
        port: port,
        inputs: inputs,
        output: output,
        before: before,
        after: after,
      )
    },
  )
}

/// Explicit checker. Enumerates the entire contract,
/// not just reachable DAG inputs. Observer values must support semantic equality.
/// Rejected inputs are excluded; contract violations and user panics propagate.
/// No admissible inputs produces no evidence, despite vacuous preservation.
#let check(definition, observer, contract, port: 0) = {
  let definition = schema.checked(definition, schema.definition)
  let observer = schema.checked(observer, schema.callable, scope: ("observer",))
  let port = schema.checked(port, schema.index, scope: ("port",))
  assert(
    port < definition.arity,
    message: "preservation port is outside policy inputs",
  )
  let results = arguments(semantic.states(contract), definition.arity).map(
    inputs => inspect(definition, observer, contract, inputs, port),
  )
  let admissible = results.filter(result => result.admissible).len()
  let issues = if admissible == 0 {
    ((kind: "no-admissible-inputs", port: port),)
  } else {
    results.filter(result => result.issue != none).map(result => result.issue)
  }
  (
    admissible: admissible,
    evidence: if issues.len() > 0 { none } else {
      (
        kind: "local-preservation",
        definition: definition,
        observer: observer,
        contract: contract,
        port: port,
        examined: results.len(),
        admissible: admissible,
      )
    },
    issues: issues,
  )
}
