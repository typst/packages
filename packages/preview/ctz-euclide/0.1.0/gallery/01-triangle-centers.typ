#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 0.95cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "dot", size: 0.07, fill: black))

  (ctz.pts)(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  (ctz.centroid)("G", "A", "B", "C")
  (ctz.circumcenter)("O", "A", "B", "C")
  (ctz.incenter)("I", "A", "B", "C")
  (ctz.orthocenter)("H", "A", "B", "C")

  // Euler line
  line("H", "O", stroke: (
    paint: red.darken(20%),
    dash: "dashed",
    thickness: 1.2pt,
  ))

  // Circumcircle
  circle("O", "A", stroke: blue + 1pt)

  // Incircle
  (ctz.incircle)("A", "B", "C", stroke: green.darken(20%) + 1pt)

  // Medians
  (ctz.midpoint)("Ma", "B", "C")
  (ctz.midpoint)("Mb", "A", "C")
  (ctz.midpoint)("Mc", "A", "B")
  line("A", "Ma", stroke: gray + 0.7pt)
  line("B", "Mb", stroke: gray + 0.7pt)
  line("C", "Mc", stroke: gray + 0.7pt)

  (ctz.points)("A", "B", "C", "G", "O", "I", "H")
  (ctz.labels)(
    "A",
    "B",
    "C",
    "G",
    "O",
    "I",
    "H",
    A: "below left",
    B: "below right",
    C: "above",
    G: (pos: "right", offset: (0.15, 0)),
    O: (pos: "right", offset: (0.15, 0)),
    I: (pos: "above left", offset: (-0.1, 0.1)),
    H: (pos: "left", offset: (-0.15, 0)),
  )
})
