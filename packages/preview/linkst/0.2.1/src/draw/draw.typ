#import "@preview/cetz:0.4.0"
#import cetz.draw: *
#import "std-style.typ": std-style
#import "compute-items.typ": compute-items
#import "resolve-debug.typ": resolve-debug
#import "../utils/lib.typ": match-dict, resolve-stroke, resolve-transform
#import "../knot/lib.typ": draw-knot
#import "../edge/lib.typ": draw-edge
#import "../node/lib.typ": draw-node

#let draw-items(items, style) = {
  // filter items by type
  let nodes = items.filter(e => e.type == "node")
  let edges = items.filter(e => e.type == "edge")
  let knots = items.filter(e => e.type == "knot")

  cetz.canvas(
    {
      scale(style.scale)

      if style.debug.grid {
        grid((-3, -3), (3, 3), help-lines: true)
        line((-3, 0), (3, 0), stroke: gray + 0.5pt)
        line((0, -3), (0, 3), stroke: gray + 0.5pt)
      }

      resolve-transform(style.transform)

      // draw the items
      for knot in knots { on-layer(knot.layer, draw-knot(knot)) }
      for edge in edges { on-layer(edge.layer, {draw-edge(edge, nodes.at(edge.start-node), nodes.at(edge.end-node))}) }
      for node in nodes { on-layer(node.layer, draw-node(node)) }
    },
    background: style.background,
    padding: style.padding,
    stroke: style.canvas-stroke,
  )
}

#let draw(
  ..items,
  style: (:),
) = {

  items = items.pos()

  // normalize style
  style = match-dict(style, std-style)
  style.debug = resolve-debug(style.debug)
  style.stroke = resolve-stroke(style.stroke)

  // fetch edge indices for nodes, get connection points, etc.
  items = compute-items(items, style)

  draw-items(items, style)
}
