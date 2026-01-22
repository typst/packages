#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas({
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Base of equilateral triangle
  ctz-def-points("A", (0, 0), "B", (5, 0))

  // Construct equilateral triangle
  ctz-def-equilateral("C", "A", "B")

  // Draw triangle
  ctz-draw-line("A", "B", "C", "A", stroke: blue + 1.5pt)

  // Mark 60 angles
  ctz-draw-angle("A", "B", "C", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  ctz-draw-angle("B", "C", "A", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  ctz-draw-angle("C", "A", "B", label: $60°$, radius: 0.8, stroke: orange + 0.8pt)

  // Draw circles at vertices
  ctz-draw-circle-r("A", 0.3, stroke: green + 1pt)
  ctz-draw-circle-r("B", 0.3, stroke: green + 1pt)
  ctz-draw-circle-r("C", 0.3, stroke: orange + 1pt)

  // Find center (all centers coincide in equilateral triangle)
  ctz-def-centroid("G", "A", "B", "C")

  // Draw altitudes/medians
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")

  ctz-draw-line("A", "Ma", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  ctz-draw-line("B", "Mb", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  ctz-draw-line("C", "Mc", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))

  // Mark center
  ctz-style(point: (shape: "dot", size: 0.1, fill: red))
  ctz-draw-points("G")

  // Mark vertices
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))
  ctz-draw-points("A", "B", "C")

  // Labels
  ctz-draw-labels("A", "B", "C", "G",
    A: "below left", B: "below right", C: "above", G: "right")
})
