/// Assemble local knowledge observations using the common graph machinery.
#import "../graph.typ"

/// Returns (state, origins, data, unclassified, issues).
///
/// State and origins come directly from graph.assemble. Open data is indexed
/// by node ID only after successful assembly; on failure it is none.
///
/// References to known nodes become graph edges. Other references remain
/// unclassified: they may denote anchors, bibliography entries, or missing
/// knowledge nodes. Their absence alone is not a broken-link diagnosis.
#let assemble(locals) = {
  let ids = locals.map(item => item.node.id)
  let references = locals.map(item => item.references).flatten()
  let internal = references.filter(item => item.target in ids)
  let unclassified = references.filter(item => item.target not in ids)

  let result = graph.assemble((
    graph.fragment(
      nodes: locals.map(item => item.node),
      edges: internal,
    ),
  ))
  if result.state == none {
    return result + (data: none, unclassified: unclassified)
  }

  let data = (:)
  for item in locals {
    data.insert(item.node.id, item.data)
  }
  result + (data: data, unclassified: unclassified)
}
