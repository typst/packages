#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas({
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Base of equilateral triangle
  (ctz.pts)("A", (0, 0), "B", (5, 0))

  // Construct equilateral triangle
  (ctz.equilateral)("C", "A", "B")

  // Draw triangle
  line("A", "B", "C", "A", stroke: blue + 1.5pt)

  // Mark 60° angles
  (ctz.angle)("A", "B", "C", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  (ctz.angle)("B", "C", "A", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  (ctz.angle)("C", "A", "B", label: $60°$, radius: 0.8, stroke: orange + 0.8pt)

  // Draw circles at vertices
  circle("A", radius: 0.3, stroke: green + 1pt)
  circle("B", radius: 0.3, stroke: green + 1pt)
  circle("C", radius: 0.3, stroke: orange + 1pt)

  // Find center (all centers coincide in equilateral triangle)
  (ctz.centroid)("G", "A", "B", "C")

  // Draw altitudes/medians
  (ctz.midpoint)("Ma", "B", "C")
  (ctz.midpoint)("Mb", "A", "C")
  (ctz.midpoint)("Mc", "A", "B")

  line("A", "Ma", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  line("B", "Mb", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  line("C", "Mc", stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))

  // Mark center
  (ctz.style)(point: (shape: "dot", size: 0.1, fill: red))
  (ctz.points)("G")

  // Mark vertices
  (ctz.style)(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))
  (ctz.points)("A", "B", "C")

  // Labels
  (ctz.labels)("A", "B", "C", "G",
    A: "below left", B: "below right", C: "above", G: "right")
})
