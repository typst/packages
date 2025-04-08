#import "@preview/fractusist:0.2.0": *

#set page(fill: none, width: auto, height: auto, margin: 10pt)

#dragon-curve(
  12,
  step-size: 4,
  stroke: stroke(
    paint: gradient.linear(..color.map.crest, angle: 45deg),
    thickness: 1pt,
    cap: "square"
  )
)
