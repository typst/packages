/// Directed multigraphs assembled from local declarations.
///
/// Graph = (
///   nodes: array<string>,
///   edges: dictionary<edge-id, (source: string, target: string)>,
/// )
/// GraphState = (
///   graph: Graph,
///   values: (nodes: dictionary<node-id, any>, edges: dictionary<edge-id, any>),
/// )
///
/// Identities are non-empty strings. Node and edge identities occupy separate
/// namespaces. Parallel edges remain distinct by ID; cycles are allowed.
/// Values are opaque to this module. Source origins are kept outside the state.

#let require-id(id) = {
  assert(type(id) == str, message: "graph identity must be a string")
  assert(id != "", message: "graph identity must not be empty")
}

/// Declare a node and its initial value. Origin is optional, opaque provenance.
#let node(id, value: none, origin: none) = {
  require-id(id)
  (id: id, value: value, origin: origin)
}

/// Declare an edge occurrence. Endpoints need not exist in the local fragment.
#let edge(id, source: none, target: none, value: none, origin: none) = {
  require-id(id)
  require-id(source)
  require-id(target)
  (id: id, source: source, target: target, value: value, origin: origin)
}

/// Group declarations without resolving references or choosing edge ownership.
#let fragment(nodes: (), edges: ()) = {
  assert(type(nodes) == array, message: "fragment nodes must be an array")
  assert(type(edges) == array, message: "fragment edges must be an array")
  (nodes: nodes, edges: edges)
}

// Report each duplicate against the first declaration of that identity.
#let duplicate-issues(items, kind) = {
  let origins = (:)
  let issues = ()
  for item in items {
    if item.id in origins {
      issues.push((
        kind: kind,
        id: item.id,
        origins: (origins.at(item.id), item.origin),
      ))
    } else {
      origins.insert(item.id, item.origin)
    }
  }
  issues
}

#let endpoint-issues(edges, node-ids) = (
  edges
    .map(item => {
      ("source", "target")
        .filter(endpoint => item.at(endpoint) not in node-ids)
        .map(endpoint => (
          kind: "missing-endpoint",
          id: item.id,
          endpoint: endpoint,
          target: item.at(endpoint),
          origin: item.origin,
        ))
    })
    .flatten()
)

// Only index declarations after uniqueness has been checked.
#let index-by-id(items, project) = {
  let index = (:)
  for item in items {
    index.insert(item.id, project(item))
  }
  index
}

/// Assemble fragments after collecting all declarations.
///
/// Returns (state: GraphState | none, origins: ..., issues: array).
/// Duplicate identities and missing endpoints are reported, never repaired.
/// No partial graph is returned on failure. Malformed declarations are API
/// errors; use node, edge, and fragment to construct them.
///
/// Array order follows declaration order, but does not imply execution order.
#let assemble(fragments) = {
  let nodes = fragments
    .map(part => part.nodes)
    .flatten()
    .map(item => node(
      item.id,
      value: item.value,
      origin: item.origin,
    ))

  let edges = fragments
    .map(part => part.edges)
    .flatten()
    .map(item => edge(
      item.id,
      source: item.source,
      target: item.target,
      value: item.value,
      origin: item.origin,
    ))
  let node-ids = nodes.map(item => item.id)

  let issues = (
    duplicate-issues(nodes, "duplicate-node")
      + duplicate-issues(edges, "duplicate-edge")
      + endpoint-issues(edges, node-ids)
  )
  if issues.len() > 0 {
    return (state: none, origins: none, issues: issues)
  }

  (
    state: (
      graph: (
        nodes: node-ids,
        edges: index-by-id(edges, item => (
          source: item.source,
          target: item.target,
        )),
      ),
      values: (
        nodes: index-by-id(nodes, item => item.value),
        edges: index-by-id(edges, item => item.value),
      ),
    ),
    origins: (
      nodes: index-by-id(nodes, item => item.origin),
      edges: index-by-id(edges, item => item.origin),
    ),
    issues: (),
  )
}

/// Replace selected values, preserving topology and all unmentioned values.
/// Accepts a state produced by assemble or assign. Unknown identities are errors.
#let assign(state, nodes: (:), edges: (:)) = {
  assert(
    type(nodes) == dictionary,
    message: "node assignments must be a dictionary",
  )
  assert(
    type(edges) == dictionary,
    message: "edge assignments must be a dictionary",
  )
  for id in nodes.keys() {
    assert(id in state.values.nodes, message: "unknown node: " + id)
  }
  for id in edges.keys() {
    assert(id in state.values.edges, message: "unknown edge: " + id)
  }
  (
    graph: state.graph,
    values: (
      nodes: state.values.nodes + nodes,
      edges: state.values.edges + edges,
    ),
  )
}

/// Return edge identities without collapsing parallel occurrences.
#let incoming(graph, id) = {
  assert(id in graph.nodes, message: "unknown node: " + id)
  graph
    .edges
    .pairs()
    .filter(pair => pair.at(1).target == id)
    .map(pair => pair.at(0))
}

#let outgoing(graph, id) = {
  assert(id in graph.nodes, message: "unknown node: " + id)
  graph
    .edges
    .pairs()
    .filter(pair => pair.at(1).source == id)
    .map(pair => pair.at(0))
}
