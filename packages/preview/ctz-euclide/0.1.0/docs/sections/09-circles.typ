// Circles
#import "../helpers.typ": *

= Circles

== Named Circle — `ctz-def-circle` / `ctz-draw-circle`

Define a circle once and draw/label it by name.
This uses the “define → draw → label” pattern:
- `ctz-def-circle` stores geometry under a name.
- `ctz-draw-circle` renders it later (you can style it each time).
- `ctz-label-circle` places text relative to the circle without recomputing center/radius.

```typst
ctz-def-points(O: (0, 0), A: (3, 0))
ctz-def-circle("C1", "O", through: "A")
ctz-draw("C1", stroke: gray)
ctz-label-circle("C1", $C_1$, pos: "above right", dist: 0.2)
```

More label placement controls:
```typst
ctz-label-circle("C1", $C_1$,
  pos: "above",
  dist: 0.25,
  offset: (0.1, 0))
```

== Circumcircle — `ctz-draw-circumcircle`

Draw the circumscribed circle of a triangle:

```typst
ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue + 1pt)
```

== Incircle — `ctz-draw-incircle`

Draw the inscribed circle of a triangle:

```typst
ctz-draw(incircle: ("A", "B", "C"), stroke: green + 1pt)
```

#pagebreak()

