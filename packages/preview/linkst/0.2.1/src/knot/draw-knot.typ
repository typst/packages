#import "@preview/cetz:0.4.0"
#import "../utils/resolve-transform.typ": resolve-transform
#import "../edge/lib.typ": draw-edge
#import "../node/lib.typ": draw-node
#import "../draw/std-style.typ": std-style
#import "../draw/compute-items.typ": compute-items
#import "../draw/resolve-style.typ": resolve-style
#import "../draw/resolve-debug.typ": resolve-debug, false-debug

#let draw-knot(knot) = {
  import cetz.draw: *

  let style = knot.style

  // normalize style etc.
  style = resolve-style(style, none, std-style)

  let (_, edges, nodes) = compute-items(knot.items.pos(), style)

  group({
    if style.keys().any(k => k == "pre-transform") { resolve-transform(style.pre-transform) }
    scale(style.scale)
    resolve-transform(style.transform)

    for edge in edges { draw-edge(edge, nodes.at(edge.start-node), nodes.at(edge.end-node)) }
    for node in nodes { draw-node(node) }
  })
}
