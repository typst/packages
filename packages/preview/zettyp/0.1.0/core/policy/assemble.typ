/// Resolve invocation declarations into addressable, acyclic wiring.
#import "../graph.typ"
#import "schema.typ"

// Scheduling uses dependency sets; invocation ports retain order and repeats.
// A stalled remainder includes cycles and descendants waiting on those cycles.
#let layers(calls, inputs) = {
  let pending = calls.map(call => (
    id: call.id,
    dependencies: call.inputs.filter(id => id not in inputs).dedup(),
  ))
  let result = ()
  while pending.len() > 0 {
    let ready = pending
      .filter(call => call.dependencies.len() == 0)
      .map(call => call.id)
      .sorted()
    if ready.len() == 0 {
      return (
        value: none,
        issues: (
          (
            kind: "cyclic-dependencies",
            unresolved: pending.map(call => call.id).sorted(),
          ),
        ),
      )
    }
    result.push(ready)
    pending = pending
      .filter(call => call.id not in ready)
      .map(call => (
        id: call.id,
        dependencies: call.dependencies.filter(id => id not in ready),
      ))
  }
  (value: result, issues: ())
}

/// Returns (wiring, issues). Invalid structure produces no partial wiring.
/// Inputs are ordered external identities; calls come from invocation().
/// All identities share one namespace. Forward references and unused nodes
/// are valid. No definition is executed and no semantic contract is required.
#let assemble(calls, inputs: ()) = {
  let calls = schema.checked(calls, schema.invocations, scope: ("calls",))
  let inputs = schema.checked(inputs, schema.identities, scope: ("inputs",))
  let declarations = inputs.map(id => (id: id, origin: none)) + calls
  let ids = declarations.map(item => item.id)
  let issues = graph.duplicate-issues(declarations, "duplicate-identity")
  for call in calls {
    if call.inputs.len() != call.definition.arity {
      issues.push((
        kind: "port-count-mismatch",
        invocation: call.id,
        expected: call.definition.arity,
        actual: call.inputs.len(),
        origin: call.origin,
      ))
    }
    for (port, source) in call.inputs.enumerate() {
      if source not in ids {
        issues.push((
          kind: "missing-input",
          invocation: call.id,
          port: port,
          source: source,
          origin: call.origin,
        ))
      }
    }
  }
  if issues.len() > 0 { return (wiring: none, issues: issues) }

  let schedule = layers(calls, inputs)
  if schedule.value == none {
    return (wiring: none, issues: schedule.issues)
  }
  // External input order is semantic; each ready layer uses canonical ID order.
  let ids = inputs + schedule.value.flatten()
  let slots = ids
    .enumerate()
    .fold((:), (table, pair) => {
      let (slot, id) = pair
      table.insert(id, slot)
      table
    })
  let definitions = graph.index-by-id(calls, call => (
    definition: call.definition,
    ports: call.inputs.map(id => slots.at(id)),
  ))
  (
    wiring: (
      inputs: inputs,
      ids: ids,
      slots: slots,
      calls: definitions,
      origins: graph.index-by-id(declarations, item => item.origin),
      layers: schedule.value,
    ),
    issues: (),
  )
}
