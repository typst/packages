#import "@preview/physkit:0.1.0": mechanics, vectors

#set page(width: 260mm, height: 145mm, margin: 12mm, fill: rgb("f7f9fb"))
#set text(font: "Libertinus Serif", fill: rgb("253047"))

#let a = vectors.vector(
  "a",
  (3, 2),
  label: [$arrow(a)$],
  color: rgb("0077b6"),
  label-offset: (-0.1, 0.28),
  show-components: true,
)
#let b = vectors.vector(
  "b",
  (-1, 3),
  from: a.end,
  label: [$arrow(b)$],
  color: rgb("d1495b"),
  label-offset: (0.22, 0.05),
)
#let r = vectors.resultant(
  "r",
  (a, b),
  label: [$arrow(R)$],
  color: rgb("2a9d8f"),
  label-position: 68%,
  label-offset: (-0.22, 0.18),
)

#let body = mechanics.box(
  "isolated-body",
  width: 1.4,
  height: 1.0,
  label: [$m$],
)
#let body-forces = (
  mechanics.force("weight", body, (0, -1),
    anchor: "bottom", magnitude: 2.0,
    label: [$P$], label-offset: (0.3, 0)),
  mechanics.force("normal", body, (0, 1),
    anchor: "top", magnitude: 1.7,
    label: [$N$], label-offset: (0.3, 0)),
  mechanics.force("friction", body, (-1, 0),
    anchor: "left", magnitude: 1.45,
    label: [$f$], label-offset: (0, 0.28)),
  mechanics.force("applied", body, (0.866, 0.5),
    anchor: "right", magnitude: 2.0,
    label: [$F$], label-offset: (0.05, 0.3)),
)

#align(center)[
  #text(size: 18pt, weight: "bold")[Vetores e diagrama de corpo livre]
]
#v(5mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 12mm,
  block(
    width: 100%, height: 100mm, inset: 7mm, radius: 3mm,
    fill: white, stroke: rgb("d8e0e8") + 0.6pt,
    [
      #text(size: 11pt, weight: "semibold")[Soma vetorial no plano cartesiano]
      #v(5mm)
      #align(center)[
        #vectors.diagram(
          vectors: (a, b, r),
          x-range: (-1, 5),
          y-range: (-1, 6),
        )
      ]
    ],
  ),
  block(
    width: 100%, height: 100mm, inset: 7mm, radius: 3mm,
    fill: white, stroke: rgb("d8e0e8") + 0.6pt,
    [
      #text(size: 11pt, weight: "semibold")[Diagrama de corpo livre]
      #v(18mm)
      #align(center)[
        #mechanics.free-body(body, forces: body-forces)
      ]
    ],
  ),
)
