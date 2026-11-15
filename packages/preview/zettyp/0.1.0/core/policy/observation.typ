/// Local observations: reusable definitions, address bindings, and collection.
#import "result.typ"
#import "schema.typ"

/// Branches share the caller's chosen observation space.
/// Construction executes neither branch; error interpretation is explicit.
#let definition(observe, on-error: none) = schema.checked(
  (observe: observe, on-error: on-error),
  schema.observer,
)

/// Names identify observations, not computation vertices.
/// Several observations may consume the same vertex without adding DAG nodes.
#let binding(name, definition, at: none, origin: none) = schema.checked(
  (name: name, definition: definition, at: at, origin: origin),
  schema.binding,
)

/// Resolve all addresses before lifting. No observation is executed.
/// Structural issues produce no partial plan; preservation is not required.
#let compile(program, bindings) = {
  let bindings = schema.checked(bindings, schema.bindings)
  let issues = ()
  for (index, binding) in bindings.enumerate() {
    if bindings.slice(0, index).any(previous => previous.name == binding.name) {
      issues.push((
        kind: "duplicate-observation",
        name: binding.name,
        origin: binding.origin,
      ))
    }
    if binding.at not in program.wiring.slots {
      issues.push((
        kind: "missing-observation-target",
        name: binding.name,
        at: binding.at,
        origin: binding.origin,
      ))
    }
  }
  if issues.len() > 0 { return (plan: none, issues: issues) }
  (
    plan: (
      bindings: bindings.map(binding => (
        name: binding.name,
        at: binding.at,
        origin: binding.origin,
        observe: result.lift-observer(
          program.contract,
          binding.definition.observe,
          binding.definition.on-error,
        ),
      )),
    ),
    issues: (),
  )
}

/// Consume saved results from the same program, never rerunning its policies.
/// Missing addresses are errors, not substitutes for invocation failures.
/// Each lifted observer owns its success/error interpretation and validation.
#let collect(plan, evaluation) = {
  for binding in plan.bindings {
    assert(
      binding.at in evaluation.results,
      message: "missing observation result: " + binding.at,
    )
  }
  plan.bindings.fold((:), (table, binding) => {
    table.insert(binding.name, (
      at: binding.at,
      origin: binding.origin,
      value: (binding.observe)(evaluation.results.at(binding.at)),
    ))
    table
  })
}

/// Read a collected value without executing observers again.
#let query(table, name) = {
  assert(name in table, message: "unknown observation: " + name)
  table.at(name)
}
