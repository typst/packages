// Generates docs/img/quickstart.svg — the quick-start diagram from the
// Introduction chapter.
//   typst compile --root . --ignore-system-fonts docs/img/quickstart.typ docs/img/quickstart.svg
#import "../../src/lib.typ" as typ
#let node = typ.node-type("node", base-style: (
  shape: typ.shapes.circle, shape-labelled: typ.shapes.stadium,
  fill: aqua.lighten(70%), stroke: 0.6pt + teal, min-size: 12pt, inset: 4pt,
))
#set page(width: auto, height: auto, margin: 8pt)

#typ.diagram({
  let a = node(0, 0, label: [A])
  let b = node(1, 0, label: [B])
  typ.edge(a, b)
  typ.edge(a, (-1, 0))
  typ.edge(b, (2, 0))
})
