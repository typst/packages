// Visual regression for constant-width highlighted waypoint joins and butt
// caps. Every panel is one edge; separate edge objects are intentionally
// independent.
#import "/src/lib.typ" as typ

#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, min-size: 9pt))
#let duo = typ.edge-type(none, base-style: (highlight: (red, green)))

#let diagram = typ.diagram

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 8pt)

#let joined(body) = diagram(
  scale: 1cm,
  inset: 5pt,
  edge-styles: (
    stroke: stroke(
      paint: black, thickness: 1.2pt, cap: "butt", join: "miter",
    ),
  ),
  body,
)

#grid(
  columns: 2,
  gutter: 12pt,
  [*one colour, right angle* #joined({
    typ.edge((0, 0), (2, 0), (2, -2), highlight: green)
  })],
  [*two colours, right angle* #joined({
    duo((0, 0), (2, 0), (2, 2))
  })],
  [*two colours, oblique angle* #joined({
    typ.edge((0, 0), (2, 0), (3, 1.7), highlight: (red, green))
  })],
  [*mixed smooth and exact* #joined({
    typ.edge(
      (0, 0),
      typ.smooth((1, 1)),
      (2, 0),
      (3, 0),
      typ.smooth((4, 1)),
      (5, 0),
      highlight: (red, green),
    )
  })],
  [
    #joined({
      let n1 = dot(1, 0.5)
      n1
      duo((0, 1), n1)
      duo((0, 0), n1)
      duo(n1, (2, 1))
      duo(n1, (2, 0), clip: false)
    })
  ]
)
