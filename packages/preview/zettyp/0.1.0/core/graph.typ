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

#import "graph-schema.typ" as schema

#let require-id(id) = {
  let _ = schema.checked(id, schema.id)
}

/// Declare a node and its initial value. Origin is optional, opaque provenance.
#let node(id, value: none, origin: none) = schema.checked(
  (id: id, value: value, origin: origin),
  schema.node-declaration,
)

/// Declare an edge occurrence. Endpoints need not exist in the local fragment.
#let edge(
  id,
  source: none,
  target: none,
  value: none,
  origin: none,
) = schema.checked(
  (id: id, source: source, target: target, value: value, origin: origin),
  schema.edge-declaration,
)

/// Group declarations without resolving references or choosing edge ownership.
#let fragment(nodes: (), edges: ()) = schema.checked(
  (nodes: nodes, edges: edges),
  schema.fragment,
)

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
  let fragments = schema.checked(fragments, schema.fragments)
  let nodes = fragments.map(part => part.nodes).flatten()
  let edges = fragments.map(part => part.edges).flatten()
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
  let state = schema.checked(state, schema.state, scope: ("state",))
  let updates = schema.checked(
    (nodes: nodes, edges: edges),
    schema.assignments,
    scope: ("assignments",),
  )
  for id in updates.nodes.keys() {
    assert(id in state.values.nodes, message: "unknown node: " + id)
  }
  for id in updates.edges.keys() {
    assert(id in state.values.edges, message: "unknown edge: " + id)
  }
  (
    graph: state.graph,
    values: (
      nodes: state.values.nodes + updates.nodes,
      edges: state.values.edges + updates.edges,
    ),
  )
}

/// Return edge identities without collapsing parallel occurrences.
#let incoming(graph, id) = {
  let graph = schema.checked(graph, schema.graph, scope: ("graph",))
  require-id(id)
  assert(id in graph.nodes, message: "unknown node: " + id)
  graph
    .edges
    .pairs()
    .filter(pair => pair.at(1).target == id)
    .map(pair => pair.at(0))
}

#let outgoing(graph, id) = {
  let graph = schema.checked(graph, schema.graph, scope: ("graph",))
  require-id(id)
  assert(id in graph.nodes, message: "unknown node: " + id)
  graph
    .edges
    .pairs()
    .filter(pair => pair.at(1).source == id)
    .map(pair => pair.at(0))
}
