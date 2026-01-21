#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 0.85cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "cross", size: 0.1, stroke: black + 1.2pt))

  (ctz.pts)(A: (0, 0), B: (8, 0), C: (2.5, 5.5))

  // Set clip region
  (ctz.set-clip)(-1.5, -1.5, 9.5, 7)

  // Triangle
  line("A", "B", "C", "A", stroke: black + 1.5pt)

  // Extended altitudes (clipped)
  (ctz.perp)("Ha1", "Ha2", ("B", "C"), "A")
  (ctz.perp)("Hb1", "Hb2", ("A", "C"), "B")
  (ctz.perp)("Hc1", "Hc2", ("A", "B"), "C")

  (ctz.line)("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
  (ctz.line)("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
  (ctz.line)("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)

  // Orthocenter
  (ctz.orthocenter)("H", "A", "B", "C")

  // Feet of altitudes
  (ctz.project)("Ha", "A", "B", "C")
  (ctz.project)("Hb", "B", "A", "C")
  (ctz.project)("Hc", "C", "A", "B")

  // Right angle marks
  (ctz.mark-right-angle)("A", "Ha", "B", size: 0.3)
  (ctz.mark-right-angle)("B", "Hb", "C", size: 0.3)
  (ctz.mark-right-angle)("C", "Hc", "A", size: 0.3)

  (ctz.points)("A", "B", "C", "H", "Ha", "Hb", "Hc")
  (ctz.labels)(
    "A",
    "B",
    "C",
    "H",
    A: "below left",
    B: "below right",
    C: "above",
    H: (pos: "below right", offset: (0.1, -0.05)),
  )
})
