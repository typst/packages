#import "@preview/fractusist:0.2.0": *

#set page(fill: none, width: auto, height: auto, margin: 10pt)

#sierpinski-triangle(
  6,
  step-size: 5,
  fill: gradient.linear(..color.map.crest, angle: 45deg),
  stroke: none
)
