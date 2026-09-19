// pythagorean-spiral — quick examples
// compile with: typst compile example.typ
#import "@preview/pythagorean-spiral:0.1.0": *

#set page(width: 21cm, height: 29.7cm, margin: 1.5cm)
#set text(size: 10pt)

#align(center, text(size: 18pt, weight: "bold")[The Spiral of Theodorus])
#v(2pt)
#align(center, text(size: 9pt, fill: rgb("#666666"))[
  Each triangle has a leg of length #raw("size") and the previous hypotenuse;
  the n-th hypotenuse is #raw("√(n+1)·size").
])
#v(8pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 10pt,
  align(center, pythagorean-spiral(steps: 5, size: 0.9cm)),
  align(center, pythagorean-spiral(steps: 12, size: 0.9cm)),
  align(center, pythagorean-spiral(steps: 17, size: 0.9cm)),
  align(center, pythagorean-spiral(steps: 24, size: 0.9cm)),
)

#v(10pt)
#text(size: 12pt, weight: "bold")[Colours, gradients, direction]
#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  align(center, pythagorean-spiral(
    steps: 30, size: 0.9cm,
    fill: gradient.linear(rgb("#ff6b6b"), rgb("#4ecdc4")),
    stroke: 1.2pt + rgb("#2d3436"),
  )),
  align(center, pythagorean-spiral(
    steps: 30, size: 0.9cm,
    fill: (yellow, orange, red, purple),
    direction: "cw",
  )),
)

#v(10pt)
#text(size: 12pt, weight: "bold")[Length labels]
#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  align(center, pythagorean-spiral(
    steps: 7, size: 1.25cm,
    fill: blue.transparentize(70%),
    length-labels: "values",
  )),
  align(center, pythagorean-spiral(
    steps: 7, size: 1.25cm,
    length-labels: "formulas",
    label-new-legs: true,
  )),
)

#v(10pt)
#text(size: 12pt, weight: "bold")[Teaching annotations]
#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  align(center, pythagorean-spiral(
    steps: 8, size: 1.1cm,
    fill: blue.transparentize(75%),
    labels: "vertices",
    right-angle-marks: true,
  )),
  align(center, pythagorean-spiral(
    steps: 10, size: 1.0cm,
    fill: (yellow, orange),
    labels: "indices",
    label-size: 7pt,
  )),
)

#v(10pt)
#text(size: 12pt, weight: "bold")[Modes]
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  align(center, pythagorean-spiral(steps: 17, size: 0.9cm, mode: "spiral")),
  align(center, pythagorean-spiral(steps: 17, size: 0.9cm, mode: "rays")),
  align(center, pythagorean-spiral(
    steps: 17, size: 0.9cm, mode: "triangles", show-hypotenuses: false,
  )),
)

#v(10pt)
#let total = spiral-angle(17)
#align(center, text(size: 9pt, fill: rgb("#666666"))[
  Accumulated angle for 17 triangles: #(total / 1deg)° — more than a full turn!
])
