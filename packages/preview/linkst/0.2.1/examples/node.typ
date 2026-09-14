#import "@preview/linkst:0.2.1": *

#set page(width: auto, height: auto, margin: 1cm)

#let node0 = node(
  (0, 0),
)

#let node1 = node(
  (1, 0),
)

#let node2 = node(
  (0.5, calc.sqrt(3) / 2),
)

#let nodePi = node(
  (0.5, calc.sqrt(3) / 2 / 3),
  label: text(blue, size: 30pt)[$Pi$],
  style: (connection-size: 0)
)

#draw(
  node0,
  node1,
  node2,
  nodePi,

  style: (
    scale: 2,
    debug: true,
    background: luma(10%),
    padding: 15pt,
    canvas-stroke: (paint: orange, thickness: 1pt)
  ),
)
