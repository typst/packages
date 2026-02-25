// Line Constructions
#import "../helpers.typ": *

= Line Constructions

== Perpendicular — `ctz-def-perp`

Construct a perpendicular line through a point:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, clip-canvas: (-0.5, -0.5, 5.5, 3.5), {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 1), C: (2, 3))
    ctz-def-perp("P1", "P2", ("A", "B"), "C")
    ctz-def-project("H", "C", "A", "B")

    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("P1", "P2"), stroke: blue)
    ctz-draw-mark-right-angle("A", "H", "C", size: 0.3)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "left", B: "right", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 1), C: (2, 3))
    ctz-def-perp("P1", "P2", ("A", "B"), "C")
    ctz-def-project("H", "C", "A", "B")
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("P1", "P2"), stroke: blue)
    ctz-draw-mark-right-angle("A", "H", "C", size: 0.3)
    ctz-draw(points: ("A", "B", "C"), labels: (A: "left", B: "right", C: "above"))
  },
  length: 0.75cm,
)

== Parallel — `ctz-def-para`

Construct a parallel line through a point:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, clip-canvas: (-0.5, -0.5, 5.5, 3.5), {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 1), C: (1, 2.5))
    ctz-def-para("P1", "P2", ("A", "B"), "C")

    ctz-draw-line-add("A", "B", add: (2, 2), stroke: black)
    ctz-draw-line-add("P1", "P2", add: (2, 2), stroke: green)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below",
      B: "below",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 1), C: (1, 2.5))
    ctz-def-para("P1", "P2", ("A", "B"), "C")
    ctz-draw-line-add("A", "B", add: (2, 2), stroke: black)
    ctz-draw-line-add("P1", "P2", add: (2, 2), stroke: green)
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  },
  length: 0.75cm,
  clip-canvas: (-0.5, -0.5, 5.5, 3.5),
)

== Angle Bisector — `ctz-def-bisect`

Construct the bisector of an angle:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, clip-canvas: (-0.5, -0.5, 4.5, 3.5), {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-def-bisect("D1", "D2", "C", "A", "B")

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-segment("D1", "D2", stroke: red)

    ctz-draw-angle("A", "C", "B", radius: 0.5, stroke: gray)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below",
      B: "below",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-def-bisect("D1", "D2", "C", "A", "B")
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-segment("D1", "D2", stroke: red)
    ctz-draw-angle("A", "C", "B", radius: 0.5, stroke: gray)
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  },
  clip-canvas: (-0.5, -0.5, 4.5, 3.5),
)

== Perpendicular Bisector — `ctz-def-mediator`

Construct the perpendicular bisector of a segment:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, clip-canvas: (-0.5, -0.5, 4.5, 3.5), {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (1, 1), B: (5, 3))
    ctz-def-mediator("M1", "M2", "A", "B")
    ctz-def-midpoint("M", "A", "B")

    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("M1", "M2"), stroke: purple)
    ctz-draw-mark-right-angle("M1", "M", "A", size: 0.25)

    ctz-draw(points: ("A", "B", "M"), labels: (
      A: "left",
      B: "right",
      M: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (1, 1), B: (5, 3))
    ctz-def-mediator("M1", "M2", "A", "B")
    ctz-def-midpoint("M", "A", "B")
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("M1", "M2"), stroke: purple)
    ctz-draw-mark-right-angle("M1", "M", "A", size: 0.25)
    ctz-draw(points: ("A", "B", "M"), labels: (A: "left", B: "right", M: "below"))
  },
  length: 0.75cm,
  clip-canvas: (-0.5, -0.5, 4.5, 3.5),
)

#pagebreak()
