#import "@preview/cetz:0.4.2"

#import "helpers.typ": cartesian

#let draw-angles(r, phi, theta, angle-labels) = {
  import cetz.draw: *
  import cetz.angle

  let dir = if phi <= 206.5deg and phi > 26.5deg { "cw" } else { "ccw" }

  // Invisible line to draw the angle
  line(
    name: "state-line",
    (0, 0, 0),
    cartesian(r, phi, theta),
    stroke: none,
  )

  if theta != 0deg {
    // Project onto a 2D plane for angle drawing (cetz 0.4.2 requirement)
    let state-point = cartesian(r, phi, theta)
    let projected-x = calc.sqrt(state-point.at(0) * state-point.at(0) + state-point.at(2) * state-point.at(2))

    angle.angle(
      name: "theta",
      (0, 0, 0),
      (0, 1, 0),
      (projected-x, state-point.at(1), 0),
      direction: dir,
      radius: 0.2 * r,
    )
  }

  if angle-labels and theta != 0deg {
    content(
      "theta",
      $#math.theta$,
      anchor: if theta != 180deg {
        "south-west"
      } else { "south-east" },
      padding: (
        x: if theta != 180deg {
          -0.02
        } else { 0.1 },
        y: 0.05,
      ),
    )
  }

  if phi == 0deg or theta == 0deg or theta == 180deg {
    return
  }

  on-xz({
    arc(
      name: "phi",
      (0, 0),
      radius: 0.2 * r,
      start: 90deg,
      delta: -phi,
      anchor: "origin",
    )
  })

  if angle-labels {
    content("phi", $#math.phi.alt$, anchor: "north-west", padding: 0.02)
  }
}
