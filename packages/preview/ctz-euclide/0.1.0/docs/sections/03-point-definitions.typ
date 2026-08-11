// Point Definitions
#import "../helpers.typ": *

= Point Definitions

== Basic Points — `ctz-def-points`

Define one or more points at specific coordinates:

```typst
ctz-def-points(A: (0, 0), B: (4, 0), C: (2, 3))
```

== Midpoint — `ctz-def-midpoint`

Find the midpoint of a segment:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 3))
    ctz-def-midpoint("M", "A", "B")

    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(points: ("A", "B", "M"), labels: (
      A: "left", B: "right", M: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 3))
    ctz-def-midpoint("M", "A", "B")
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(points: ("A", "B", "M"), labels: (A: "left", B: "right", M: "above"))
  },
)

== Regular Polygons — `ctz-def-regular-polygon`

Generate vertices of a regular $n$-gon. If you pass a polygon name first, it is registered and can be drawn/labeled by name:
You can also mark all sides during drawing with `mark` and optional `mark-opts`.

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (3, 0))
    // O is the center; A is the starting vertex that fixes the radius/angle.
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")

    ctz-draw("Hex", stroke: blue)
    ctz-draw(points: ("A", "B", "C", "D", "E", "F", "O"), labels: (O: "below"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0), A: (3, 0))
    // O is the center; A is the starting vertex that fixes the radius/angle.
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")
    ctz-draw("Hex", stroke: blue)
    ctz-draw(points: ("A", "B", "C", "D", "E", "F", "O"), labels: (O: "below"))
  },
  length: 0.7cm,
)

== Named Polygons — `ctz-def-polygon` / `ctz-label-polygon`

Define a polygon once and draw/label it by name:

```typst
ctz-def-points(A: (0, 0), B: (4, 0), C: (4, 2), D: (0, 2))
ctz-def-polygon("P1", "A", "B", "C", "D")
ctz-draw("P1", stroke: black)
ctz-label-polygon("P1", $P_1$, pos: "center")
```

== Linear Combination — `ctz-def-linear`

Define a point along a line: $P = A + k(B - A)$

```typst
ctz-def-linear("P", "A", "B", 0.3)  // P is 30% from A to B
ctz-def-linear("Q", "A", "B", 1.5)  // Q extends beyond B
```

#pagebreak()

