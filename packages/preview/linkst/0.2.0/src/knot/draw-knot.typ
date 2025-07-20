#import "@preview/cetz:0.4.0"
#import "../utils/resolve-transform.typ": resolve-transform
#import "../edge/lib.typ": draw-edge
#import "../node/lib.typ": draw-node
#import "../draw/compute-items.typ": compute-items

#let draw-knot(knot) = {
  import cetz.draw: *
  
  let style = knot.style
  let items = knot.items.pos()

  items = compute-items(items, style)

  let nodes = items.filter(e => e.type == "node")
  let edges = items.filter(e => e.type == "edge")

  let all-nodes = items.filter(e => e.type == "node")

  group({
    resolve-transform(knot.style.transform)

    for edge in edges { draw-edge(edge, all-nodes.at(edge.start-node), all-nodes.at(edge.end-node)) }
    for node in nodes { draw-node(node) }
  })
}
