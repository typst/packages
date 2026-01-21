#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 0.9cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (
    shape: "circle",
    size: 0.06,
    stroke: black + 0.8pt,
    fill: white,
  ))

  (ctz.pts)(A: (0, 0), B: (7, 0), C: (2, 5))
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Midpoints of sides
  (ctz.midpoint)("Ma", "B", "C")
  (ctz.midpoint)("Mb", "A", "C")
  (ctz.midpoint)("Mc", "A", "B")

  // Feet of altitudes
  (ctz.project)("Ha", "A", "B", "C")
  (ctz.project)("Hb", "B", "A", "C")
  (ctz.project)("Hc", "C", "A", "B")

  // Orthocenter and midpoints to vertices
  (ctz.orthocenter)("H", "A", "B", "C")
  (ctz.midpoint)("MHa", "H", "A")
  (ctz.midpoint)("MHb", "H", "B")
  (ctz.midpoint)("MHc", "H", "C")

  // Nine-point circle
  (ctz.euler)("N", "A", "B", "C")
  circle("N", "Ma", stroke: purple.darken(10%) + 1.2pt)

  // Draw altitudes
  line("A", "Ha", stroke: blue.lighten(30%) + 0.7pt)
  line("B", "Hb", stroke: blue.lighten(30%) + 0.7pt)
  line("C", "Hc", stroke: blue.lighten(30%) + 0.7pt)

  (ctz.points)(
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
  )
  (ctz.labels)(
    "A",
    "B",
    "C",
    "N",
    A: "below left",
    B: "below right",
    C: "above",
    N: (pos: "below", offset: (0, -0.15)),
  )
})
