#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 0.95cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "dot", size: 0.08, fill: black))

  (ctz.pts)(A: (-3, 0), B: (3, 0))

  // For k = 2, construct Apollonius circle
  // Locus of points P such that PA/PB = 2

  // External division point
  let k = 2
  (ctz.pts)(E: (-5, 0))

  // Internal division point
  (ctz.pts)(I: (-1, 0))

  // Center is midpoint of E and I
  (ctz.midpoint)("O", "E", "I")

  // Circle through E and I
  circle("O", "E", stroke: purple.darken(10%) + 1.3pt)

  // Show some points on the circle
  (ctz.rotate)("P1", "E", "O", 60)
  (ctz.rotate)("P2", "E", "O", 120)
  (ctz.rotate)("P3", "E", "O", -60)
  (ctz.rotate)("P4", "E", "O", -120)

  // Draw radii from P1 to A and B
  line("P1", "A", stroke: blue + 0.8pt)
  line("P1", "B", stroke: red + 0.8pt)

  // Base points
  line("A", "B", stroke: black + 1pt)

  (ctz.points)("A", "B", "O", "E", "I", "P1", "P2", "P3", "P4")
  (ctz.labels)(
    "A",
    "B",
    "E",
    "I",
    "P1",
    A: "below",
    B: "below",
    E: "below left",
    I: "below",
    P1: (pos: "above", offset: (0, 0.15)),
  )
  (ctz.labels)("O", O: (pos: "below", offset: (0, -0.15)))
})
