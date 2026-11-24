/// Exhaustive observation preservation over a finite semantic contract.
#import "../semantic.typ"
#import "function.typ" as policy

// Ordered argument tuples, including repeated states.
#let arguments(states, count) = range(count).fold(((),), (tuples, _) => (
  tuples.fold((), (next, tuple) => next + states.map(state => tuple + (state,)))
))

#let inspect(definition, observer, contract, inputs, port) = {
  let result = policy.apply(definition, inputs)
  if result.status == "failure" { return (admissible: false, issue: none) }
  let output = semantic.checked(contract, result.value)
  let before = observer(inputs.at(port))
  let after = observer(output)
  (
    admissible: true,
    issue: if before == after { none } else {
      (
        kind: "observation-changed",
        policy: definition.name,
        port: port,
        inputs: inputs,
        output: output,
        before: before,
        after: after,
      )
    },
  )
}

/// Success means every admissible tuple preserves the selected input's observation.
/// No admissible inputs is an error, not a vacuous authorization to consume.
#let check(definition, observer, contract, port: 0) = {
  assert(type(observer) == function, message: "observer must be a function")
  assert(
    type(port) == int and port >= 0 and port < definition.inputs,
    message: "preservation port is outside policy inputs",
  )
  let results = arguments(semantic.states(contract), definition.inputs).map(
    inputs => (
      inspect(definition, observer, contract, inputs, port)
    ),
  )
  let admissible = results.filter(result => result.admissible).len()
  if admissible == 0 {
    return (
      admissible: 0,
      issues: (
        (kind: "no-admissible-inputs", policy: definition.name, port: port),
      ),
    )
  }
  (
    admissible: admissible,
    issues: results
      .filter(result => result.issue != none)
      .map(result => result.issue),
  )
}
