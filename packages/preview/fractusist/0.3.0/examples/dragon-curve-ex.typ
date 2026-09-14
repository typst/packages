#import "@preview/fractusist:0.3.0": *

#set page(fill: none, width: auto, height: auto, margin: 0pt)

#lsystem(
  ..lsystem-use("Dragon Curve"),
  order: 12,
  step-size: 4,
  start-angle: 1,
  padding: 10,
  stroke: stroke(
    paint: gradient.linear(..color.map.crest, angle: 45deg),
    thickness: 1pt,
    cap: "square"
  )
)
