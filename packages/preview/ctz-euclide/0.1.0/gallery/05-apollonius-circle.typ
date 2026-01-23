#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.95cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))
  ctz-def-points(A: (-3, 0), B: (3, 0))
  // Apollonius circle: locus of points P where PA/PB = k
  let k = 2
  // External and internal division points
  ctz-def-points(E: (-5, 0), I: (-1, 0))
  // Center is midpoint of E and I
  ctz-def-midpoint("O", "E", "I")
  ctz-draw(circle-through: ("O", "E"), stroke: purple.darken(10%) + 1.3pt)
  // Show some points on the circle
  ctz-def-rotation("P1", "E", "O", 60)
  ctz-def-rotation("P2", "E", "O", 120)
  ctz-def-rotation("P3", "E", "O", -60)
  ctz-def-rotation("P4", "E", "O", -120)
  // For P1: PA/PB = k = 2
  ctz-draw(segment: ("P1", "A"), stroke: blue + 0.8pt)
  ctz-draw(segment: ("P1", "B"), stroke: red + 0.8pt)
  ctz-draw(segment: ("A", "B"), stroke: black + 1pt)
  ctz-draw(points: ("B", "O", "E", "I", "P1", "P2", "P3", "P4"), labels: (
    
    B: "below right",
    E: "left",
    I: "above right",
    P1: "above",
    O: "below",
  ))
})
