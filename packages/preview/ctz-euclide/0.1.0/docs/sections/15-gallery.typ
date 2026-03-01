// Gallery Examples
#import "../helpers.typ": *

= Gallery Examples

The following pages showcase advanced geometric constructions using ctz-euclide. Each example demonstrates different features and techniques.

#full-figure(
  "Triangle Centers",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.07, fill: black))

    ctz-def-points(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

    ctz-def-centroid("G", "A", "B", "C")
    ctz-def-circumcenter("O", "A", "B", "C")
    ctz-def-incenter("I", "A", "B", "C")
    ctz-def-orthocenter("H", "A", "B", "C")

    // Euler line
    ctz-draw(segment: ("H", "O"), stroke: (
      paint: red.darken(20%),
      dash: "dashed",
      thickness: 1.2pt
    ))

    // Circumcircle
    ctz-draw(circle-through: ("O", "A"), stroke: blue + 1pt)

    // Incircle
    ctz-draw(incircle: ("A", "B", "C"), stroke: green.darken(20%) + 1pt)

    // Medians
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")
    ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.7pt)
    ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.7pt)
    ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.7pt)

    ctz-draw(points: ("A", "B", "C", "G", "O", "I", "H"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: (pos: "right", offset: (0.15, 0)),
      O: (pos: "right", offset: (0.15, 0)),
      I: (pos: "above left", offset: (-0.1, 0.1)),
      H: (pos: "left", offset: (-0.15, 0))
    ))
  },
  code: [```typst
#ctz-canvas(length: 0.95cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.07, fill: black))

  ctz-def-points(A: (0, 0), B: (7, 0.5), C: (2.5, 5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  ctz-def-centroid("G", "A", "B", "C")
  ctz-def-circumcenter("O", "A", "B", "C")
  ctz-def-incenter("I", "A", "B", "C")
  ctz-def-orthocenter("H", "A", "B", "C")

  // Euler line (H, G, O are collinear)
  ctz-draw(segment: ("H", "O"), stroke: (
    paint: red.darken(20%),
    dash: "dashed",
    thickness: 1.2pt
  ))

  // Circumcircle and incircle
  ctz-draw(circle-through: ("O", "A"), stroke: blue + 1pt)
  ctz-draw(incircle: ("A", "B", "C"), stroke: green.darken(20%) + 1pt)

  // Draw medians to centroid
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: gray + 0.7pt)
  ctz-draw(segment: ("B", "Mb"), stroke: gray + 0.7pt)
  ctz-draw(segment: ("C", "Mc"), stroke: gray + 0.7pt)

  ctz-draw(points: ("A", "B", "C", "G", "O", "I", "H"), labels: (
    A: "below left",
    B: "below right",
    C: "above",
    G: "right",
    O: "below",
    I: "right",
    H: "left"
  ))
})
```],
  length: 0.95cm,
)

