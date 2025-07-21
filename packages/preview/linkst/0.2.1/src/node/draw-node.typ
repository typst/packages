#import "@preview/cetz:0.4.0"
#import cetz.draw: *
#import cetz.vector: *
#import "draw-connections.typ": draw-connections

#let draw-connection-points(
  node,
) = {
  if(node.style.debug.connections) {
    // border circle
    circle(
      node.position,
      radius: node.style.connection-size,
      stroke: (thickness: 0.7pt, paint: rgb("#ff923988")),
    )

    // connection point inices
    for (i, connection-point) in node.connection-points.enumerate() {
      // connection point normal
      line(
        connection-point.position,
        add(connection-point.position, scale(connection-point.normal, node.style.connection-size * 0.7)),
        stroke: (thickness: 0.5pt, paint: rgb("#41bd6acb")),
      )
      
      // connection point index
      circle(
        connection-point.position,
        radius: 0.25 * node.style.connection-size,
        name: "connection-point",
        fill: rgb("#8ddce694"),
        stroke: none,
      )

      content(
        "connection-point.center",
        [#text(12pt * node.style.scale * node.style.connection-size, fill: rgb("#0000007e"))[#i]]
      )
    }
  }
}

#let draw-index(
  node,
) = {
  if(node.style.debug.nodes) {
    circle(
      "node",
      radius: 0.5 * node.style.connection-size,
      fill: rgb("#ec998a88"),
      stroke: none,
    )

    content(
      "node",
      [#text(20pt * node.style.scale * node.style.connection-size)[#node.index]]
    )
  }
}

#let draw-label(
  node,
) = {
  group(ctx => {
    let (ctx, origin) = cetz.coordinate.resolve(ctx, "node")

    let label = if(node.style.debug.nodes){[#text(fill: rgb(0, 0, 0, 100))[#node.label]]}
                else [#node.label]

    content(
      add(origin, node.label-offset),
      label,
    )
  })
}

#let draw-node(
  node,
) = {

  anchor("node", node.position)

  draw-connections(node)
  draw-label(node)
  draw-connection-points(node)
  draw-index(node)

}