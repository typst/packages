#import "@preview/ctz-euclide:0.1.5": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.95cm, {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.07, fill: black))

  ctz-def-points(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  ctz-def-centroid("G", "A", "B", "C")
  ctz-def-circumcenter("O", "A", "B", "C")
  ctz-def-incenter("I", "A", "B", "C")
  ctz-def-orthocenter("H", "A", "B", "C")

  // Euler line
  ctz-draw(segment: ("H", "O"), stroke: (
    paint: red.darken(20%),
    dash: "dashed",
    thickness: 1.2pt,
  ))

  // Circumcircle
  ctz-draw(circle-through: ("O", "A"), stroke: blue + 1pt)

  // Incircle
  ctz-draw(incircle: ("A", "B", "C"), stroke: green.darken(20%) + 1pt)

  // Medians
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.7pt)
  ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.7pt)
  ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.7pt)

  ctz-draw(points: ("A", "B", "C", "G", "O", "I", "H"), labels: (
    A: "below left",
    B: "below right",
    C: "above",
    G: (pos: "right", offset: (0.15, 0)),
    O: (pos: "right", offset: (0.15, 0)),
    I: (pos: "above left", offset: (-0.1, 0.1)),
    H: (pos: "left", offset: (-0.15, 0)),
  ))
})
