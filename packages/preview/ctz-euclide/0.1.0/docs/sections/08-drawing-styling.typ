// Drawing & Styling
#import "../helpers.typ": *

= Drawing & Styling

== Points — `ctz-draw-points`

Draw points at named locations:

```typst
ctz-draw(points: ("A", "B", "C"))
```

== Unified Drawing — `ctz-draw`

The `ctz-draw()` function provides a unified interface for drawing both *named objects* and *unnamed constructs*.

=== Drawing Named Objects

Use `ctz-draw()` to draw any object type without remembering type-specific commands. It automatically detects whether the object is a point, line, circle, polygon, or conic (ellipse/parabola/projectile).

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-def-line("l1", (-2, 0), (2, 0))
    ctz-def-polygon("tri", "A", "B", "C")
    ctz-def-points(A: (1, 2), B: (2, 0), C: (0, 1))

    ctz-draw("c1", stroke: blue, fill: none)
    ctz-draw("l1", stroke: red + 1.5pt)
    ctz-draw("tri", stroke: green)
    ctz-draw("A")
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-circle("c1", (0, 0), radius: 1.5)
    ctz-def-line("l1", (-2, 0), (2, 0))
    ctz-def-polygon("tri", "A", "B", "C")
    ctz-def-points(A: (1, 2), B: (2, 0), C: (0, 1))
    ctz-draw("c1", stroke: blue, fill: none)
    ctz-draw("l1", stroke: red + 1.5pt)
    ctz-draw("tri", stroke: green)
    ctz-draw("A")
  },
  length: 0.75cm,
)

=== Drawing Unnamed Constructs

You can also use `ctz-draw()` to draw geometric objects directly without defining them first using named parameters.

==== Points with Labels

Draw multiple points at once, optionally with labels:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))

    // Draw points with custom label positions
    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 0), C: (2, 2), D: (0, 2))
    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.75cm,
)

Use `labels: true` for default label positioning, or omit the `labels` parameter to draw points without labels.

==== Paths and Polylines

Draw paths using the `path:` parameter for CeTZ-style path syntax, or `line:` for polylines through points:

```typst
ctz-draw(path: "A--B--C--A", stroke: black)  // Close the path by repeating first point
ctz-draw(line: ("A", "B", "C", "D"), stroke: red)  // Open polyline
```

==== Circles

Draw circles without naming them:

```typst
// Circle through two points (center and point on circumference)
ctz-draw(circle-through: ("O", "A"), stroke: blue)

// Circle by center and radius
ctz-draw(circle-r: ((0, 0), 1.5), stroke: green)

// Circle by diameter endpoints
ctz-draw(circle-diameter: ("A", "B"), stroke: purple)

// Circumcircle of triangle
ctz-draw(circumcircle: ("A", "B", "C"), stroke: red)

// Incircle of triangle
ctz-draw(incircle: ("A", "B", "C"), stroke: teal)
```

==== Conics (Ellipses, Parabolas, Projectiles)

Draw conics without naming them:

```typst
// Ellipse by center, radii, and rotation angle
ctz-draw(ellipse: ((0, 0), 3, 2, 20deg), stroke: black)

// Parabola by focus + directrix (line or two points)
ctz-draw(parabola: ((0, 0), ((-2, -3), (-2, 3)), 4), stroke: black)

// Projectile by origin + velocity (optional gravity, vectors, etc.)
ctz-draw(projectile: (origin: (0, 0), velocity: (4, 6), y-floor: 0, vectors: true), stroke: blue)
```

==== Arcs and Semicircles

```typst
// Arc by center and two points
ctz-draw(arc: (center: "O", start: "A", end: "B"), stroke: orange)

// Arc by center, radius, and angles (in degrees)
ctz-draw(arc-r: ((0, 0), 2, 0, 90), stroke: black)

// Semicircle by diameter endpoints
ctz-draw(semicircle: ("A", "B"), stroke: blue, fill: blue.lighten(80%))
```

==== Line Segments

```typst
ctz-draw(segment: ("A", "B"), stroke: maroon + 1.5pt)
```

=== Complete Example

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))

    // Named circle
    ctz-def-circle("myCircle", (1.5, 1), radius: 2.5)
    ctz-draw("myCircle", stroke: gray + 0.5pt)

    // Unnamed constructs
    ctz-draw(path: "A--B--C--A", stroke: black)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-def-circle("myCircle", (1.5, 1), radius: 2.5)
    ctz-draw("myCircle", stroke: gray + 0.5pt)
    ctz-draw(path: "A--B--C--A", stroke: black)
    ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
    ctz-draw(incircle: ("A", "B", "C"), stroke: red)
    ctz-draw(points: ("A", "B", "C"), labels: true)
  },
  length: 0.6cm,
)

