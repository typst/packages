#import "../typing.typ": *

#let ocean = it => {

  show: set-diagram(
    fill: rgb("#f1f1f9"),
    xaxis: (subticks: none, mirror: false),
    yaxis: (subticks: none, mirror: false)
  )
  show: set-spine(stroke: none)
  show: set-tick(
    // stroke: 0.5pt,
    inset: 0pt,
    outset: 2pt
  )
  show: set-legend(
    pad: .4em,
    stroke: none,
    radius: 0pt,
    fill: white.transparentize(30%)
  )

  it
}
