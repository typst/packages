/// Assemble local calls into a dependency DAG without executing policies.
#import "../graph.typ"

// Length-prefix the product identity so arbitrary product names cannot collide.
#let binding-id(output, port) = (
  str(output.len()) + ":" + output + ":" + str(port)
)

// Input positions remain distinct, including repeated products.
#let call-fragment(call) = graph.fragment(
  nodes: (
    graph.node(call.output, value: (
      kind: "call",
      policy: call.policy,
    )),
  ),
  edges: call
    .inputs
    .enumerate()
    .map(((port, source)) => graph.edge(
      binding-id(call.output, port),
      source: source,
      target: call.output,
      value: (port: port),
    )),
)

#let declarations(calls, inputs) = (
  (
    graph.fragment(nodes: inputs.map(id => (
      graph.node(id, value: (kind: "input"))
    ))),
  )
    + calls.map(call-fragment)
)

// Scheduling ignores repeated dependencies; argument ports remain in the graph.
#let dependencies(topology) = topology.nodes.map(id => (
  id: id,
  inputs: topology
    .edges
    .values()
    .filter(edge => edge.target == id)
    .map(edge => edge.source)
    .dedup(),
))

// A stalled remainder contains cycles and their blocked descendants.
#let layers(pending) = {
  if pending.len() == 0 { return (value: (), issues: ()) }
  let ready = pending
    .filter(item => item.inputs.len() == 0)
    .map(item => item.id)
  if ready.len() == 0 {
    return (
      value: none,
      issues: (
        (kind: "cyclic-dependencies", products: pending.map(item => item.id)),
      ),
    )
  }
  let rest = layers(
    pending
      .filter(item => item.id not in ready)
      .map(item => (
        id: item.id,
        inputs: item.inputs.filter(id => id not in ready),
      )),
  )
  if rest.value == none { return rest }
  (value: (ready,) + rest.value, issues: ())
}

#let validate(assembled, inputs, output) = {
  if output not in assembled.state.graph.nodes {
    return (flow: none, issues: ((kind: "missing-output", product: output),))
  }
  let schedule = layers(dependencies(assembled.state.graph))
  if schedule.value == none {
    return (flow: none, issues: schedule.issues)
  }
  (
    flow: (
      state: assembled.state,
      origins: assembled.origins,
      inputs: inputs,
      output: output,
      layers: schedule.value,
    ),
    issues: (),
  )
}

/// Returns (flow, issues); failure returns no flow.
/// Input order defines composite arguments. All calls are checked.
#let assemble(calls, inputs: (), output: none) = {
  assert(type(calls) == array, message: "policy calls must be an array")
  assert(type(inputs) == array, message: "policy inputs must be an array")
  assert(
    type(output) == str and output != "",
    message: "policy output must be a non-empty string",
  )

  let assembled = graph.assemble(declarations(calls, inputs))
  if assembled.state == none {
    return (flow: none, issues: assembled.issues)
  }
  validate(assembled, inputs, output)
}