== Labels — `ctz-draw-labels`

Add labels to points with positioning:

```typst
ctz-draw-labels("A", "B", "C",
  A: "below left",
  B: "below right",
  C: "above")
```

Positions: `"above"`, `"below"`, `"left"`, `"right"`, `"above left"`, etc.

Custom offset:
```typst
ctz-draw-labels("O", O: (pos: "below", offset: (0, -0.15)))
```

More placement controls (position, offset, distance):
```typst
ctz-draw-labels("A", "B", "C",
  A: (pos: "above", dist: 0.25),
  B: (pos: "right", offset: (0.1, 0)),
  C: (pos: "below left", offset: (-0.05, -0.05)))
```

== Labels & Points — Unified API (Recommended)

The modern approach combines point drawing and labeling in a single call:

#example(
  [```typst
  #ctz-canvas(length: 0.75cm, {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  },
  length: 0.75cm,
)

This unified API replaces separate `ctz-draw-points()` and `ctz-draw-labels()` calls. The old API remains supported for backward compatibility.

You can also label points that were drawn earlier:
```typst
ctz-draw(points: ("A", "B"))  // Draw points without labels
// ... other drawing commands ...
ctz-draw(labels: (A: "below", B: "above"))  // Add labels later
```

== Segments — `ctz-draw-segment`

Draw a segment with optional arrow or bar tips and a dimension label:

```typst
ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
```

Supported `arrows`: `--` (none), `->`, `<-`, `<->`, `|-|`, `|->`, `<-|`.

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (6, 1.5))

    ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
    ctz-draw-segment("B", "C", arrows: "->", dim: $v$, dim-pos: "below")
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (6, 1.5))

    ctz-draw-segment("A", "B", arrows: "|-|", dim: $5$, dim-pos: "above")
    ctz-draw-segment("B", "C", arrows: "->", dim: $v$, dim-pos: "below")
    ctz-draw(points: ("A", "B", "C"), labels: (A: "below", B: "below", C: "above"))
  },
  length: 0.8cm,
)

Mark equal-length segments with ticks:

```typst
ctz-draw-mark-segment("A", "B", mark: 1)
ctz-draw-mark-segment("C", "D", mark: 2)
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (4, 2.5), D: (0, 2.5))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black)

    // Opposite sides equal
    ctz-draw-mark-segment("A", "B", mark: 1)
    ctz-draw-mark-segment("C", "D", mark: 1)
    ctz-draw-mark-segment("B", "C", mark: 2)
    ctz-draw-mark-segment("D", "A", mark: 2)

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (4, 2.5), D: (0, 2.5))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black)

    // Opposite sides equal
    ctz-draw-mark-segment("A", "B", mark: 1)
    ctz-draw-mark-segment("C", "D", mark: 1)
    ctz-draw-mark-segment("B", "C", mark: 2)
    ctz-draw-mark-segment("D", "A", mark: 2)

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.8cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (3, 0))
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")

    ctz-draw-regular-polygon(("A", "B", "C", "D", "E", "F"),
      stroke: black, mark: 1)

    // Mark all sides with the same tick
    // (use mark-opts to customize size/position)

    ctz-draw(points: ("A", "B", "C", "D", "E", "F"), labels: (
      A: "right",
      B: "above right",
      C: "above left",
      D: "left",
      E: "below",
      F: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(O: (0, 0), A: (3, 0))
    ctz-def-regular-polygon("Hex", ("A", "B", "C", "D", "E", "F"), "O", "A")

    ctz-draw-regular-polygon(("A", "B", "C", "D", "E", "F"),
      stroke: black, mark: 1)

    // Mark all sides with the same tick
    // (use mark-opts to customize size/position)

    ctz-draw(points: ("A", "B", "C", "D", "E", "F"), labels: (
      A: "right",
      B: "above right",
      C: "above left",
      D: "left",
      E: "below",
      F: "below"
    ))
  },
  length: 0.7cm,
)

== Segment Measurements — `ctz-draw-measure-segment`

Draw an offset measurement line with dotted fences and a centered label.
The line breaks around the label and uses open arrowheads by default.

