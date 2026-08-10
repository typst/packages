#import "../src/lib.typ" as typ

#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, shape-labelled: typ.shapes.stadium, min-size: 9pt, inset: 4pt))
#let diagram = typ.diagram

#diagram({
  import typ: *
  let n1 = dot(0, 0)
  let n2 = dot(1, 0, label: $alpha$)
  let n3 = dot(3, 0, label: $chi_(a_1)^(b_2) e^(i a x (v + v))$)
  edge(n1, n2, n3)
})
