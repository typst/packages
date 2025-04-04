#import "@preview/fractusist:0.3.0": *

#set page(fill: none, width: auto, height: auto, margin: 0pt)

#lsystem(
  ..lsystem-use("Sierpinski Triangle"),
  order: 6,
  step-size: 4,
  start-angle: 1,
  padding: 10,
  fill: gradient.linear(..color.map.crest, angle: 45deg),
  stroke: none
)