#full-figure(
  "Nine-Point Circle",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (
      shape: "circle",
      size: 0.06,
      stroke: black + 0.8pt,
      fill: white,
    ))

    ctz-def-points(A: (0, 0), B: (7, 0), C: (2, 5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

    // Midpoints of sides
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")

    // Feet of altitudes
    ctz-def-project("Ha", "A", "B", "C")
    ctz-def-project("Hb", "B", "A", "C")
    ctz-def-project("Hc", "C", "A", "B")

    // Orthocenter and midpoints to vertices
    ctz-def-orthocenter("H", "A", "B", "C")
    ctz-def-midpoint("MHa", "H", "A")
    ctz-def-midpoint("MHb", "H", "B")
    ctz-def-midpoint("MHc", "H", "C")

    // Nine-point circle
    ctz-def-euler("N", "A", "B", "C")
    ctz-draw(circle-through: ("N", "Ma"), stroke: purple.darken(10%) + 1.2pt)

    // Draw altitudes
    ctz-draw(segment: ("A", "Ha"), stroke: blue.lighten(30%) + 0.7pt)
    ctz-draw(segment: ("B", "Hb"), stroke: blue.lighten(30%) + 0.7pt)
    ctz-draw(segment: ("C", "Hc"), stroke: blue.lighten(30%) + 0.7pt)

    ctz-draw(points: (
      "A", "B", "C", "N",
      "Ma", "Mb", "Mc",
      "Ha", "Hb", "Hc",
      "MHa", "MHb", "MHc",
      "H"
    ), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      N: (pos: "below", offset: (0, -0.15))
    ))
  },
  code: [```typst
#ctz-canvas(length: 0.9cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "circle", size: 0.06, stroke: black + 0.8pt, fill: white))

  ctz-def-points(A: (0, 0), B: (7, 0), C: (2, 5))
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  // Midpoints of sides
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")

  // Feet of altitudes
  ctz-def-project("Ha", "A", "B", "C")
  ctz-def-project("Hb", "B", "A", "C")
  ctz-def-project("Hc", "C", "A", "B")

  // Orthocenter and midpoints to vertices
  ctz-def-orthocenter("H", "A", "B", "C")
  ctz-def-midpoint("MHa", "H", "A")
  ctz-def-midpoint("MHb", "H", "B")
  ctz-def-midpoint("MHc", "H", "C")

  // Nine-point circle passes through all 9 points
  ctz-def-euler("N", "A", "B", "C")
  ctz-draw(circle-through: ("N", "Ma"), stroke: purple.darken(10%) + 1.2pt)

  // Draw altitudes
  ctz-draw(segment: ("A", "Ha"), stroke: blue.lighten(30%) + 0.7pt)
  ctz-draw(segment: ("B", "Hb"), stroke: blue.lighten(30%) + 0.7pt)
  ctz-draw(segment: ("C", "Hc"), stroke: blue.lighten(30%) + 0.7pt)

  ctz-draw(points: ("A", "B", "C", "N", "Ma", "Mb", "Mc", "Ha", "Hb", "Hc", "MHa", "MHb", "MHc", "H"), labels: (
    A: "left",
    B: "right",
    C: "above",
    N: "below"
  ))
})
```],
  length: 0.9cm,
)

#full-figure(
  "Regular Pentagon",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.08, fill: black))

    ctz-def-points(O: (0, 0), V1: (4, 0))
    ctz-def-regular-polygon("Pent", ("A", "B", "C", "D", "E"), "O", "V1")

    // Pentagon
    ctz-draw("Pent", stroke: black + 1.5pt)

    // All diagonals
    ctz-draw(segment: ("A", "C"), stroke: blue + 0.8pt)
    ctz-draw(segment: ("A", "D"), stroke: blue + 0.8pt)
    ctz-draw(segment: ("B", "D"), stroke: red + 0.8pt)
    ctz-draw(segment: ("B", "E"), stroke: red + 0.8pt)
    ctz-draw(segment: ("C", "E"), stroke: green.darken(20%) + 0.8pt)

    // Center
    ctz-draw(circle-r: (_pt("O"), 4), stroke: gray.lighten(50%) + 0.5pt)

    ctz-draw(points: ("A", "B", "C", "D", "E", "O"), labels: (
      A: "right",
      B: (pos: "above right", offset: (0.1, 0.1)),
      C: "above left",
      D: "below left",
      E: "below right",
      O: (pos: "below", offset: (0, -0.15))
    ))
  },
  code: [```typst
#ctz-canvas(length: 1cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))

  ctz-def-points(O: (0, 0), V1: (4, 0))
  ctz-def-regular-polygon("Pent", ("A", "B", "C", "D", "E"), "O", "V1")

  // Pentagon
  ctz-draw("Pent", stroke: black + 1.5pt)

  // All diagonals
  ctz-draw(segment: ("A", "C"), stroke: blue + 0.8pt)
  ctz-draw(segment: ("A", "D"), stroke: blue + 0.8pt)
  ctz-draw(segment: ("B", "D"), stroke: red + 0.8pt)
  ctz-draw(segment: ("B", "E"), stroke: red + 0.8pt)
  ctz-draw(segment: ("C", "E"), stroke: green.darken(20%) + 0.8pt)

  // Center
  ctz-draw(circle-r: (_pt("O"), 4), stroke: gray.lighten(50%) + 0.5pt)

  ctz-draw(points: ("A", "B", "C", "D", "E", "O"), labels: (
    A: "right",
    B: (pos: "above right", offset: (0.1, 0.1),
    C: "above left",
    D: "below left",
    E: "below right",
    O: "below"
  ))
})
```],
  length: 1cm,
)

