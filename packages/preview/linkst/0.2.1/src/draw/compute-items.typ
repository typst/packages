#import "../utils/lib.typ": match-dict, resolve-relative, resolve-to-1d, resolve-to-2d, resolve-stroke-all
#import "../edge/lib.typ": resolve-type, auto-mode, resolve-short-not
#import "../node/lib.typ": resolve-pos, connection-points
#import "resolve-style.typ": resolve-style

#let compute-items(items, style) = {
  // normalize styles and reduce style data
  for (i, item) in items.enumerate() { items.at(i).style = resolve-style(item.style, item.type, style) }
  
  // resolve relative edge indices
  let node-count = 0
  let last-node-index = 0
  for (i, item) in items.enumerate() { 
    if item.type == "node" { last-node-index = node-count; node-count += 1 }
    else if item.type == "edge" { 
      if item.start-node < 0 { items.at(i).start-node = (last-node-index + item.start-node + 1) }
      if item.end-node < 0 { items.at(i).end-node = (last-node-index + item.end-node + 1) }
    }
  }

  // filter items by type
  let nodes = items.filter(e => e.type == "node")
  let edges = items.filter(e => e.type == "edge")
  let knots = items.filter(e => e.type == "knot")

  // resolve style to be usable
  for i in range(edges.len()) { edges.at(i).style.stroke = resolve-stroke-all(edges.at(i).style.stroke) }

  // assing indices
  for i in range(nodes.len()) { nodes.at(i).index = i }
  for i in range(edges.len()) { edges.at(i).index = i }
  for i in range(knots.len()) { knots.at(i).index = i }
  
  // compute node data
  nodes = nodes.map(node => {
    node.position = resolve-pos(node.position)
    node.connect = resolve-to-2d(node.connect)
    node
  })

  // compute edge data
  edges = edges.map(edge => {
    edge = resolve-short-not(edge)
    edge.edge-type = resolve-type(edge)
    edge.mode = auto-mode(edge.edge-type, edge.mode)
    edge = resolve-relative(edge, nodes.at(edge.start-node), nodes.at(edge.end-node))
    edge
  })

  // get intersection of edges and nodes
  //  assign edges to nodes
  for (i, edge) in edges.enumerate() {
    nodes.at(edge.start-node).edges.push(i)
    if(edge.start-node != edge.end-node) { nodes.at(edge.end-node).edges.push(i) }
  }
  //  assign connection points to nodes
  for (i, node) in nodes.enumerate() {
    nodes.at(i).connection-points = connection-points(i, node, nodes, edges)
  }

  return (knots, edges, nodes)
}
