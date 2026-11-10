/// The disjoint union of contract-valid GraphStates and invocation errors.
/// Left holds a state; right holds a failure or blocked error with its producer.
/// Sources and dependency wiring remain outside this carrier.
#import "../semantic.typ"
#import "../graph.typ"
#import "clone.typ"
#import "sum.typ"
#import "schema.typ"

#let success(contract, state) = sum.left(semantic.checked(contract, state))

#let failure(id, issues) = {
  let error = schema.checked(
    (kind: "failure", invocation: id, issues: issues),
    schema.failure,
  )
  sum.right(error + (issues: error.issues.dedup()))
}

#let blocked(id, dependencies) = {
  let error = schema.checked(
    (kind: "blocked", invocation: id, dependencies: dependencies),
    schema.blocked,
  )
  sum.right(error + (dependencies: error.dependencies.dedup().sorted()))
}

/// Check carrier membership, not policy applicability.
/// Malformed sums, errors and contract violations panic.
#let checked(contract, result) = {
  let validate = sum.merge(
    state => success(contract, state),
    error => {
      let error = schema.checked(error, schema.error, scope: ("error",))
      if error.kind == "failure" {
        failure(error.invocation, error.issues)
      } else {
        blocked(error.invocation, error.dependencies)
      }
    },
  )
  validate(result)
}

/// Both branches return the caller's chosen observation space.
/// Observer receives a state; on-error receives the complete error payload.
/// No invocation identity, DAG access or diagnostic side effects are added.
#let lift-observer(contract, observer, on-error) = {
  let observe = sum.merge(observer, on-error)
  result => observe(checked(contract, result))
}

/// Collect checked policy inputs: all ordered states or all ordered errors.
/// Preserve repeated errors; blocked determines producer deduplication.
/// Empty inputs yield a successful empty tuple for nullary policies.
#let collect-inputs(inputs) = {
  let inputs = schema.checked(inputs, schema.sums, scope: ("inputs",))
  let append = sum.merge(
    states => sum.merge(
      state => sum.left(states + (state,)),
      error => sum.right((error,)),
    ),
    errors => sum.merge(
      _ => sum.right(errors),
      error => sum.right(errors + (error,)),
    ),
  )
  inputs.fold(sum.left(()), (collected, input) => (append(collected))(input))
}

/// Lift one definition at a fixed invocation identity and semantic contract.
/// Validate all inputs before collecting errors. Only all-left inputs reach
/// check; only an empty check result reaches run. Contract panics propagate.
#let lift(contract, id, definition) = {
  graph.require-id(id)
  let definition = schema.checked(definition, schema.definition)
  let execute = sum.merge(
    states => {
      let issues = schema.checked(
        (definition.check)(states),
        schema.issues,
        scope: ("check",),
      )
      if issues.len() > 0 { return failure(id, issues) }
      success(contract, (definition.run)(states))
    },
    errors => blocked(id, errors.map(error => error.invocation)),
  )
  clone.operation(definition.arity, arguments => {
    let inputs = arguments.map(result => checked(contract, result))
    execute(collect-inputs(inputs))
  })
}
