// A logical edge keeps real endpoints; an adapter's local geometry may instead
// contain a continuation boundary. These records never route or move content.
#let _deixis-logical-endpoints(source, target) = (
  source: if source.virtual { none } else { source },
  target: if target.virtual { none } else { target },
)

// Margin placement publishes its source and accepted destination on different
// pages. Join that existing evidence without querying/remeasuring live bodies.
// Conflicting frames remain unknown rather than selecting an arbitrary body.
#let _deixis-margin-endpoint-index(connections) = {
  let grouped = (:)
  for prepared in connections {
    let edge = prepared.edge
    if edge.source.identity == none { continue }
    let uid = str(edge.source.identity)
    if uid not in grouped { grouped.insert(uid, (source: (), target: ())) }
    for (role, node) in (("source", edge.source), ("target", edge.target)) {
      if not node.virtual { grouped.at(uid).at(role).push(node) }
    }
  }
  let result = (:)
  for (uid, roles) in grouped {
    let endpoints = (:)
    for (role, nodes) in roles {
      endpoints.insert(role, if nodes.len() > 0 and nodes.all(n => n.page == nodes.first().page and n.bounds == nodes.first().bounds) {
        nodes.first()
      } else { none })
    }
    result.insert(uid, endpoints)
  }
  result
}

#let _deixis-continuation-peer(node) = {
  if node == none { return none }
  let b = node.bounds
  let point = (b.left + (b.right - b.left) / 2, b.top + (b.bottom - b.top) / 2)
  (page: node.page, point: point, destination: (page: node.page, x: point.first(), y: point.last()))
}

#let _deixis-page-fragment(edge, page, source, target, incoming: false, outgoing: false) = {
  let logical = edge.at("logical", default: _deixis-logical-endpoints(edge.source, edge.target))
  let complete = logical.source != none and logical.target != none
  (page: page, kind: if incoming { "target" } else if outgoing { "source" } else { "whole" },
    status: if complete { "resolved" } else { "incomplete" },
    source: source, target: target, logical: logical)
}
