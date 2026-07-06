// Triangle Centers
#import "../helpers.typ": *

= Triangle Centers

== Basic Centers

=== Centroid — `ctz-def-centroid`

The intersection of medians (center of mass):

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-centroid("G", "A", "B", "C")

    // Draw medians
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(segment: ("A", "Ma"), stroke: blue + 0.5pt)
    ctz-draw(segment: ("B", "Mb"), stroke: blue + 0.5pt)
    ctz-draw(segment: ("C", "Mc"), stroke: blue + 0.5pt)

    ctz-draw(points: ("A", "B", "C", "G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "above right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-centroid("G", "A", "B", "C")
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(segment: ("A", "Ma"), stroke: blue + 0.5pt)
    ctz-draw(segment: ("B", "Mb"), stroke: blue + 0.5pt)
    ctz-draw(segment: ("C", "Mc"), stroke: blue + 0.5pt)
    ctz-draw(points: ("A", "B", "C", "G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "above right"
    ))
  },
)

=== Circumcenter — `ctz-def-circumcenter`

Center of the circumscribed circle:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-circumcenter("O", "A", "B", "C")

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(circle-through: ("O", "A"), stroke: blue + 0.7pt)

    ctz-draw(segment: ("O", "A"), stroke: gray + 0.5pt)
    ctz-draw(segment: ("O", "B"), stroke: gray + 0.5pt)
    ctz-draw(segment: ("O", "C"), stroke: gray + 0.5pt)

    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      O: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-circumcenter("O", "A", "B", "C")
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(circle-through: ("O", "A"), stroke: blue + 0.7pt)
    ctz-draw(segment: ("O", "A"), stroke: gray + 0.5pt)
    ctz-draw(segment: ("O", "B"), stroke: gray + 0.5pt)
    ctz-draw(segment: ("O", "C"), stroke: gray + 0.5pt)
    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      O: "below"
    ))
  },
  length: 0.75cm,
)

=== Incenter — `ctz-def-incenter`

Center of the inscribed circle:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-incenter("I", "A", "B", "C")

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(incircle: ("A", "B", "C"), stroke: green + 0.7pt)

    ctz-draw(points: ("A", "B", "C", "I"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      I: "below right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-incenter("I", "A", "B", "C")
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(incircle: ("A", "B", "C"), stroke: green + 0.7pt)
    ctz-draw(points: ("A", "B", "C", "I"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      I: "below right"
    ))
  },
  length: 0.75cm,
)

=== Orthocenter — `ctz-def-orthocenter`

Intersection of altitudes:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-orthocenter("H", "A", "B", "C")

    // Altitudes
    ctz-def-perp("Ha1", "Ha2", ("B", "C"), "A")
    ctz-def-perp("Hb1", "Hb2", ("A", "C"), "B")
    ctz-def-perp("Hc1", "Hc2", ("A", "B"), "C")

    ctz-set-clip(-0.5, -0.5, 5.5, 4)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-line-global-clip("A", "Ha1", add: (2, 2), stroke: red + 0.5pt)
    ctz-draw-line-global-clip("B", "Hb1", add: (2, 2), stroke: red + 0.5pt)
    ctz-draw-line-global-clip("C", "Hc1", add: (2, 2), stroke: red + 0.5pt)

    ctz-draw(points: ("A", "B", "C", "H"), labels: (
      A: "left",
      B: "right",
      C: "above right",
      H: "below right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (2, 3.5))
    ctz-def-orthocenter("H", "A", "B", "C")
    ctz-def-perp("Ha1", "Ha2", ("B", "C"), "A")
    ctz-def-perp("Hb1", "Hb2", ("A", "C"), "B")
    ctz-def-perp("Hc1", "Hc2", ("A", "B"), "C")
    ctz-set-clip(-0.5, -0.5, 5.5, 4)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-line-global-clip("A", "Ha1", add: (2, 2), stroke: red + 0.5pt)
    ctz-draw-line-global-clip("B", "Hb1", add: (2, 2), stroke: red + 0.5pt)
    ctz-draw-line-global-clip("C", "Hc1", add: (2, 2), stroke: red + 0.5pt)
    ctz-draw(points: ("A", "B", "C", "H"), labels: (
      A: "left",
      B: "right",
      C: "above right",
      H: "below right"
    ))
  },
  length: 0.75cm,
)

== The Euler Line