#full-figure(
  "Inscribed Angle Theorem",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "cross", size: 0.11, stroke: black + 1.2pt))

    ctz-def-points(O: (0, 0), R: (4, 0))
    ctz-draw(circle-r: (_pt("O"), 4), stroke: black + 1.2pt)

    // Place points on circle: A left, C right, B at bottom
    ctz-def-rotation("A", "R", "O", 150)
    ctz-def-rotation("C", "R", "O", 30)
    ctz-def-rotation("B", "R", "O", 250)

    // Inscribed angle at B (looking up at chord AC)
    ctz-draw(segment: ("A", "B"), stroke: blue + 1.2pt)
    ctz-draw(segment: ("B", "C"), stroke: blue + 1.2pt)
    ctz-draw-angle(
      "B",
      "A",
      "C",
      label: $alpha$,
      radius: 0.8,
      fill: blue.lighten(70%),
      stroke: blue,
    )

    // Central angle at O (same chord AC)
    ctz-draw(segment: ("O", "A"), stroke: red + 1.2pt)
    ctz-draw(segment: ("O", "C"), stroke: red + 1.2pt)
    ctz-draw-angle(
      "O",
      "A",
      "C",
      label: $2alpha$,
      radius: 1.2,
      fill: red.lighten(70%),
      stroke: red,
    )

    // Arc
    ctz-draw(segment: ("A", "C"), stroke: gray.lighten(40%) + 0.8pt)

    ctz-draw(points: ("O", "A", "B", "C"), labels: (
      O: (pos: "below", offset: (0, -0.15)),
      A: "left",
      B: "below left",
      C: "right"
    ))
  },
  code: [```typst
#ctz-canvas(length: 1cm, {
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.11, stroke: black + 1.2pt))

  ctz-def-points(O: (0, 0), R: (4, 0))
  ctz-draw(circle-r: (_pt("O"), 4), stroke: black + 1.2pt)

  // Place points on circle
  ctz-def-rotation("A", "R", "O", 150)
  ctz-def-rotation("C", "R", "O", 30)
  ctz-def-rotation("B", "R", "O", 250)

  // Inscribed angle at B
  ctz-draw(segment: ("A", "B"), stroke: blue + 1.2pt)
  ctz-draw(segment: ("B", "C"), stroke: blue + 1.2pt)
  ctz-draw-angle("B", "A", "C", label: $alpha$, radius: 0.8,
    fill: blue.lighten(70%), stroke: blue)

  // Central angle at O (twice the inscribed angle)
  ctz-draw(segment: ("O", "A"), stroke: red + 1.2pt)
  ctz-draw(segment: ("O", "C"), stroke: red + 1.2pt)
  ctz-draw-angle("O", "A", "C", label: $2alpha$, radius: 1.2,
    fill: red.lighten(70%), stroke: red)

  ctz-draw(segment: ("A", "C"), stroke: gray.lighten(40%) + 0.8pt)
  ctz-draw(points: ("O", "A", "B", "C"), labels: (
    O: "below",
    A: "left",
    B: "right",
    C: "above"
  ))
})
```],
  length: 1cm,
)

