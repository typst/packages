/// Named observation bindings and snapshot-local results.
#import "verification.typ"
#import "../semantic.typ"

#let bind(name, observer: none, at: none) = {
  assert(
    type(name) == str and name != "",
    message: "observation name must be a non-empty string",
  )
  assert(type(observer) == function, message: "observer must be a function")
  assert(
    type(at) == str and at != "",
    message: "observation product must be a non-empty string",
  )
  (name: name, observer: observer, at: at)
}

#let binding-issues(flow, bindings) = (
  bindings
    .enumerate()
    .map(((index, binding)) => {
      let duplicate = bindings
        .slice(0, index)
        .any(previous => previous.name == binding.name)
      let missing = binding.at not in flow.state.graph.nodes
      (
        (
          if duplicate {
            ((kind: "duplicate-observation", name: binding.name),)
          } else { () }
        )
          + (
            if missing {
              (
                (
                  kind: "missing-product",
                  name: binding.name,
                  product: binding.at,
                ),
              )
            } else { () }
          )
      )
    })
    .flatten()
)

/// Resolve bind declarations. Structural validity does not prove stability.
#let prepare(flow, bindings) = {
  assert(
    type(bindings) == array,
    message: "observation bindings must be an array",
  )
  let issues = binding-issues(flow, bindings)
  if issues.len() > 0 { return (plan: none, issues: issues) }
  (plan: (flow: flow, bindings: bindings), issues: ())
}

/// Complete verification before collecting any observation values.
#let verify(prepared, contract: none) = verification.verify(
  prepared.flow,
  prepared.bindings,
  contract: contract,
)

// Never substitute another product for an unavailable binding.
#let observe(binding, target, results) = {
  let result = results.at(binding.at)
  let location = (product: binding.at, target: target)
  if result.status != "success" {
    return location + (status: "unavailable", reason: result.status)
  }
  (
    location
      + (
        status: "available",
        value: (binding.observer)(result.value),
        evidence: binding.evidence,
      )
  )
}

/// Consume a verified plan with an evaluation of its flow; never fall back.
#let collect(plan, evaluation) = {
  assert(
    "contract" in plan,
    message: "observations must be verified before collection",
  )
  if plan.contract != none {
    for result in evaluation.results.values() {
      if result.status == "success" {
        let _ = semantic.checked(plan.contract, result.value)
      }
    }
  }
  plan.bindings.fold((:), (table, binding) => {
    table.insert(binding.name, observe(
      binding,
      plan.target,
      evaluation.results,
    ))
    table
  })
}

/// Read saved results without rerunning observers or publishing announcements.
#let query(table, name) = {
  assert(name in table, message: "unknown observation: " + name)
  table.at(name)
}
