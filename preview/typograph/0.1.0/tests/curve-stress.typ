// Compile-only regression fixture for the curved-edge hot path: clipped cubic
// endpoints, path-length labels, and repeated visual label preparation.
#import "/src/lib.typ" as typ

#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, min-size: 9pt))
#let arrow = typ.node-type("arrow", base-style: (shape: typ.shapes.arrow, min-size: 11pt))

#let diagram = typ.diagram
#let n = 10

#diagram(scale: 0.5cm, {
  for row in range(n) {
    for col in range(n) {
      let x = col * 1.6
      let y = row * 1.3
      let start = dot(x, y)
      let end = arrow(x + 1, y + 0.7)
      typ.edge(
        start,
        typ.cubic((x + 0.25, y + 0.8), (x + 1.35, y + 0.7), end),
        label: $q$,
        label-pos: 0.55,
      )
    }
  }
})
