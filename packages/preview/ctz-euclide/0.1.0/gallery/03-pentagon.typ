#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 1cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

  (ctz.pts)(O: (0, 0), V1: (4, 0))
  (ctz.regular-polygon)(("A", "B", "C", "D", "E"), "O", "V1")

  // Pentagon
  line("A", "B", "C", "D", "E", "A", stroke: black + 1.5pt)

  // All diagonals
  line("A", "C", stroke: blue + 0.8pt)
  line("A", "D", stroke: blue + 0.8pt)
  line("B", "D", stroke: red + 0.8pt)
  line("B", "E", stroke: red + 0.8pt)
  line("C", "E", stroke: green.darken(20%) + 0.8pt)

  // Center
  circle("O", radius: 4, stroke: gray.lighten(50%) + 0.5pt)

  (ctz.points)("A", "B", "C", "D", "E", "O")
  (ctz.labels)(
    "A",
    "B",
    "C",
    "D",
    "E",
    A: "right",
    B: (pos: "above right", offset: (0.1, 0.1)),
    C: "above left",
    D: "below left",
    E: "below right",
  )
  (ctz.labels)("O", O: (pos: "below", offset: (0, -0.15)))
})
