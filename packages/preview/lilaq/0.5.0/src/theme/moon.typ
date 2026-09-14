#import "../typing.typ": *

#let moon = it => {
  show: set-diagram(
    // fill: rgb("#242424"),
    // xaxis: (subticks: none, mirror: false),
    // yaxis: (subticks: none, mirror: false)
  )

  show: set-grid(stroke: luma(30%))
  show: set-spine(stroke: white)

  show: set-tick(
    inset: 3pt,
  )

  show: set-legend(
    radius: 3pt,
    fill: black.transparentize(30%)
  )

  it
}
