#import "../../core/graph.typ"
#import "../../core/vocabulary.typ"
#import "content.typ": emit

#let colored-edge(registry, color, body) = {
  assert(
    vocabulary.enum-value(color) and vocabulary.contains(registry, color),
    message: "relation color must be a registered enum",
  )
  emit((protocol: "zettyp.dependency", version: 1, color: color, body: body))
  body
}

/// Build named neighbor views once per state, outside the node loop.
#let neighbor-index(state, projections) = {
  let topology = graph.schema.checked(state.graph, graph.schema.graph)
  let queries = projections
    .pairs()
    .map(((name, query)) => {
      let query = graph.schema.checked(query, graph.schema.record(
        "NeighborQuery",
        (
          color: graph.schema.opaque,
          direction: graph.schema.one-of(("incoming", "outgoing")),
        ),
      ))
      assert(
        vocabulary.enum-value(query.color),
        message: "expected a relation color",
      )
      let incoming = query.direction == "incoming"
      (
        name: name,
        color: query.color,
        node: if incoming { "target" } else { "source" },
        neighbor: if incoming { "source" } else { "target" },
      )
    })
  let views = projections.keys().map(name => (name, (:))).to-dict()
  for (id, edge) in topology.edges {
    for query in queries {
      if state.values.edges.at(id).relation != query.color { continue }
      let node = edge.at(query.node)
      let view = views.at(query.name)
      view.insert(node, view.at(node, default: ()) + (edge.at(query.neighbor),))
      views.insert(query.name, view)
    }
  }
  (
    nodes: topology.nodes.map(id => (id, true)).to-dict(),
    views: views
      .pairs()
      .map(((name, view)) => (
        name,
        view.pairs().map(((id, ids)) => (id, ids.dedup())).to-dict(),
      ))
      .to-dict(),
  )
}

/// Query a prepared view; preserve first-occurrence order and isolated nodes.
#let neighbors(index, id, name) = {
  graph.require-id(id)
  assert(id in index.nodes, message: "unknown node: " + id)
  index.views.at(name).at(id, default: ())
}

#let project-neighbors(index, id) = (
  index.views.keys().map(name => (name, neighbors(index, id, name))).to-dict()
)

/// Group the selected relation view without changing original occurrences.
#let dependency-groups(state, colors) = {
  let ids = state
    .graph
    .edges
    .keys()
    .filter(id => state.values.edges.at(id).relation in colors)
  ids
    .map(id => state.graph.edges.at(id))
    .dedup()
    .map(edge => (
      edge + (occurrences: ids.filter(id => state.graph.edges.at(id) == edge))
    ))
}

#let reachable(edges, start, target) = {
  let pending = (start,)
  let visited = ()
  while pending.len() > 0 {
    let id = pending.pop()
    if id == target { return true }
    if id in visited { continue }
    visited.push(id)
    pending += edges.filter(edge => edge.source == id).map(edge => edge.target)
  }
  false
}
