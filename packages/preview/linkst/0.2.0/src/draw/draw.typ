#import "@preview/cetz:0.4.0"
#import cetz.draw: *
#import "std-style.typ": std-style
#import "compute-items.typ": compute-items
#import "resolve-debug.typ": resolve-debug
#import "../utils/lib.typ": match-dict, resolve-stroke, resolve-transform
#import "../knot/lib.typ": draw-knot
#import "../edge/lib.typ": draw-edge
#import "../node/lib.typ": draw-node


#let assign-to-layers(items) = {
  let layer-positions = items.map(item => item.layer)
  let dedup-positions = layer-positions.dedup()
  let sorted-positions = dedup-positions.sorted()

  let layers = ()
  for p in sorted-positions {
    let layer-items = items.filter(item => item.layer == p)
    layers.push(layer-items)
  }

  return layers
}

#let draw-layer(
  layer-items,
  all-items,
  style,
) = {
  // filter layer items by type
  let nodes = layer-items.filter(e => e.type == "node")
  let edges = layer-items.filter(e => e.type == "edge")
  let knots = layer-items.filter(e => e.type == "knot")

  // filter all items by type
  let all-nodes = all-items.filter(e => e.type == "node")

  // draw the items
  for knot in knots { draw-knot(knot) }
  for edge in edges { draw-edge(edge, all-nodes.at(edge.start-node), all-nodes.at(edge.end-node)) }
  for node in nodes { draw-node(node) }
}

#let draw-layers(layers, items, style) = {
  let all-items = items

  cetz.canvas(
    {
      scale(style.scale)

      if style.debug.grid {
        grid((-3, -3), (3, 3), help-lines: true)
        line((-3, 0), (3, 0), stroke: gray + 0.5pt)
        line((0, -3), (0, 3), stroke: gray + 0.5pt)
      }
      
      resolve-transform(style.transform)

      for layer-items in layers {
        draw-layer(layer-items, all-items, style)
      }
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
  // sort layers
  let layers = assign-to-layers(items)

  draw-layers(layers, items, style)
}
