#import "../utils/lib.typ": match-dict, resolve-relative, resolve-to-2d, resolve-stroke
#import "../edge/lib.typ": resolve-type, auto-mode
#import "../node/lib.typ": resolve-pos, connection-points

#let compute-items(items, style) = {
  // normalize item styles
  items = items.map(item => {
    if item.style.keys().find(k => k == "stroke") != none { item.style.stroke = resolve-stroke(item.style.stroke) } // resolve strokes to dictionaries

    if item.style.keys().find(k => k == "transform") != none { item.style.transform = style.transform + item.style.transform } // add the transform

    item.style = match-dict(item.style, style);
    item
  })

  // filter items by type
  let nodes = items.filter(e => e.type == "node")
  let edges = items.filter(e => e.type == "edge")
  let knots = items.filter(e => e.type == "knot")

  // assing indices
  nodes = nodes.enumerate().map(k => { let (i, node) = k; node.index = i; node })
  edges = edges.enumerate().map(k => { let (i, edge) = k; edge.index = i; edge })
  knots = knots.enumerate().map(k => { let (i, knot) = k; knot.index = i; knot })
  
  // compute node data
  nodes = nodes.map(node => {
    node.position = resolve-pos(node.position)
    node.connect = resolve-to-2d(node.connect)
    node
  })

  // compute edge data
  edges = edges.map(edge => {
    edge.edge-type = resolve-type(edge);
    edge.mode = auto-mode(edge.edge-type, edge.mode)
    edge = resolve-relative(edge, nodes.at(edge.start-node), nodes.at(edge.end-node))
    edge
  })

  // get intersection of edges and nodes
  //  assign edges to nodes
  for (i, edge) in edges.enumerate() {
    nodes.at(edge.start-node).edges.push((i, edge))
    if(edge.start-node != edge.end-node) { nodes.at(edge.end-node).edges.push((i, edge)) }
  }
  //  assign connection points to nodes
  let nodes = nodes.enumerate().map(k => {
    let (index, node) = k
    let connection-points = connection-points(index, node, nodes, node.style)
    node.connection-points = connection-points
    return node
  })

  return nodes + edges + knots
}
