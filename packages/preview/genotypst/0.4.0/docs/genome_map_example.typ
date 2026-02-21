#import "../src/lib.typ": *

#set page(
  fill: none,
  height: auto,
  width: 200mm,
  margin: 0cm,
)

#set align(center)
#set text(font: "Source Sans 3")
#show raw: set text(font: "Source Code Pro", size: 9pt)

#let locus = (
  (start: 400, end: 1260, strand: 1, label: [A], color: rgb("#56B4E9")),
  (start: 1300, end: 2200, strand: 1, label: [B]),
  (start: 2250, end: 3460, strand: -1, label: [C], color: rgb("#E69F00")),
  (start: 3500, end: 3800, label: [D]),
  (start: 3850, end: 5400, strand: 1, label: [E]),
)

#render-genome-map(
  locus,
  coordinate-axis: true,
  width: 80%,
)
