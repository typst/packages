#import "../typing.typ": *


#let skyline = it => {

  show: set-diagram(
    fill: none,
    xaxis: (subticks: none, mirror: false),
    yaxis: (subticks: none, mirror: false)
  )

  show: set-grid(stroke: none)
  show: set-tick(inset: 3pt)

  show: set-legend(
    pad: .4em,
    radius: 1pt,
    fill: white.transparentize(0%)
  )

  it
}
