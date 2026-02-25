#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.9cm, {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (
    shape: "circle",
    size: 0.06,
    stroke: black + 0.8pt,
    fill: white,
  ))

  ctz-def-points(A: (0, 0), B: (7, 0), C: (2, 5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  // Midpoints of sides
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")

  // Feet of altitudes
  ctz-def-project("Ha", "A", "B", "C")
  ctz-def-project("Hb", "B", "A", "C")
  ctz-def-project("Hc", "C", "A", "B")

  // Orthocenter and midpoints to vertices
  ctz-def-orthocenter("H", "A", "B", "C")
  ctz-def-midpoint("MHa", "H", "A")
  ctz-def-midpoint("MHb", "H", "B")
  ctz-def-midpoint("MHc", "H", "C")

  // Nine-point circle
  ctz-def-euler("N", "A", "B", "C")
  ctz-draw(circle-through: ("N", "Ma"), stroke: purple.darken(10%) + 1.2pt)

  // Draw altitudes
  ctz-draw(segment: ("A", "Ha"), stroke: blue.lighten(30%) + 0.7pt)
  ctz-draw(segment: ("B", "Hb"), stroke: blue.lighten(30%) + 0.7pt)
  ctz-draw(segment: ("C", "Hc"), stroke: blue.lighten(30%) + 0.7pt)

  ctz-draw(points: (
    "A",
    "B",
    "C",
    "N",
    "Ma",
    "Mb",
    "Mc",
    "Ha",
    "Hb",
    "Hc",
    "MHa",
    "MHb",
    "MHc",
    "H",
  ), labels: (
    A: "below left",
    B: "below right",
    C: "above",
    N: (pos: "below", offset: (0, -0.15)),
  ))
})
