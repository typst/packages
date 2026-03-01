#import "@preview/ctz-euclide:0.1.5": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(clip-canvas: (-1, -1, 7, 6), {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))

  // Define triangle
  ctz-def-points("A", (0, 0), "B", (6, 0), "C", (2.5, 5))

  // Calculate midpoints
  ctz-def-midpoint("Mab", "A", "B")
  ctz-def-midpoint("Mbc", "B", "C")
  ctz-def-midpoint("Mca", "C", "A")

  // Calculate ctz-def-circumcenter(intersection of perpendicular bisectors)
  ctz-def-circumcenter("O", "A", "B", "C")

  // Create perpendicular bisector lines
  ctz-def-mediator("Pab1", "Pab2", "A", "B")
  ctz-def-mediator("Pbc1", "Pbc2", "B", "C")
  ctz-def-mediator("Pca1", "Pca2", "C", "A")

  // Draw triangle
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  // Draw perpendicular bisectors (clipped)
  ctz-draw-segment("Pab1", "Pab2", stroke: blue + 0.8pt)
  ctz-draw-segment("Pbc1", "Pbc2", stroke: red + 0.8pt)
  ctz-draw-segment("Pca1", "Pca2", stroke: green + 0.8pt)

  // Draw circumcircle
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: purple + 1.2pt)

  // Draw segments from circumcenter to vertices
  ctz-draw(segment: ("O", "A"), stroke: gray + 0.4pt)
  ctz-draw(segment: ("O", "B"), stroke: gray + 0.4pt)
  ctz-draw(segment: ("O", "C"), stroke: gray + 0.4pt)

  // Mark right angles at midpoints
  ctz-draw-mark-right-angle("A", "Mab", "O", size: 0.3)
  ctz-draw-mark-right-angle("B", "Mbc", "O", size: 0.3)
  ctz-draw-mark-right-angle("C", "Mca", "O", size: 0.3)

  // Mark points
  ctz-draw(points: ("A", "B", "C", "O", "Mab", "Mbc", "Mca"), labels: (
    A: "below left", B: "below right", C: "above", O: "below"))
})
