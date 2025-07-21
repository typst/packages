#import "@preview/cetz:0.4.0"
#import "../utils/resolve-transform.typ": resolve-transform
#import "../edge/lib.typ": draw-edge
#import "../node/lib.typ": draw-node
#import "../draw/compute-items.typ": compute-items

#let draw-knot(knot) = {
  import cetz.draw: *

  let style = knot.style

  let (_, edges, nodes) = compute-items(knot.items.pos(), style)

  group({
    resolve-transform(style.transform)

    for edge in edges { draw-edge(edge, nodes.at(edge.start-node), nodes.at(edge.end-node)) }
    for node in nodes { draw-node(node) }
  })
}
