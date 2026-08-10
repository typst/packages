// Generates docs/img/gates-ports.svg — a box and a gate with labeled ports.
//   typst compile --root . --ignore-system-fonts docs/img/gates-ports.typ docs/img/gates-ports.svg
#import "../../src/lib.typ" as typ
#let diagram = typ.diagram
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 9pt)

#diagram(scale: 1cm, {
  import typ: *
  box(0, 0, label: [box])
  let g = gate(2.4, 0, $U$, legs: (left: 2, right: 1, top: 1))
  for i in range(2) { edge(port(g, "left", i), rel(-0.8, 0)) }
  edge(port(g, "right"), rel(0.8, 0))
  edge(port(g, "top"), rel(0, 0.8))
})
