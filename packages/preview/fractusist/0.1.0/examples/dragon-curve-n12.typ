#set document(date: none)


#import "@preview/fractusist:0.1.0": *


#set page(width: auto, height: auto, margin: 0pt)


#dragon-curve(
  12,
  step-size: 6,
  stroke-style: stroke(
    paint: gradient.linear(..color.map.crest, angle: 45deg),
    thickness: 3pt,
    cap: "square"
  )
)
