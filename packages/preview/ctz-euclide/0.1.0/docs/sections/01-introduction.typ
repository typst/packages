// Introduction
#import "../helpers.typ": *

= Introduction

`ctz-euclide` is a geometry package for Typst, a port of the LaTeX package `tkz-euclide`. Built on top of CeTZ (a powerful drawing library), it provides high-level constructions for Euclidean geometry.

== Features

- *Point Registry*: Define points once, reference them by name throughout your figure
- *Geometric Constructions*: Perpendiculars, parallels, bisectors, mediators
- *Intersections*: Line–line, line–circle, circle–circle with multiple solution handling
- *Triangle Centers*: Centroid, circumcenter, incenter, orthocenter, and 10+ specialized centers
- *Special Triangles*: Medial, orthic, intouch triangles
- *Transformations*: Rotation, reflection, translation, homothety, projection, inversion
- *Drawing & Styling*: Points, labels, angles, segments with tick marks
- *Grid & Axes*: Coordinate systems with customizable appearance
- *Clipping*: Mathematical line clipping for clean bounded figures

== Installation

Import the package in your Typst document:

```typst
#import "@preview/ctz-euclide:0.1.0": *
```

All figures use the `ctz-canvas` function (re-exported from CeTZ):

```typst
#ctz-canvas({
  import cetz.draw: *
  ctz-init()

  // Your geometry code here
})
```

Naming notes:
- All public functions are prefixed with `ctz-` to avoid conflicts.
- Point creation and drawing use `ctz-def-points` and `ctz-draw-points`.
- Other constructors use `ctz-def-*`, and drawing utilities use `ctz-draw-*`.

The `ctz-init()` call initializes the point registry and coordinate resolver.

== Basic Usage

#example(
  [```typst
  #ctz-canvas(length: 0.8cm, {
    import cetz.draw: *
    ctz-init()

    // Define points
    ctz-def-points(A: (0, 0), B: (4, 0), C: (2, 3))

    // Draw triangle
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)

    // Find circumcenter and draw circumcircle
    ctz-def-circumcenter("O", "A", "B", "C")
    ctz-draw(circle-through: ("O", "A"), stroke: blue)

    // Draw and label points
    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "below left", B: "below right",
      C: "above", O: "below"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (4, 0), C: (2, 3))
    ctz-draw(line: ("A", "B", "C", "A"), stroke: black)
    ctz-def-circumcenter("O", "A", "B", "C")
    ctz-draw(circle-through: ("O", "A"), stroke: blue)
    ctz-draw(points: ("A", "B", "C", "O"), labels: (
      A: "below left",
      B: "below right",
      C: "above",
      O: "below"
    ))
  },
)
