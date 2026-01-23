#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.85cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.2pt))
  ctz-def-points(A: (0, 0), B: (8, 0), C: (2.5, 5.5))
  ctz-set-clip(-1.5, -1.5, 9.5, 7)
  // Triangle
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)
  // Extended altitudes (automatically clipped)
  ctz-def-perp("Ha1", "Ha2", ("B", "C"), "A")
  ctz-def-perp("Hb1", "Hb2", ("A", "C"), "B")
  ctz-def-perp("Hc1", "Hc2", ("A", "B"), "C")
  ctz-draw-line-global-clip("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
  ctz-draw-line-global-clip("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
  ctz-draw-line-global-clip(
    "C",
    "Hc1",
    add: (1, 2.5),
    stroke: green.darken(20%) + 1pt,
  )
  // Orthocenter (intersection of altitudes)
  ctz-def-orthocenter("H", "A", "B", "C")
  // Feet of altitudes
  ctz-def-project("Ha", "A", "B", "C")
  ctz-def-project("Hb", "B", "A", "C")
  ctz-def-project("Hc", "C", "A", "B")
  ctz-draw-mark-right-angle("A", "Ha", "B", size: 0.3)
  ctz-draw-mark-right-angle("B", "Hb", "C", size: 0.3)
  ctz-draw-mark-right-angle("C", "Hc", "A", size: 0.3)
  ctz-draw(points: ("A", "B", "C", "H", "Ha", "Hb", "Hc"), labels: (
    
    A: "left",
    B: "below",
    C: "above right",
    H: "right",
  ))
})