#full-figure(
  "Apollonius Circle",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.08, fill: black))

    ctz-def-points(A: (-3, 0), B: (3, 0))

    // For k = 2, construct Apollonius circle
    // Locus of points P such that PA/PB = 2

    // External division point
    let k = 2
    ctz-def-points(E: (-5, 0))

    // Internal division point
    ctz-def-points(I: (-1, 0))

    // Center is midpoint of E and I
    ctz-def-midpoint("O", "E", "I")

    // Circle through E and I
    ctz-draw(circle-through: ("O", "E"), stroke: purple.darken(10%) + 1.3pt)

    // Show some points on the circle
    ctz-def-rotation("P1", "E", "O", 60)
    ctz-def-rotation("P2", "E", "O", 120)
    ctz-def-rotation("P3", "E", "O", -60)
    ctz-def-rotation("P4", "E", "O", -120)

    // Draw radii from P1 to A and B
    ctz-draw(segment: ("P1", "A"), stroke: blue + 0.8pt)
    ctz-draw(segment: ("P1", "B"), stroke: red + 0.8pt)

    // Base points
    ctz-draw(segment: ("A", "B"), stroke: black + 1pt)

    ctz-draw(points: ("B", "O", "E", "I", "P1", "P2", "P3", "P4"), labels: (
      B: "below",
      E: "below left",
      I: "above right",
      P1: (pos: "above", offset: (0, 0.15)),
      P2: "above",
      P3: "above",
      P4: "above",
      O: (pos: "below", offset: (0, -0.15))
    ))
  },
  code: [```typst
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

  ctz-draw(points: ( "B", "O", "E", "I", "P1", "P2", "P3", "P4"), labels: (
    B: "below right",
    E: "left",
    I: "above right",
    P1: "above",
    O: "below"
  ))
})
```],
  length: 0.95cm,
)

#full-figure(
  "Orthocenter and Altitudes",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.2pt))

    ctz-def-points(A: (0, 0), B: (8, 0), C: (2.5, 5.5))

    // Set clip region
    ctz-set-clip(-1.5, -1.5, 9.5, 7)

    // Triangle
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

    // Extended altitudes (clipped)
    ctz-def-perp("Ha1", "Ha2", ("B", "C"), "A")
    ctz-def-perp("Hb1", "Hb2", ("A", "C"), "B")
    ctz-def-perp("Hc1", "Hc2", ("A", "B"), "C")

    ctz-draw-line-global-clip("A", "Ha1", add: (1, 1.5), stroke: blue + 1pt)
    ctz-draw-line-global-clip("B", "Hb1", add: (1, 1.5), stroke: red + 1pt)
    ctz-draw-line-global-clip("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)

    // Orthocenter
    ctz-def-orthocenter("H", "A", "B", "C")

    // Feet of altitudes
    ctz-def-project("Ha", "A", "B", "C")
    ctz-def-project("Hb", "B", "A", "C")
    ctz-def-project("Hc", "C", "A", "B")

    // Right angle marks
    ctz-draw-mark-right-angle("A", "Ha", "B", size: 0.3)
    ctz-draw-mark-right-angle("B", "Hb", "C", size: 0.3)
    ctz-draw-mark-right-angle("C", "Hc", "A", size: 0.3)

    ctz-draw(points: ("A", "B", "C", "H", "Ha", "Hb", "Hc"), labels: (
      A: "left",
      B: "below",
      C: "above right",
      H: (pos: "below right", offset: (0.1, -0.05)),
      Ha: "below right",
      Hb: "right",
      Hc: "above left"
    ))
  },
  code: [```typst
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
  ctz-draw-line-global-clip("C", "Hc1", add: (1, 2.5), stroke: green.darken(20%) + 1pt)

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
    H: "right"
  ))
})
```],
  length: 0.85cm,
)

