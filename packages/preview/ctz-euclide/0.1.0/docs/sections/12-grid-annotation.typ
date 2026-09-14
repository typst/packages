// Grid & Annotation Helpers
// Helper functions for structured diagrams with grids, highlights, and annotations

#import "../helpers.typ": *

= Grid & Annotation Helpers

This section covers helper functions for creating structured diagrams with grids, highlights, and annotations. These are particularly useful for educational materials like Pascal's triangle, multiplication tables, or any grid-based visualizations.

== Grid Positioning

Three grid layout systems are provided for positioning content.

=== Triangular Grid

The `triangular-pos(row, col)` function computes positions in a triangular layout where each row has one more element than the previous, centered horizontally. This is the layout used by Pascal's triangle.

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-triangular-grid(
      cetz.draw, 5,
      (row, col) => str(row) + "," + str(col),
      h-spacing: 1.8,
      v-spacing: 1.0,
      text-size: 9pt,
    )
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-triangular-grid(
      cetz.draw, 5,
      (row, col) => str(row) + "," + str(col),
      h-spacing: 1.8,
      v-spacing: 1.0,
      text-size: 9pt,
    )
  },
  length: 0.7cm,
)

*Parameters:*
- `row` — Row number (0 = top)
- `col` — Column within row (0 to row)
- `h-spacing` — Horizontal spacing between adjacent cells (default: 1.5)
- `v-spacing` — Vertical spacing between rows (default: 1.2)
- `origin` — Grid origin point (default: (0, 0))

=== Pascal's Triangle

For Pascal's triangle binomial coefficients, use `draw-pascal-values`:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-pascal-values(cetz.draw, 6,
      h-spacing: 1.5, v-spacing: 1.0,
      text-size: 11pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-pascal-values(cetz.draw, 6, h-spacing: 1.5, v-spacing: 1.0, text-size: 11pt)
  },
  length: 0.65cm,
)

=== Row and Diagonal Labels

Add row labels (`draw-row-labels`) and diagonal labels (`draw-diagonal-labels`):

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    let sp = (h: 1.4, v: 1.0)

    draw-pascal-values(cetz.draw, 5,
      h-spacing: sp.h, v-spacing: sp.v,
      text-size: 10pt)

    draw-row-labels(cetz.draw, 5,
      h-spacing: sp.h, v-spacing: sp.v,
      offset: -1.2, text-color: blue,
      format: n => $n=#n$)

    draw-diagonal-labels(cetz.draw, 5,
      h-spacing: sp.h, v-spacing: sp.v,
      offset: (0.4, 0.3), text-color: gray,
      format: k => $k=#k$)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    let sp = (h: 1.4, v: 1.0)
    draw-pascal-values(cetz.draw, 5, h-spacing: sp.h, v-spacing: sp.v, text-size: 10pt)
    draw-row-labels(cetz.draw, 5, h-spacing: sp.h, v-spacing: sp.v, offset: -1.2, text-size: 9pt, text-color: blue, format: n => $n=#n$)
    draw-diagonal-labels(cetz.draw, 5, h-spacing: sp.h, v-spacing: sp.v, offset: (0.4, 0.3), text-size: 8pt, text-color: gray, format: k => $k=#k$)
  },
  length: 0.6cm,
)

=== Rectangular Grid

The `grid-pos(row, col)` function computes positions in a standard rectangular grid:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-rectangular-grid(
      cetz.draw, 3, 4,
      (r, c) => str(r * 4 + c + 1),
      h-spacing: 1.2, v-spacing: 1.0,
      text-size: 11pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-rectangular-grid(cetz.draw, 3, 4, (r, c) => str(r * 4 + c + 1), h-spacing: 1.2, v-spacing: 1.0, text-size: 11pt)
  },
  length: 0.7cm,
)

=== Hexagonal Grid

The `hex-pos(row, col)` function computes positions in a hexagonal (honeycomb) grid:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": hex-pos

    for row in range(3) {
      for col in range(4) {
        let p = hex-pos(row, col, size: 0.8)
        cetz.draw.circle(p, radius: 0.35,
          stroke: blue + 0.5pt,
          fill: blue.lighten(90%))
        content(p, text(size: 8pt,
          str(row) + "," + str(col)))
      }
    }
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": hex-pos

    for row in range(3) {
      for col in range(4) {
        let p = hex-pos(row, col, size: 0.8)
        cetz.draw.circle(p, radius: 0.35, stroke: blue + 0.5pt, fill: blue.lighten(90%))
        content(p, text(size: 8pt, str(row) + "," + str(col)))
      }
    }
  },
  length: 0.7cm,
)

== Annotation Helpers

Functions for highlighting cells and drawing annotation arrows.

=== Cell Highlighting

`highlight-fill` draws a filled circle, `highlight-outline` draws an outlined circle, and `highlight-many` highlights multiple positions:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-pascal-values(cetz.draw, 4,
      h-spacing: 1.5, v-spacing: 1.0)

    // Filled highlight
    let p1 = triangular-pos(2, 1,
      h-spacing: 1.5, v-spacing: 1.0)
    highlight-fill(cetz.draw, p1,
      radius: 0.4, fill: red.lighten(70%))
    content(p1, "2")

    // Outline highlights
    let p2 = triangular-pos(1, 0,
      h-spacing: 1.5, v-spacing: 1.0)
    let p3 = triangular-pos(1, 1,
      h-spacing: 1.5, v-spacing: 1.0)
    highlight-many(cetz.draw, (p2, p3),
      radius: 0.35, stroke: green + 1.5pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    draw-pascal-values(cetz.draw, 4, h-spacing: 1.5, v-spacing: 1.0)
    let p1 = triangular-pos(2, 1, h-spacing: 1.5, v-spacing: 1.0)
    highlight-fill(cetz.draw, p1, radius: 0.4, fill: red.lighten(70%))
    content(p1, "2")
    let p2 = triangular-pos(1, 0, h-spacing: 1.5, v-spacing: 1.0)
    let p3 = triangular-pos(1, 1, h-spacing: 1.5, v-spacing: 1.0)
    highlight-many(cetz.draw, (p2, p3), radius: 0.35, stroke: green + 1.5pt)
  },
  length: 0.7cm,
)

