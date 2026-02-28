#import "@preview/cetz:0.4.2"

#import "helpers.typ": arrowtip, cartesian

#let draw-state(r, phi, theta, state-color) = {
  import cetz.draw: *
  import calc: cos, min, sin

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
