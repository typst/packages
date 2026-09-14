// Circles
#import "../helpers.typ": *

= Circles

This section covers all circle-related functions. Every circle drawing method has a corresponding define function, allowing you to store circles as named objects for later use (intersections, transformations, etc.).

== Define vs Draw Pattern

For each way of creating a circle, there are two approaches:

1. *Define then Draw*: Store the circle as a named object, then draw it by name. This allows reusing the circle for intersections.
2. *Draw directly*: Use `ctz-draw()` with a type parameter to draw without storing.

```typst
// Approach 1: Define then draw (reusable)
ctz-def-circumcircle("C", "A", "B", "C")
ctz-draw("C", stroke: blue)
ctz-def-lc(("P", "Q"), ("A", "B"), "C")  // Can intersect with line

// Approach 2: Draw directly (one-off)
ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
```

== Circle by Center and Radius — `ctz-def-circle`

Define a circle by its center and either a radius value or a point on the circumference.

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0), A: (2, 0))

    // By radius value
    ctz-def-circle("C1", "O", radius: 1.5)
    ctz-draw("C1", stroke: blue)

    // By through point
    ctz-def-circle("C2", "O", through: "A")
    ctz-draw("C2", stroke: red)

    ctz-draw(points: ("O", "A"), labels: (O: "below", A: "right"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0), A: (2, 0))
    ctz-def-circle("C1", "O", radius: 1.5)
    ctz-draw("C1", stroke: blue)
    ctz-def-circle("C2", "O", through: "A")
    ctz-draw("C2", stroke: red)
    ctz-draw(points: ("O", "A"), labels: (O: "below", A: "right"))
  },
)

Unnamed equivalents:
```typst
ctz-draw(circle-r: ((0, 0), 1.5), stroke: blue)
ctz-draw(circle-through: ("O", "A"), stroke: red)
```

== Circle by Diameter — `ctz-def-circle-diameter`

Define a circle using two points as the diameter endpoints.

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (-2, 0), B: (2, 0))

    ctz-def-circle-diameter("C", "A", "B")
    ctz-draw("C", stroke: purple)

    ctz-draw(points: ("A", "B"), labels: (A: "left", B: "right"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (-2, 0), B: (2, 0))
    ctz-def-circle-diameter("C", "A", "B")
    ctz-draw("C", stroke: purple)
    ctz-draw(points: ("A", "B"), labels: (A: "left", B: "right"))
  },
)

Unnamed equivalent:
```typst
ctz-draw(circle-diameter: ("A", "B"), stroke: purple)
```

== Circumcircle — `ctz-def-circumcircle`

Define the circumscribed circle of a triangle (passes through all three vertices).

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))

    ctz-def-circumcircle("circ", "A", "B", "C")
    ctz-draw("circ", stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-def-circumcircle("circ", "A", "B", "C")
    ctz-draw("circ", stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  },
)

Unnamed equivalent:
```typst
ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
```

== Incircle — `ctz-def-incircle`

Define the inscribed circle of a triangle (tangent to all three sides).

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))

    ctz-def-incircle("inc", "A", "B", "C")
    ctz-draw("inc", stroke: red)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-def-incircle("inc", "A", "B", "C")
    ctz-draw("inc", stroke: red)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  },
)

Unnamed equivalent:
```typst
ctz-draw(incircle: ("A", "B", "C"), stroke: red)
```

== Excircle — `ctz-def-excircle`

Define an excircle of a triangle (tangent to one side and the extensions of the other two sides). The `vertex` parameter specifies which vertex the excircle is opposite to.

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))

    ctz-def-excircle("excA", "A", "B", "C", vertex: "a")
    ctz-def-excircle("excB", "A", "B", "C", vertex: "b")
    ctz-def-excircle("excC", "A", "B", "C", vertex: "c")

    ctz-draw("excA", stroke: red)
    ctz-draw("excB", stroke: green)
    ctz-draw("excC", stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-def-excircle("excA", "A", "B", "C", vertex: "a")
    ctz-def-excircle("excB", "A", "B", "C", vertex: "b")
    ctz-def-excircle("excC", "A", "B", "C", vertex: "c")
    ctz-draw("excA", stroke: red)
    ctz-draw("excB", stroke: green)
    ctz-draw("excC", stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  },
  length: 0.5cm,
)

== Nine-Point (Euler) Circle — `ctz-def-euler-circle`

Define the nine-point circle of a triangle. This circle passes through nine significant points: the midpoints of the three sides, the feet of the three altitudes, and the midpoints of the segments from vertices to the orthocenter.

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1.5, 3))

    ctz-def-euler-circle("euler", "A", "B", "C")
    ctz-def-circumcircle("circ", "A", "B", "C")

    ctz-draw("circ", stroke: blue + 0.5pt)
    ctz-draw("euler", stroke: orange + 1pt)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1.5, 3))
    ctz-def-euler-circle("euler", "A", "B", "C")
    ctz-def-circumcircle("circ", "A", "B", "C")
    ctz-draw("circ", stroke: blue + 0.5pt)
    ctz-draw("euler", stroke: orange + 1pt)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  },
)

