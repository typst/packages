/// Strict local preservation along every binding-to-output dependency path.
#import "preservation.typ"

#let closure(order, edges, start, reverse: false) = order.fold((start,), (
  seen,
  id,
) => {
  let reached = edges.any(edge => {
    if reverse {
      edge.source == id and edge.target in seen
    } else {
      edge.target == id and edge.source in seen
    }
  })
  if id in seen or not reached { seen } else { seen + (id,) }
})

#let check-binding(flow, binding, contract) = {
  if binding.at == flow.output {
    return (evidence: (kind: "final", target: flow.output), issues: ())
  }
  if contract == none {
    return (evidence: none, issues: ((kind: "missing-semantic-contract"),))
  }
  let order = flow.layers.fold((), (order, layer) => order + layer)
  let edges = flow.state.graph.edges
  let downstream = closure(order, edges.values(), binding.at)
  if flow.output not in downstream {
    return (evidence: none, issues: ((kind: "no-preservation-path"),))
  }
  let upstream = closure(
    order.rev(),
    edges.values(),
    flow.output,
    reverse: true,
  )
  let relevant = edges
    .pairs()
    .filter(((id, edge)) => (
      edge.source in downstream and edge.target in upstream
    ))
  let checks = relevant.map(((id, edge)) => {
    let port = flow.state.values.edges.at(id).port
    let result = preservation.check(
      flow.state.values.nodes.at(edge.target).policy,
      binding.observer,
      contract,
      port: port,
    )
    (
      edge: id,
      issues: result.issues.map(issue => (
        issue
          + (
            source: edge.source,
            invocation: edge.target,
          )
      )),
    )
  })
  let issues = checks.map(check => check.issues).flatten()
  if issues.len() > 0 { return (evidence: none, issues: issues) }
  (
    evidence: (
      kind: "local-preservation",
      target: flow.output,
      edges: checks.map(check => check.edge),
    ),
    issues: (),
  )
}

/// No partial authorization: every declared binding must pass.
#let verify(flow, bindings, contract: none) = {
  let checked = bindings.map(binding => (
    binding: binding,
    result: check-binding(flow, binding, contract),
  ))
  let issues = checked
    .map(item => item.result.issues.map(issue => (
      issue + (observation: item.binding.name, product: item.binding.at)
    )))
    .flatten()
  if issues.len() > 0 { return (plan: none, issues: issues) }
  (
    plan: (
      target: flow.output,
      contract: contract,
      bindings: checked.map(item => (
        item.binding + (evidence: item.result.evidence)
      )),
    ),
    issues: (),
  )
}
