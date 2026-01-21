#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas({
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

  // Define triangle
  (ctz.pts)("A", (0, 0), "B", (6, 0), "C", (2.5, 5))

  // Set clipping region
  (ctz.set-clip)(-1, -1, 7, 6)

  // Calculate midpoints
  (ctz.midpoint)("Mab", "A", "B")
  (ctz.midpoint)("Mbc", "B", "C")
  (ctz.midpoint)("Mca", "C", "A")

  // Calculate circumcenter (intersection of perpendicular bisectors)
  (ctz.circumcenter)("O", "A", "B", "C")

  // Create perpendicular bisector lines
  (ctz.mediator)("Pab1", "Pab2", "A", "B")
  (ctz.mediator)("Pbc1", "Pbc2", "B", "C")
  (ctz.mediator)("Pca1", "Pca2", "C", "A")

  // Draw triangle
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Draw perpendicular bisectors (clipped)
  (ctz.seg)("Pab1", "Pab2", stroke: blue + 0.8pt)
  (ctz.seg)("Pbc1", "Pbc2", stroke: red + 0.8pt)
  (ctz.seg)("Pca1", "Pca2", stroke: green + 0.8pt)

  // Draw circumcircle
  (ctz.circumcircle)("A", "B", "C", stroke: purple + 1.2pt)

  // Draw segments from circumcenter to vertices
  line("O", "A", stroke: gray + 0.4pt)
  line("O", "B", stroke: gray + 0.4pt)
  line("O", "C", stroke: gray + 0.4pt)

  // Mark right angles at midpoints
  (ctz.mark-right-angle)("A", "Mab", "O", size: 0.3)
  (ctz.mark-right-angle)("B", "Mbc", "O", size: 0.3)
  (ctz.mark-right-angle)("C", "Mca", "O", size: 0.3)

  // Mark points
  (ctz.points)("A", "B", "C", "O", "Mab", "Mbc", "Mca")

  // Labels
  (ctz.labels)("A", "B", "C", "O",
    A: "below left", B: "below right", C: "above", O: "below")
})
