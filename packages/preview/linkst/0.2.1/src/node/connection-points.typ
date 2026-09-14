#import "../edge/lib.typ": get-connection-points

#let connection-points(
  index,
  node,
  nodes,
  edges,
) = {
  let connection-points = ()

  for edge-index in node.edges {
    let edge = edges.at(edge-index)
    let is-start-node = edge.start-node == index
    let other-node-index = if(is-start-node) { edge.end-node } else { edge.start-node }
    let other-node = nodes.at(other-node-index)
    let points = get-connection-points(node, other-node, edge, is-start-node)

    if(is-start-node) { edge.start-connection-point = points.at(0).position } else { edge.end-connection-point = points.at(0).position }
    connection-points += points
  }

  for (i, p) in connection-points.enumerate() { connection-points.at(i).index = i }

  return connection-points
}