#full-figure(
  "Equilateral Triangle Construction",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

    // Base of equilateral triangle
    ctz-def-points("A", (0, 0), "B", (5, 0))

    // Construct equilateral triangle
    ctz-def-equilateral("C", "A", "B")

    // Draw triangle
    ctz-draw(line: ("A", "B", "C", "A"), stroke: blue + 1.5pt)

    // Mark 60 angles
    ctz-draw-angle("A", "B", "C", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
    ctz-draw-angle("B", "C", "A", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
    ctz-draw-angle("C", "A", "B", label: $60°$, radius: 0.8, stroke: orange + 0.8pt)

    // Draw circles at vertices
    ctz-draw(circle-r: (_pt("A"), 0.3), stroke: green + 1pt)
    ctz-draw(circle-r: (_pt("B"), 0.3), stroke: green + 1pt)
    ctz-draw(circle-r: (_pt("C"), 0.3), stroke: orange + 1pt)

    // Find center (all centers coincide in equilateral triangle)
    ctz-def-centroid("G", "A", "B", "C")

    // Draw altitudes/medians
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")

    ctz-draw(segment: ("A", "Ma"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
    ctz-draw(segment: ("B", "Mb"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
    ctz-draw(segment: ("C", "Mc"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))

    // Mark center
    ctz-style(point: (shape: "dot", size: 0.1, fill: red))
    ctz-draw(points: ("G"))

    // Mark vertices
    ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))
    ctz-draw(points: ("A", "B", "C"))

    // Labels
    ctz-draw(points: ("A", "B", "C", "G"), labels: (
      A: "left",
      B: "right",
      C: "above",
      G: "below"
    ))
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Base of equilateral triangle
  ctz-def-points("A", (0, 0), "B", (5, 0))
  ctz-def-equilateral("C", "A", "B")

  // Draw triangle
  ctz-draw(line: ("A", "B", "C", "A"), stroke: blue + 1.5pt)

  // Mark 60° angles
  ctz-draw-angle("A", "B", "C", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  ctz-draw-angle("B", "C", "A", label: $60°$, radius: 0.6, stroke: green + 0.8pt)
  ctz-draw-angle("C", "A", "B", label: $60°$, radius: 0.8, stroke: orange + 0.8pt)

  // Draw circles at vertices
  ctz-draw(circle-r: (_pt("A"), 0.3), stroke: green + 1pt)
  ctz-draw(circle-r: (_pt("B"), 0.3), stroke: green + 1pt)
  ctz-draw(circle-r: (_pt("C"), 0.3), stroke: orange + 1pt)

  // In equilateral triangle, all centers coincide
  ctz-def-centroid("G", "A", "B", "C")

  // Draw medians/altitudes
  ctz-def-midpoint("Ma", "B", "C")
  ctz-def-midpoint("Mb", "A", "C")
  ctz-def-midpoint("Mc", "A", "B")
  ctz-draw(segment: ("A", "Ma"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  ctz-draw(segment: ("B", "Mb"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))
  ctz-draw(segment: ("C", "Mc"), stroke: (paint: purple, thickness: 0.6pt, dash: "dashed"))

  ctz-draw(points: ("A", "B", "C", "G"), labels: (
    A: "left",
    B: "right",
    C: "above",
    G: "below"
  ))
})
```],
  length: 1cm,
)

#full-figure(
  "Perpendicular Bisectors and Circumcircle",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.08, fill: black))

    // Define triangle
    ctz-def-points("A", (0, 0), "B", (6, 0), "C", (2.5, 5))

    // Set clipping region
    ctz-set-clip(-1, -1, 7, 6)

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
    ctz-draw-seg-global-clip("Pab1", "Pab2", stroke: blue + 0.8pt)
    ctz-draw-seg-global-clip("Pbc1", "Pbc2", stroke: red + 0.8pt)
    ctz-draw-seg-global-clip("Pca1", "Pca2", stroke: green + 0.8pt)

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
    ctz-draw(points: ("A", "B", "C", "O", "Mab", "Mbc", "Mca"))

    // Labels
    ctz-draw(points: ("A", "B", "C", "O", "Mab", "Mbc", "Mca"), labels: (
      A: "left",
      B: "right",
      C: "above",
      O: "below"
    ))
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "dot", size: 0.08, fill: black))

  // Define triangle
  ctz-def-points("A", (0, 0), "B", (6, 0), "C", (2.5, 5))
  ctz-set-clip(-1, -1, 7, 6)

  // Calculate midpoints
  ctz-def-midpoint("Mab", "A", "B")
  ctz-def-midpoint("Mbc", "B", "C")
  ctz-def-midpoint("Mca", "C", "A")

  // Circumcenter is intersection of perpendicular bisectors
  ctz-def-circumcenter("O", "A", "B", "C")

  // Create perpendicular bisector lines
  ctz-def-mediator("Pab1", "Pab2", "A", "B")
  ctz-def-mediator("Pbc1", "Pbc2", "B", "C")
  ctz-def-mediator("Pca1", "Pca2", "C", "A")

  // Draw triangle
  ctz-draw(line: ("A", "B", "C", "A"), stroke: black + 1.5pt)

  // Draw perpendicular bisectors (clipped)
  ctz-draw-seg-global-clip("Pab1", "Pab2", stroke: blue + 0.8pt)
  ctz-draw-seg-global-clip("Pbc1", "Pbc2", stroke: red + 0.8pt)
  ctz-draw-seg-global-clip("Pca1", "Pca2", stroke: green + 0.8pt)

  // Draw circumcircle
  ctz-draw(circumcircle: ("A", "B", "C"), stroke: purple + 1.2pt)

  // Radii (equal length)
  ctz-draw(segment: ("O", "A"), stroke: gray + 0.4pt)
  ctz-draw(segment: ("O", "B"), stroke: gray + 0.4pt)
  ctz-draw(segment: ("O", "C"), stroke: gray + 0.4pt)

  ctz-draw-mark-right-angle("A", "Mab", "O", size: 0.3)
  ctz-draw-mark-right-angle("B", "Mbc", "O", size: 0.3)
  ctz-draw-mark-right-angle("C", "Mca", "O", size: 0.3)

  ctz-draw(points: ("A", "B", "C", "O", "Mab", "Mbc", "Mca"), labels: (
    A: "left",
    B: "right",
    C: "above",
    O: "below"
  ))
})
```],
  length: 0.5cm,
)

#full-figure(
  "Thales' Theorem",
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

    // Circle with diameter
    ctz-def-points("O", (0, 0), "A", (-3, 0), "B", (3, 0))

    // Point on circle
    ctz-def-point-on-circle("C", "O", 3, 110)

    // Draw circle
    ctz-draw(circle-r: (_pt("O"), 3), stroke: gray + 0.8pt)

    // Draw diameter
    ctz-draw(segment: ("A", "B"), stroke: blue + 1.2pt)

    // Draw triangle (angle at C is right angle by Thales' theorem)
    ctz-draw(line: ("A", "C", "B", "A"), stroke: black + 1.2pt)

    // Mark the right angle at C
    ctz-draw-mark-right-angle("A", "C", "B", size: 0.4)

    // Draw altitude from C to AB
    ctz-def-project("H", "C", "A", "B")
    ctz-draw(segment: ("C", "H"), stroke: (paint: green, thickness: 0.8pt, dash: "dashed"))

    // Mark points
    ctz-draw(points: ("A", "B", "C", "O", "H"))

    // Labels
    ctz-draw(points: ("A", "B", "C", "O", "H"), labels: (
      A: "left",
      B: "right",
      C: "above",
      O: "below",
      H: "below left"
    ))
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Circle with diameter AB
  ctz-def-points("O", (0, 0), "A", (-3, 0), "B", (3, 0))

  // Point C on circle
  ctz-def-point-on-circle("C", "O", 3, 110)

  // Draw circle and diameter
  ctz-draw(circle-r: (_pt("O"), 3), stroke: gray + 0.8pt)
  ctz-draw(segment: ("A", "B"), stroke: blue + 1.2pt)

  // Draw triangle ACB
  // By Thales' theorem: angle ACB = 90° (inscribed in semicircle)
  ctz-draw(line: ("A", "C", "B", "A"), stroke: black + 1.2pt)

  // Mark the right angle at C
  ctz-draw-mark-right-angle("A", "C", "B", size: 0.4)

  // Draw altitude from C to AB
  ctz-def-project("H", "C", "A", "B")
  ctz-draw(segment: ("C", "H"), stroke: (paint: green, thickness: 0.8pt, dash: "dashed"))

  ctz-draw(points: ("A", "B", "C", "O", "H"), labels: (
    A: "left",
    B: "right",
    C: "above",
    O: "below",
    H: "below left"
  ))
})
```],
  length: 1cm,
)

#full-figure(
  "Inversion",
  {
    import cetz.draw: *
    ctz-init()

    ctz-set-clip(-6, -5, 6, 6)

    ctz-def-points(
      O: (0, 0),
      A: (-5, -1.5),
      B: (5, -1.5),
      C: (2, 1),
      D: (-2, 0),
    )

    ctz-def-line("l1", "A", "B")
    ctz-def-circle("c1", "C", radius: 1.2)
    ctz-def-circle("c2", "D", radius: 2)

    ctz-def-inversion("l1i", "l1", "O", 3)
    ctz-def-inversion("c1i", "c1", "O", 3)
    ctz-def-inversion("c2i", "c2", "O", 3)

    ctz-draw(circle-r: (_pt("O"), 3), stroke: black + 1pt)

    ctz-draw("l1", stroke: gray + 0.7pt)
    ctz-draw("c1", stroke: gray + 0.7pt)
    ctz-draw("c2", stroke: gray + 0.7pt)

    ctz-draw("l1i", stroke: blue + 1.1pt)
    ctz-draw("c1i", stroke: red + 1.1pt)
    ctz-draw("c2i", stroke: green.darken(20%) + 1.1pt)

    ctz-draw(points: ("O"), labels: (O: "below left"))
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()

  ctz-set-clip(-6, -5, 6, 6)

  ctz-def-points(
    O: (0, 0),
    A: (-5, -1.5),
    B: (5, -1.5),
    C: (2, 1),
    D: (-2, 0),
  )

  ctz-def-line("l1", "A", "B")
  ctz-def-circle("c1", "C", radius: 1.2)
  ctz-def-circle("c2", "D", radius: 2)

  ctz-def-inversion("l1i", "l1", "O", 3)
  ctz-def-inversion("c1i", "c1", "O", 3)
  ctz-def-inversion("c2i", "c2", "O", 3)

  ctz-draw(circle-r: (_pt("O"), 3), stroke: black + 1pt)

  ctz-draw("l1", stroke: gray + 0.7pt)
  ctz-draw("c1", stroke: gray + 0.7pt)
  ctz-draw("c2", stroke: gray + 0.7pt)

  ctz-draw("l1i", stroke: blue + 1.1pt)
  ctz-draw("c1i", stroke: red + 1.1pt)
  ctz-draw("c2i", stroke: green.darken(20%) + 1.1pt)

  ctz-draw(points: ("O"), labels: (O: "below left"))
})
```],
  length: 0.7cm,
)