The nine-point circle has radius equal to half the circumradius.

== Spieker Circle — `ctz-def-spieker-circle`

Define the Spieker circle of a triangle (the incircle of the medial triangle).

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1.5, 3))

    // Medial triangle
    ctz-def-medial-triangle("Ma", "Mb", "Mc", "A", "B", "C")

    ctz-def-spieker-circle("spieker", "A", "B", "C")
    ctz-def-incircle("inc", "A", "B", "C")

    ctz-draw("inc", stroke: red + 0.5pt)
    ctz-draw("spieker", stroke: teal + 1pt)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(line: ("Ma", "Mb", "Mc", "Ma"), stroke: gray)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1.5, 3))
    ctz-def-medial-triangle("Ma", "Mb", "Mc", "A", "B", "C")
    ctz-def-spieker-circle("spieker", "A", "B", "C")
    ctz-def-incircle("inc", "A", "B", "C")
    ctz-draw("inc", stroke: red + 0.5pt)
    ctz-draw("spieker", stroke: teal + 1pt)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(line: ("Ma", "Mb", "Mc", "Ma"), stroke: gray)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left", B: "below right", C: "above"))
  },
)

== Apollonius Circle — `ctz-def-apollonius-circle`

Define an Apollonius circle — the locus of points P such that the ratio PA/PB equals a constant k.

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (-2, 0), B: (2, 0))

    // Circles for different ratios
    ctz-def-apollonius-circle("ap2", "A", "B", 2)
    ctz-def-apollonius-circle("ap3", "A", "B", 3)
    ctz-def-apollonius-circle("ap05", "A", "B", 0.5)

    ctz-draw("ap2", stroke: blue)
    ctz-draw("ap3", stroke: red)
    ctz-draw("ap05", stroke: green)

    ctz-draw(points: ("A", "B"), labels: (A: "below", B: "below"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (-2, 0), B: (2, 0))
    ctz-def-apollonius-circle("ap2", "A", "B", 2)
    ctz-def-apollonius-circle("ap3", "A", "B", 3)
    ctz-def-apollonius-circle("ap05", "A", "B", 0.5)
    ctz-draw("ap2", stroke: blue)
    ctz-draw("ap3", stroke: red)
    ctz-draw("ap05", stroke: green)
    ctz-draw(points: ("A", "B"), labels: (A: "below", B: "below"))
  },
)

Note: When k = 1, the locus is the perpendicular bisector of AB (a line, not a circle).

== Circle Labels — `ctz-label-circle`

Place a label relative to a named circle:

```typst
ctz-def-circle("C1", "O", radius: 2)
ctz-draw("C1", stroke: blue)
ctz-label-circle("C1", $C_1$, pos: "above right", dist: 0.2)
```

Parameters:
- `pos`: Position around the circle (`"above"`, `"below"`, `"left"`, `"right"`, or combinations)
- `dist`: Distance from the circle edge
- `offset`: Additional (x, y) offset

#pagebreak()

== Summary: Circle Functions

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Define Function*], [*Draw Shorthand*], [*Description*],
  [`ctz-def-circle(name, center, radius: r)`], [`circle-r: (center, r)`], [Circle by center and radius],
  [`ctz-def-circle(name, center, through: pt)`], [`circle-through: (center, pt)`], [Circle through point],
  [`ctz-def-circle-diameter(name, a, b)`], [`circle-diameter: (a, b)`], [Circle by diameter],
  [`ctz-def-circumcircle(name, a, b, c)`], [`circumcircle: (a, b, c)`], [Circumcircle of triangle],
  [`ctz-def-incircle(name, a, b, c)`], [`incircle: (a, b, c)`], [Incircle of triangle],
  [`ctz-def-excircle(name, a, b, c, vertex: v)`], [—], [Excircle opposite to vertex],
  [`ctz-def-euler-circle(name, a, b, c)`], [—], [Nine-point circle],
  [`ctz-def-spieker-circle(name, a, b, c)`], [—], [Spieker circle],
  [`ctz-def-apollonius-circle(name, a, b, k)`], [—], [Apollonius circle (ratio k)],
)

All defined circles can be:
- Drawn with `ctz-draw("name", stroke: ..., fill: ...)`
- Used in circle-circle intersections: `ctz-def-cc(("P", "Q"), "circle1", "circle2")`
- Used in line-circle intersections: `ctz-def-lc(("P", "Q"), line, "circle")`

