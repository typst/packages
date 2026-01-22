#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 1cm, {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))

  ctz-def-points(O: (0, 0), V1: (4, 0))
  ctz-def-regular-polygon("Pent", ("A", "B", "C", "D", "E"), "O", "V1")

  // Pentagon
  ctz-draw-polygon("Pent", stroke: black + 1.5pt)

  // All diagonals
  ctz-draw-line("A", "C", stroke: blue + 0.8pt)
  ctz-draw-line("A", "D", stroke: blue + 0.8pt)
  ctz-draw-line("B", "D", stroke: red + 0.8pt)
  ctz-draw-line("B", "E", stroke: red + 0.8pt)
  ctz-draw-line("C", "E", stroke: green.darken(20%) + 0.8pt)

  // Center
  ctz-def-circle("C1", "O", radius: 4)
  ctz-draw-circle("C1", stroke: gray.lighten(50%) + 0.5pt)
  ctz-label-polygon("Pent", $P_1$, pos: "center")

  ctz-draw-points("A", "B", "C", "D", "E", "O")
  ctz-draw-labels(
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
  ctz-draw-labels("O", O: (pos: "below", offset: (0, -0.15)))
})
