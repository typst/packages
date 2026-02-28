#import "@preview/cetz:0.4.2"

#let draw-polar-labels() = {
  import cetz.draw: *

  circle(
    name: "N",
    (0, 1, 0),
    radius: 0.03,
    stroke: black,
    fill: white,
  )

  circle(
    name: "S",
    (0, -1, 0),
    radius: 0.03,
    stroke: black,
    fill: white,
  )

  content(
    "N",
    anchor: "south-east",
    $lr(| 0 chevron.r)$,
    padding: 0.04,
  )

  content(
    "S",
    anchor: "north-west",
    $lr(| 1 chevron.r)$,
    padding: 0.04,
  )
}
