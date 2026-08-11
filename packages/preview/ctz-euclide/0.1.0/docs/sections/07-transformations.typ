// Transformations
#import "../helpers.typ": *

= Transformations

== Rotation — `rotate`

Rotate a point around a center:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (2, 2), A: (5, 2))
    ctz-def-rotation("B", "A", "O", 60)
    ctz-def-rotation("C", "A", "O", 120)

    ctz-draw(circle-r: (_pt("O"), 3), stroke: gray.lighten(50%))
    ctz-draw(segment: ("O", "A"), stroke: blue)
    ctz-draw(segment: ("O", "B"), stroke: blue)
    ctz-draw(segment: ("O", "C"), stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw(points: ("O", "A", "B", "C"), labels: (
      O: "below left",
      A: "right",
      B: "above right",
      C: "left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (2, 2), A: (5, 2))
    ctz-def-rotation("B", "A", "O", 60)
    ctz-def-rotation("C", "A", "O", 120)
    ctz-draw(circle-r: (_pt("O"), 3), stroke: gray.lighten(50%))
    ctz-draw(segment: ("O", "A"), stroke: blue)
    ctz-draw(segment: ("O", "B"), stroke: blue)
    ctz-draw(segment: ("O", "C"), stroke: blue)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("O", "A", "B", "C"), labels: (
      O: "below left",
      A: "right",
      B: "above right",
      C: "left"
    ))
  },
  length: 0.75cm,
)

== Reflection — `ctz-def-reflect`

Reflect a point across a line:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 3), P: (3, 0))
    ctz-def-reflect("Pp", "P", "A", "B")

    ctz-draw(segment: ("A", "B"), stroke: gray)
    ctz-draw(path: "P--Pp", stroke: blue + 0.5pt, mark: (end: ">"), points: false, labels: false)

    ctz-draw(points: ("A", "B", "P", "Pp"), labels: (
      P: "below",
      Pp: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 3), P: (3, 0))
    ctz-def-reflect("Pp", "P", "A", "B")
    ctz-draw(segment: ("A", "B"), stroke: gray)
    ctz-draw(path: "P--Pp", stroke: blue + 0.5pt, mark: (end: ">"), points: false, labels: false)
    ctz-draw(points: ("A", "B", "P", "Pp"), labels: (
      P: "below",
      Pp: "above left"
    ))
  },
  length: 0.75cm,
)

== Homothety (Scaling) — `scale`

Scale a point from a center:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (2, 1), B: (3, 2), C: (1, 2.5))
    ctz-def-homothety("Ap", "A", "O", 2)
    ctz-def-homothety("Bp", "B", "O", 2)
    ctz-def-homothety("Cp", "C", "O", 2)

    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(line: ("Ap", "Bp", "Cp", "Ap"), stroke: blue)
    ctz-draw(segment: ("O", "Ap"), stroke: gray + 0.3pt)
    ctz-draw(segment: ("O", "Bp"), stroke: gray + 0.3pt)
    ctz-draw(segment: ("O", "Cp"), stroke: gray + 0.3pt)

    ctz-draw(points: ("O", "A", "B", "C", "Ap", "Bp", "Cp"), labels: (
      O: "below left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0), A: (2, 1), B: (3, 2), C: (1, 2.5))
    ctz-def-homothety("Ap", "A", "O", 2)
    ctz-def-homothety("Bp", "B", "O", 2)
    ctz-def-homothety("Cp", "C", "O", 2)
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(line: ("Ap", "Bp", "Cp", "Ap"), stroke: blue)
    ctz-draw(segment: ("O", "Ap"), stroke: gray + 0.3pt)
    ctz-draw(segment: ("O", "Bp"), stroke: gray + 0.3pt)
    ctz-draw(segment: ("O", "Cp"), stroke: gray + 0.3pt)
    ctz-draw(points: ("O", "A", "B", "C", "Ap", "Bp", "Cp"), labels: (
      O: "below left"
    ))
  },
  length: 0.7cm,
)

== Projection — `ctz-def-project`