=== Curved Arrows

`curved-arrow` draws a curved annotation arrow. The `bend` parameter controls curvature direction and amount (positive = bend right, negative = bend left):

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    content((0, 0), $A$)
    content((3, 0), $B$)
    content((1.5, 2), $C$)

    curved-arrow(cetz.draw,
      (0.3, 0.2), (2.7, 0.2),
      bend: 0.5, stroke: red + 1pt)

    curved-arrow(cetz.draw,
      (0.3, -0.2), (2.7, -0.2),
      bend: -0.5, stroke: blue + 1pt)

    curved-arrow(cetz.draw,
      (0.3, 0.1), (1.3, 1.7),
      bend: -0.6, stroke: green + 1pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    content((0, 0), $A$)
    content((3, 0), $B$)
    content((1.5, 2), $C$)

    curved-arrow(cetz.draw, (0.3, 0.2), (2.7, 0.2), bend: 0.5, stroke: red + 1pt)
    curved-arrow(cetz.draw, (0.3, -0.2), (2.7, -0.2), bend: -0.5, stroke: blue + 1pt)
    curved-arrow(cetz.draw, (0.3, 0.1), (1.3, 1.7), bend: -0.6, stroke: green + 1pt)
  },
  length: 0.8cm,
)

=== Smooth Arrows

`smooth-arrow` draws a Catmull-Rom spline through waypoints for complex curved paths:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    content((0, 0), $P$)
    content((4, -1), $Q$)

    smooth-arrow(cetz.draw,
      (0.4, 0), (3.6, -1),
      waypoints: (
        (1.2, 0.8),
        (2.5, 0.5),
        (3.2, -0.3),
      ),
      stroke: purple + 1.2pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    content((0, 0), $P$)
    content((4, -1), $Q$)
    smooth-arrow(cetz.draw, (0.4, 0), (3.6, -1), waypoints: ((1.2, 0.8), (2.5, 0.5), (3.2, -0.3)), stroke: purple + 1.2pt)
  },
  length: 0.8cm,
)

=== Addition Indicator

`draw-addition-indicator` shows two values combining into a result (useful for Pascal's triangle):

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    let a = (0, 0)
    let b = (1.5, 0)
    let sum = (0.75, -1.2)

    content(a, $3$)
    content(b, $3$)
    content(sum, $6$)

    draw-addition-indicator(cetz.draw,
      a, b, sum, color: green)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    let a = (0, 0)
    let b = (1.5, 0)
    let sum = (0.75, -1.2)
    content(a, $3$)
    content(b, $3$)
    content(sum, $6$)
    draw-addition-indicator(cetz.draw, a, b, sum, color: green)
  },
  length: 0.8cm,
)

=== Braces

`draw-brace-h` and `draw-brace-v` draw horizontal and vertical braces with optional labels:

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    for i in range(5) {
      content((i * 0.8, 0),
        text(size: 11pt, str(i + 1)))
    }

    draw-brace-h(cetz.draw,
      (0, -0.3), (3.2, -0.3),
      label: text(size: 9pt, "first four"),
      side: "below", amplitude: 0.25)

    draw-brace-h(cetz.draw,
      (0, 0.3), (3.2, 0.3),
      label: text(size: 9pt, "above"),
      side: "above", amplitude: 0.25,
      stroke: blue + 1pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    for i in range(5) { content((i * 0.8, 0), text(size: 11pt, str(i + 1))) }
    draw-brace-h(cetz.draw, (0, -0.3), (3.2, -0.3), label: text(size: 9pt, "first four"), side: "below", amplitude: 0.25)
    draw-brace-h(cetz.draw, (0, 0.3), (3.2, 0.3), label: text(size: 9pt, "above"), side: "above", amplitude: 0.25, stroke: blue + 1pt)
  },
  length: 0.8cm,
)

#example(
  [```typst
  #cetz.canvas({
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    for i in range(4) {
      content((0, -i * 0.7),
        text(size: 11pt, "Row " + str(i)))
    }

    draw-brace-v(cetz.draw,
      (1.2, 0), (1.2, -2.1),
      label: text(size: 9pt, "3 rows"),
      side: "right", amplitude: 0.3)

    draw-brace-v(cetz.draw,
      (-0.6, 0), (-0.6, -1.4),
      label: text(size: 9pt, "2"),
      side: "left", amplitude: 0.25,
      stroke: red + 1pt)
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    import "@preview/ctz-euclide:0.1.0": *

    for i in range(4) { content((0, -i * 0.7), text(size: 11pt, "Row " + str(i))) }
    draw-brace-v(cetz.draw, (1.2, 0), (1.2, -2.1), label: text(size: 9pt, "3 rows"), side: "right", amplitude: 0.3)
    draw-brace-v(cetz.draw, (-0.6, 0), (-0.6, -1.4), label: text(size: 9pt, "2"), side: "left", amplitude: 0.25, stroke: red + 1pt)
  },
  length: 0.8cm,
)
