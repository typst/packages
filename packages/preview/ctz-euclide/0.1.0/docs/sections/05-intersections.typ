// Intersections
#import "../helpers.typ": *

= Intersections

== Line–Line — `ctz-def-ll`

Find the intersection of two lines:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 3),
              C: (4, 0), D: (0, 2.5))
    ctz-def-line("L1", "A", "B")
    ctz-def-line("L2", "C", "D")
    ctz-def-ll("I", "L1", "L2")

    ctz-draw("L1", stroke: blue)
    ctz-draw("L2", stroke: red)

    ctz-draw(points: ("A", "B", "C", "D", "I"), labels: (I: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 3), C: (4, 0), D: (0, 2.5))
    ctz-def-line("L1", "A", "B")
    ctz-def-line("L2", "C", "D")
    ctz-def-ll("I", "L1", "L2")
    ctz-draw("L1", stroke: blue)
    ctz-draw("L2", stroke: red)
    ctz-draw(points: ("A", "B", "C", "D", "I"), labels: (I: "above"))
  },
)

== Line–Circle — `ctz-def-lc`

Find intersections of a line with a circle:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), R: (3, 0),
              A: (-2, 2), B: (4, 1))
    ctz-def-line("L1", "A", "B")
    ctz-def-circle("C1", "O", through: "R")
    ctz-def-lc(("I1", "I2"), "L1", "C1")

    ctz-draw("C1", stroke: blue)
    ctz-label-circle("C1", $C_1$, pos: "above", dist: 0.2)
    ctz-set-clip(-4, -4, 5, 4)
    ctz-draw-line-global-clip("A", "B", add: (2, 2), stroke: red)

    ctz-draw(points: ("O", "I1", "I2"), labels: (
      O: "below",
      I1: "above left",
      I2: "above right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O: (0, 0), R: (3, 0), A: (-2, 2), B: (4, 1))
    ctz-def-line("L1", "A", "B")
    ctz-def-circle("C1", "O", through: "R")
    ctz-def-lc(("I1", "I2"), "L1", "C1")
    ctz-draw("C1", stroke: blue)
    ctz-label-circle("C1", $C_1$, pos: "above", dist: 0.2)
    ctz-set-clip(-4, -4, 5, 4)
    ctz-draw-line-global-clip("A", "B", add: (2, 2), stroke: red)
    ctz-draw(points: ("O", "I1", "I2"), labels: (
      O: "below",
      I1: "above left",
      I2: "above right"
    ))
  },
  length: 0.7cm,
)

Named line/circle form:

```typst
ctz-def-line("L1", "A", "B")
ctz-def-circle("C1", "O", radius: 3)
ctz-def-lc(("I1", "I2"), "L1", "C1")
```

== Circle–Circle — `ctz-def-cc`

Find intersections of two circles:

#example(
  [```typst
  #ctz-canvas(length: 0.65cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O1: (0, 0), O2: (3, 0),
              R1: (2.5, 0), R2: (5.5, 0))
    ctz-def-circle("C1", "O1", through: "R1")
    ctz-def-circle("C2", "O2", through: "R2")
    ctz-def-cc(("I1", "I2"), "C1", "C2")

    ctz-draw("C1", stroke: blue)
    ctz-draw("C2", stroke: red)
    ctz-label-circle("C1", $C_1$, pos: "above left", dist: 0.2)
    ctz-label-circle("C2", $C_2$, pos: "above right", dist: 0.2)

    ctz-draw(points: ("O1", "O2", "I1", "I2"), labels: (
      I1: "above",
      I2: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(O1: (0, 0), O2: (3, 0), R1: (2.5, 0), R2: (5.5, 0))
    ctz-def-circle("C1", "O1", through: "R1")
    ctz-def-circle("C2", "O2", through: "R2")
    ctz-def-cc(("I1", "I2"), "C1", "C2")
    ctz-draw("C1", stroke: blue)
    ctz-draw("C2", stroke: red)
    ctz-label-circle("C1", $C_1$, pos: "above left", dist: 0.2)
    ctz-label-circle("C2", $C_2$, pos: "above right", dist: 0.2)
    ctz-draw(points: ("O1", "O2", "I1", "I2"), labels: (I1: "above", I2: "below"))
  },
  length: 0.65cm,
)

Named circle form:

```typst
ctz-def-circle("C1", "O1", through: "R1")
ctz-def-circle("C2", "O2", through: "R2")
ctz-def-cc(("I1", "I2"), "C1", "C2")
```

#pagebreak()