#full-figure(
  "Inversion Packing",
  {
    import cetz.draw: *
    ctz-init()

    let n = 24

    // Inversion circle setup
    ctz-def-points(O: (-4.5, 0))
    ctz-def-line("l1", (-1, 0), (-1, 1))
    ctz-def-line("l2", (1, 0), (1, 1))

    ctz-def-inversion("l1i", "l1", "O", 1)
    ctz-def-inversion("l2i", "l2", "O", 1)

    // Draw inverted lines (outer boundary)
    ctz-draw("l1i", stroke: black + 0.5pt)
    ctz-draw("l2i", stroke: black + 0.5pt)

    // Invert a stack of circles to create the packing
    for i in range(-n, n + 1) {
      let name = "c" + str(i)
      let invname = "ci" + str(i)
      ctz-def-circle(name, (0, 2 * i), radius: 1)
      ctz-def-inversion(invname, name, "O", 1)

      ctz-draw(invname, fill: yellow, stroke: red + 0.4pt)
    }
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()

  let n = 24

  // Inversion circle setup
  ctz-def-points(O: (-4.5, 0))
  ctz-def-line("l1", (-1, 0), (-1, 1))
  ctz-def-line("l2", (1, 0), (1, 1))

  ctz-def-inversion("l1i", "l1", "O", 1)
  ctz-def-inversion("l2i", "l2", "O", 1)

  // Draw inverted lines (outer boundary)
  ctz-draw("l1i", stroke: black + 0.5pt)
  ctz-draw("l2i", stroke: black + 0.5pt)

  // Invert a stack of circles to create the packing
  for i in range(-n, n + 1) {
    let name = "c" + str(i)
    let invname = "ci" + str(i)
    ctz-def-circle(name, (0, 2 * i), radius: 1)
    ctz-def-inversion(invname, name, "O", 1)

    ctz-draw(invname, fill: yellow, stroke: red + 0.4pt)
  }
})
```],
  length: 1.5cm,
)

#full-figure(
  "Inversion Ladder",
  {
    import cetz.draw: *
    ctz-init()

    let O = (-4, 0)
    let R = 3
    let n = 6

    ctz-def-line("l1", (-1, 0), (-1, 1))
    ctz-def-line("l2", (1, 0), (1, 1))
    ctz-def-inversion("l1i", "l1", O, R)
    ctz-def-inversion("l2i", "l2", O, R)

    ctz-set-clip(-2, -2, 4, 8)

    ctz-draw-line-global-clip((-1, 0), (-1, 1), add: (10, 10), stroke: blue + 0.4pt)
    ctz-draw-line-global-clip((1, 0), (1, 1), add: (10, 10), stroke: green + 0.4pt)
    ctz-draw("l1i", stroke: blue + 0.4pt)
    ctz-draw("l2i", stroke: green + 0.4pt)

    for i in range(0, n + 1) {
      let cname = "C" + str(i)
      let cpname = "Cp" + str(i)
      ctz-def-circle(cname, (0, 2 * i), radius: 1)
      ctz-def-inversion(cpname, cname, O, R)
      ctz-draw(cpname, stroke: red + 0.4pt)

      if calc.abs(i) < 4 {
        ctz-draw(cname, stroke: red + 0.4pt)

        ctz-def-points(P1: (1, 2 * i), P2: (-1, 2 * i))
        ctz-def-inversion("P1i", "P1", O, R)
        ctz-def-inversion("P2i", "P2", O, R)

        ctz-draw(segment: ("P1", "P1i"), stroke: green + 0.4pt)
        ctz-draw(segment: ("P2", "P2i"), stroke: blue + 0.4pt)
      }
    }
  },
  code: [```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()

  let O = (-4, 0)
  let R = 3
  let n = 6

  ctz-def-line("l1", (-1, 0), (-1, 1))
  ctz-def-line("l2", (1, 0), (1, 1))
  ctz-def-inversion("l1i", "l1", O, R)
  ctz-def-inversion("l2i", "l2", O, R)

  ctz-set-clip(-2, -2, 4, 8)

  ctz-draw-line-global-clip((-1, 0), (-1, 1), add: (10, 10), stroke: blue + 0.4pt)
  ctz-draw-line-global-clip((1, 0), (1, 1), add: (10, 10), stroke: green + 0.4pt)
  ctz-draw("l1i", stroke: blue + 0.4pt)
  ctz-draw("l2i", stroke: green + 0.4pt)

  for i in range(0, n + 1) {
    let cname = "C" + str(i)
    let cpname = "Cp" + str(i)
    ctz-def-circle(cname, (0, 2 * i), radius: 1)
    ctz-def-inversion(cpname, cname, O, R)
    ctz-draw(cpname, stroke: red + 0.4pt)

    if calc.abs(i) < 4 {
      ctz-draw(cname, stroke: red + 0.4pt)

      ctz-def-points(P1: (1, 2 * i), P2: (-1, 2 * i))
      ctz-def-inversion("P1i", "P1", O, R)
      ctz-def-inversion("P2i", "P2", O, R)

      ctz-draw(segment: ("P1", "P1i"), stroke: green + 0.4pt)
      ctz-draw(segment: ("P2", "P2i"), stroke: blue + 0.4pt)
    }
  }
})
```],
  length: 0.7cm,
)
