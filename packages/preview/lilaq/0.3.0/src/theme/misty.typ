#import "../typing.typ": *

#let misty = it => {

  show selector(title): set align(left)
  show selector(title): set text(1.2em)
  show: set-diagram(
    fill: luma(91%),
    xaxis: (subticks: none, mirror: false),
    yaxis: (subticks: none, mirror: false)
  )
  show: set-spine(
    stroke: none
  )
  show: set-grid(
    stroke: white
  )
  show: set-tick(
    stroke: .7pt,
    inset: 0pt,
    outset: 2.5pt
  )
  show: set-legend(
    position: horizon + left,
    dx: 100%,
    pad: .4em,
    stroke: none,
    fill: luma(91%)
  )

  it
}