Project a point onto a line:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 1), P: (2, 3))
    ctz-def-project("H", "P", "A", "B")

    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("P", "H"), stroke: blue + 0.5pt)
    ctz-draw-mark-right-angle("A", "H", "P", size: 0.25)

    ctz-draw(points: ("A", "B", "P", "H"), labels: (
      P: "above",
      H: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (5, 1), P: (2, 3))
    ctz-def-project("H", "P", "A", "B")
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("P", "H"), stroke: blue + 0.5pt)
    ctz-draw-mark-right-angle("A", "H", "P", size: 0.25)
    ctz-draw(points: ("A", "B", "P", "H"), labels: (
      P: "above",
      H: "below"
    ))
  },
  length: 0.75cm,
)

== Inversion — `ctz-def-inversion`

Invert points, lines, or circles through a circle:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()
    ctz-set-clip(-5, -4.5, 5, 4)

    ctz-def-points(O: (0, 0), A: (-4, -1), B: (4, -1), C: (1.8, 1))
    ctz-def-line("L", "A", "B")
    ctz-def-circle("C1", "C", radius: 1.1)

    ctz-def-inversion("Li", "L", "O", 3)
    ctz-def-inversion("C1i", "C1", "O", 3)

    ctz-draw(circle-r: (_pt("O"), 3), stroke: black + 1pt)
    ctz-draw("L", stroke: gray + 0.7pt)
    ctz-draw("C1", stroke: gray + 0.7pt)
    ctz-draw("Li", stroke: blue + 1pt)
    ctz-draw("C1i", stroke: red + 1pt)
    ctz-draw(points: ("O"), labels: (O: "below left"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-set-clip(-5, -4.5, 5, 4)
    ctz-def-points(O: (0, 0), A: (-4, -1), B: (4, -1), C: (1.8, 1))
    ctz-def-line("L", "A", "B")
    ctz-def-circle("C1", "C", radius: 1.1)
    ctz-def-inversion("Li", "L", "O", 3)
    ctz-def-inversion("C1i", "C1", "O", 3)
    ctz-draw(circle-r: (_pt("O"), 3), stroke: black + 1pt)
    ctz-draw("L", stroke: gray + 0.7pt)
    ctz-draw("C1", stroke: gray + 0.7pt)
    ctz-draw("Li", stroke: blue + 1pt)
    ctz-draw("C1i", stroke: red + 1pt)
    ctz-draw(points: ("O"), labels: (O: "below left"))
  },
  length: 0.7cm,
)

== Object Duplication — `ctz-duplicate`

Duplicate any geometric object. For polygons, explicit point names must be provided.

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    // Duplicate a circle
    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-duplicate("c2", "c1")
    ctz-draw("c1", stroke: blue)

    // Duplicate a polygon
    ctz-def-regular-polygon("tri", ("A","B","C"),
      (3, 0), (4, 0), n: 3)
    ctz-duplicate("tri2", "tri",
      points: ("A2", "B2", "C2"))
    ctz-draw("tri", stroke: green)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-duplicate("c2", "c1")
    ctz-draw("c1", stroke: blue)
    ctz-def-regular-polygon("tri", ("A","B","C"),
      (3, 0), (4, 0), n: 3)
    ctz-duplicate("tri2", "tri",
      points: ("A2", "B2", "C2"))
    ctz-draw("tri", stroke: green)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  },
  length: 0.75cm,
)

For points, lines, and circles, duplication is straightforward. For polygons, you must provide explicit point names so the vertices can be referenced independently.

== Polymorphic Rotation

The `ctz-def-rotation()` function works on all object types: points, lines, circles, and polygons.

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    // Rotate a circle
    ctz-def-points(O: (0, 0))
    ctz-def-circle("c1", (2, 0), radius: 1)
    ctz-def-rotation("c2", "c1", "O", 45)

    ctz-draw("c1", stroke: blue)
    ctz-draw("c2", stroke: red)
    ctz-draw(points: ("O"), labels: (
      O: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0))
    ctz-def-circle("c1", (2, 0), radius: 1)
    ctz-def-rotation("c2", "c1", "O", 45)
    ctz-draw("c1", stroke: blue)
    ctz-draw("c2", stroke: red)
    ctz-draw(points: ("O"), labels: (
      O: "below"
    ))
  },
  length: 0.75cm,
)

For lines, both endpoints are rotated. For circles, the center is rotated while radius remains constant. For polygons, all constituent points are rotated in place.

#pagebreak()

