// model: mixed node/edge descriptors -> a validated graph. Pure, no cetz.
// Splits the argument list into nodes and edges, checks each node id is unique and
// each edge references declared nodes, and names the offender on bad input.
// Returns (nodes, edges, ids) — `ids` maps a node id to its position in `nodes`.

#let shapes = ("rounded", "rectangle", "diamond", "parallelogram")

#let model(items) = {
  let nodes = ()
  let edges = ()
  let ids = (:)
  for (i, it) in items.enumerate() {
    assert(
      type(it) == dictionary
        and it.at("kind", default: none) in ("node", "edge"),
      message: "flowchart: argument " + str(i) + " is not a node() or edge()",
    )
    if it.kind == "node" {
      assert(
        it.id not in ids,
        message: "flowchart: duplicate node id " + repr(it.id),
      )
      assert(
        shapes.contains(it.shape),
        message: "node "
          + repr(it.id)
          + ": shape must be one of "
          + shapes.join(", "),
      )
      ids.insert(it.id, nodes.len())
      nodes.push((
        index: nodes.len(),
        id: it.id,
        label: it.label,
        shape: it.shape,
        fill: it.fill,
      ))
    } else {
      assert(
        it.from in ids,
        message: "flowchart: edge references unknown node " + repr(it.from),
      )
      assert(
        it.to in ids,
        message: "flowchart: edge references unknown node " + repr(it.to),
      )
      edges.push((from: it.from, to: it.to, label: it.label))
    }
  }
  (nodes: nodes, edges: edges, ids: ids)
}
