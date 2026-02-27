#import "@preview/cetz:0.3.4"

#import "helpers.typ": arrowtip, cartesian

#let draw-state(r, phi, theta, state-color) = {
  import cetz.draw: *
  import calc: sin, cos, min

  if theta == 0deg or theta == 180deg {
    line(
      name: "state",
      (0, 0),
      (0, r * cos(theta)),
      stroke: state-color,
      mark: arrowtip(color: state-color),
    )

    return
  }

  line(
    name: "state",
    (0, 0),
    cartesian(r, phi, theta),
    stroke: state-color,
    mark: arrowtip(color: state-color),
  )
}