In any non-equilateral triangle, the orthocenter $H$, centroid $G$, and circumcenter $O$ are collinear. This line is called the *Euler line*, and remarkably, $G$ divides $H O$ in the ratio $2:1$.

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (1.5, 3.5))

    ctz-def-orthocenter("H", "A", "B", "C")
    ctz-def-centroid("G", "A", "B", "C")
    ctz-def-circumcenter("O", "A", "B", "C")

    ctz-set-clip(-0.5, -0.5, 5.5, 4)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-line-add("H", "O", add: 0.5, stroke: (paint: red, dash: "dashed"))
    ctz-draw(circle-through: ("O", "A"), stroke: blue + 0.6pt)

    ctz-draw(points: ("A", "B", "C", "H", "G", "O"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      H: "left",
      G: "below",
      O: "right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    ctz-def-orthocenter("H", "A", "B", "C")
    ctz-def-centroid("G", "A", "B", "C")
    ctz-def-circumcenter("O", "A", "B", "C")
    ctz-set-clip(-0.5, -0.5, 5.5, 4)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-line-add("H", "O", add: 0.5, stroke: (paint: red, dash: "dashed"))
    ctz-draw(circle-through: ("O", "A"), stroke: blue + 0.6pt)
    ctz-draw(points: ("A", "B", "C", "H", "G", "O"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      H: "left",
      G: "below",
      O: "right"
    ))
  },
  length: 0.75cm,
)

== Right Triangles via Thales' Theorem

Thales' theorem states that any triangle inscribed in a semicircle with the diameter as its base has a right angle at the opposite vertex. The `ctz-def-thales-triangle()` function creates such triangles.

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0))
    ctz-def-thales-triangle("A", "B", "C", "O", 2.5,
      base-angle: 30, orientation: "left")

    ctz-draw(circle-r: (_pt("O"), 2.5), stroke: gray + 0.5pt)
    ctz-draw-path("A--B--C--A", stroke: black + 1pt)
    ctz-draw-mark-right-angle("A", "C", "B", color: red)

    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "right",
      B: "left",
      C: "above",
      O: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0))
    ctz-def-thales-triangle("A", "B", "C", "O", 2.5,
      base-angle: 30, orientation: "left")
    ctz-draw(circle-r: (_pt("O"), 2.5), stroke: gray + 0.5pt)
    ctz-draw-path("A--B--C--A", stroke: black + 1pt)
    ctz-draw-mark-right-angle("A", "C", "B", color: red)
    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "right",
      B: "left",
      C: "above",
      O: "below"
    ))
  },
  length: 0.75cm,
)

Parameters:
- `name-a, name-b`: Diameter endpoints (base of triangle)
- `name-c`: Vertex with the right angle
- `center`: Circle center
- `radius`: Circle radius
- `base-angle`: Rotation angle for the diameter (default: 0)
- `orientation`: "left" or "right" - position of right angle vertex

#pagebreak()

== Advanced Centers

`ctz-euclide` supports 10+ specialized triangle centers:

- `ctz-def-lemoine` — Symmedian point (Lemoine point)
- `ctz-def-nagel` — Nagel point
- `ctz-def-gergonne` — Gergonne point
- `ctz-def-spieker` — Spieker center (incenter of medial triangle)
- `ctz-def-euler` — Nine-point circle center
- `ctz-def-feuerbach` — Feuerbach point
- `ctz-def-mittenpunkt` — Mittenpunkt
- `ctz-def-excenter` — Excenter (specify vertex: `"a"`, `"b"`, or `"c"`)

Example with Euler (nine-point) circle:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    ctz-def-euler("N", "A", "B", "C")

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    // Nine-point circle passes through midpoints
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")

    ctz-draw(circle-through: ("N", "Ma"), stroke: purple + 0.7pt)

    ctz-draw(points: ("A", "B", "C", "N", "Ma", "Mb", "Mc"), labels: (
      N: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 0), C: (1.5, 3.5))
    ctz-def-euler("N", "A", "B", "C")
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-def-midpoint("Ma", "B", "C")
    ctz-def-midpoint("Mb", "A", "C")
    ctz-def-midpoint("Mc", "A", "B")
    ctz-draw(circle-through: ("N", "Ma"), stroke: purple + 0.7pt)
    ctz-draw(points: ("A", "B", "C", "N", "Ma", "Mb", "Mc"), labels: (
      N: "below"
    ))
  },
  length: 0.7cm,
)

#pagebreak()

