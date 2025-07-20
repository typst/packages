#import "../edge/lib.typ": get-connection-points

#let connection-points(
  index,
  node,
  nodes,
  style,
) = {
  let connection-points = () 
  
  let new-edges = ()

  for (i, edge) in node.edges {
    let is-start-node = edge.start-node == index
    let other-node-index = if(is-start-node) { edge.end-node } else { edge.start-node }
    let other-node = nodes.at(other-node-index)
    let points = get-connection-points(node, other-node, edge, i, is-start-node)

    if(is-start-node) { edge.start-connection-point = points.at(0).position } else { edge.end-connection-point = points.at(0).position }
    new-edges.push((i, edge))
    connection-points += points
  }

  return connection-points
}