```typst
ctz-draw-measure-segment("A", "B", label: $5$, offset: 0.3, side: "left")
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 1.2))
    ctz-draw-segment("A", "B", stroke: black + 1pt)

    // Minimal measurement example
    ctz-draw-measure-segment("A", "B", label: $ell$, offset: 0.45, side: "left",
      fence-dash: "dotted")

    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "below"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 1.2))
    ctz-draw-segment("A", "B", stroke: black + 1pt)

    // Minimal measurement example
    ctz-draw-measure-segment("A", "B", label: $ell$, offset: 0.45, side: "left",
      fence-dash: "dotted")

    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "below"
    ))
  },
  length: 0.8cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (5, 3), D: (0, 3))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black + 1pt)

    // Rectangle measurements (width and height)
    ctz-draw-measure-segment("A", "B", label: $w$, offset: 0.45, side: "below")
    ctz-draw-measure-segment("C", "B", label: $h$, offset: -0.45, side: "right")

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (5, 0), C: (5, 3), D: (0, 3))
    ctz-draw(line: ("A", "B", "C", "D"), stroke: black + 1pt)

    // Rectangle measurements (width and height)
    ctz-draw-measure-segment("A", "B", label: $w$, offset: 0.45, side: "below")
    ctz-draw-measure-segment("C", "B", label: $h$, offset: -0.45, side: "right")

    ctz-draw(points: ("A", "B", "C", "D"), labels: (
      A: "below left",
      B: "below right",
      C: "above right",
      D: "above left"
    ))
  },
  length: 0.8cm,
)

== Paths — `ctz-draw-path`

Draw polylines with per-segment tips using a TikZ-like string:

```typst
ctz-draw-path("A--B->C|-|D", stroke: black)
```

Supported connectors: `--`, `->`, `<-`, `<->`, `|-|`, `|->`, `<-|`.

By default, `ctz-draw-path` draws points as crosses for normal segments and hides
points that touch a bar connector (`|-|`, `|->`, `<-|`). Labels default to `below`.
You can override per-point placements or point styles in the path with `{...}`, or via
`label-overrides`.

Default behavior, label are placed below

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    // Default labels below, default point styles
    ctz-draw-path("A--B->C|-|D", stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    // Default labels below, default point styles
    ctz-draw-path("A--B->C|-|D", stroke: black)
  },
  length: 0.8cm,
)


#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below}--B{below}->C{above}|-|D{below}", stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below}--B{below}->C{above}|-|D{below}", stroke: black)
  },
  length: 0.8cm,
)

Override placements using `label-overrides`:

```typst
ctz-draw-path("A--B->C|-|D",
  label-overrides: (A: "left", C: "above right"))
```

Customize point appearance or disable points/labels:

```typst
ctz-draw-path("A--B->C|-|D",
  point-style: "circle",
  point-color: red,
  label-pos: "above")
```

```typst
ctz-draw-path("A--B->C|-|D",
  points: false,
  labels: false)
```

Per-point overrides inside the path:

```typst
ctz-draw-path("A{below, style: circle}--B{below}->C{above, style: none}|-|D{below}",
  stroke: black)
```

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below, style: circle}--B{below}->C{above}|-|D{below}",
      stroke: black)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(
      A: (0, 0), B: (3, 0), C: (6, 1.5), D: (8, 0),
    )

    ctz-draw-path("A{below, style: circle}--B{below}->C{above}|-|D{below}",
      stroke: black)
  },
  length: 0.8cm,
)


== Global Styling — `ctz-style`

Set default styles for points and labels:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.1, fill: red))

    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"))

    ctz-style(point: (shape: "cross", size: 0.15, stroke: blue + 1.5pt))
    ctz-def-centroid("G", "A", "B", "C")
    ctz-draw(points: ("G"))

    ctz-draw(points: ("G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "right"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-style(point: (shape: "dot", size: 0.1, fill: red))
    ctz-def-points(A: (0, 0), B: (3, 0), C: (1.5, 2.5))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw(points: ("A", "B", "C"))
    ctz-style(point: (shape: "cross", size: 0.15, stroke: blue + 1.5pt))
    ctz-def-centroid("G", "A", "B", "C")
    ctz-draw(points: ("G"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      G: "right"
    ))
  },
)

Point shapes: `"dot"`, `"cross"`, `"circle"`, `"square"`

== Angle Marking — `ctz-draw-angle`

Mark and label angles:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    ctz-draw-angle("A", "B", "C",
      label: $alpha$,
      radius: 0.7,
      fill: blue.lighten(70%),
      stroke: blue)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (1, 3))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-draw-angle("A", "B", "C", label: $alpha$, radius: 0.7, fill: blue.lighten(70%), stroke: blue)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "below right",
      C: "above"
    ))
  },
)

== Right Angle Mark — `ctz-draw-mark-right-angle`

Mark a right angle with a small square:

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (4, 0), C: (0, 3))
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("A", "C"), stroke: black)

    ctz-draw-mark-right-angle("B", "A", "C", size: 0.4)

    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "right",
      C: "above"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (0, 3))
    ctz-draw(segment: ("A", "B"), stroke: black)
    ctz-draw(segment: ("A", "C"), stroke: black)
    ctz-draw-mark-right-angle("B", "A", "C", size: 0.4)
    ctz-draw(points: ("A", "B", "C"), labels: (
      A: "below left",
      B: "right",
      C: "above"
    ))
  },
)

#pagebreak()

