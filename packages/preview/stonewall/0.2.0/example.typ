#import "@preview/stonewall:0.2.0": flags

#set page(width: 200pt, height: auto, margin: 0pt)
#set text(fill: black, size: 12pt)
#set text(top-edge: "bounds", bottom-edge: "bounds")


#stack(
  spacing: 3pt,
  ..flags.map(((name, preset)) => block(
    width: 100%,
    height: 20pt,
    fill: gradient.linear(..preset),
    align(center + horizon, smallcaps(name)),
  ))
)
