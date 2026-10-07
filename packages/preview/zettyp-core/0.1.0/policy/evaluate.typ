/// Evaluate an assembled flow over one fixed knowledge graph.
#import "function.typ" as policy
#import "../semantic.typ"

// User functions must return complete assignments on the same topology.
#let checked(state, topology) = {
  assert(
    type(state) == dictionary,
    message: "policy product must be a GraphState",
  )
  assert(
    state.at("graph", default: none) == topology,
    message: "policy product changed topology",
  )
  let values = state.at("values", default: none)
  assert(
    type(values) == dictionary,
    message: "policy product must contain values",
  )
  let nodes = values.at("nodes", default: none)
  let edges = values.at("edges", default: none)
  assert(
    type(nodes) == dictionary and type(edges) == dictionary,
    message: "policy assignments must be dictionaries",
  )
  assert(
    nodes.keys().sorted() == topology.nodes.sorted(),
    message: "policy node assignments do not match topology",
  )
  assert(
    edges.keys().sorted() == topology.edges.keys().sorted(),
    message: "policy edge assignments do not match topology",
  )
  state
}

#let sources(state, target) = (
  (
    state.graph.edges.pairs().filter(pair => pair.at(1).target == target)
  )
    .sorted(key: pair => state.values.edges.at(pair.at(0)).port)
    .map(pair => pair.at(1).source)
)

#let collect(pairs) = pairs.fold((:), (values, pair) => {
  values.insert(pair.at(0), pair.at(1))
  values
})

// Blocked calls never run their check or implementation.
#let evaluate-call(state, id, results, validate) = {
  let upstream = sources(state, id)
  let unavailable = upstream.filter(source => (
    results.at(source).status != "success"
  ))
  if unavailable.len() > 0 {
    return (status: "blocked", dependencies: unavailable.dedup())
  }
  let result = policy.apply(
    state.values.nodes.at(id).policy,
    upstream.map(source => results.at(source).value),
  )
  if result.status == "failure" { return result }
  (status: "success", value: validate(result.value))
}

#let evaluate-layer(flow, layer, results, validate) = {
  let calls = layer.filter(id => flow.state.values.nodes.at(id).kind == "call")
  (
    results
      + collect(calls.map(id => (
        id,
        evaluate-call(flow.state, id, results, validate),
      )))
  )
}

/// Supply a finite contract, or just topology for unrestricted assignments.
/// Returns (results, output). Contract violations panic; check issues recover.
#let evaluate(flow, topology: none, contract: none, inputs: ()) = {
  let validate = if contract == none {
    assert(
      type(topology) == dictionary,
      message: "evaluation requires a graph topology",
    )
    state => checked(state, topology)
  } else {
    assert(
      topology == none or topology == contract.topology,
      message: "evaluation topology conflicts with semantic contract",
    )
    state => semantic.checked(contract, state)
  }
  assert(type(inputs) == array, message: "policy inputs must be an array")
  assert(
    inputs.len() == flow.inputs.len(),
    message: "policy input count does not match flow",
  )

  let initial = collect(
    flow
      .inputs
      .zip(inputs)
      .map(((id, state)) => (
        id,
        (status: "success", value: validate(state)),
      )),
  )
  let results = flow.layers.fold(initial, (results, layer) => (
    evaluate-layer(flow, layer, results, validate)
  ))
  (results: results, output: results.at(flow.output))
}
