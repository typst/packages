// Generates docs/img/flip-vs-rotate.svg — directional shapes and flip:.
//   typst compile --root . --ignore-system-fonts docs/img/flip-vs-rotate.typ docs/img/flip-vs-rotate.svg
#import "../../src/lib.typ" as typ
#let diagram = typ.diagram
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 8pt)

// A mirrored pair declared directly with flip: true in base-style (the
// "effect is state mirrored" pattern), and a flippable: true constructor a
// document can flip per call.
#let tri = typ.node-type("tri", base-style: (shape: typ.shapes.flat-triangle, fill: white, stroke: 0.6pt + black, min-width: 26pt, min-height: 20pt))
#let tri-mirror = typ.node-type("tri-mirror", base-style: (shape: typ.shapes.flat-triangle, flip: true, fill: white, stroke: 0.6pt + black, min-width: 26pt, min-height: 20pt))
#let pointer = typ.node-type("pointer", flippable: true, base-style: (shape: typ.shapes.arrow, fill: luma(220), stroke: 0.6pt + black, min-size: 11pt, inset: 3pt))

#table(
  columns: 4, align: center + horizon, stroke: none, column-gutter: 16pt, row-gutter: 4pt,
  [*`tri`*], [*`tri-mirror`*], [*`pointer`*], [*`pointer(flip: true)`*],
  diagram(scale: 1cm, { tri(0, 0) }),
  diagram(scale: 1cm, { tri-mirror(0, 0) }),
  diagram(scale: 1cm, { pointer(0, 0, label: $m$) }),
  diagram(scale: 1cm, { pointer(0, 0, label: $m$, flip: true) }),
  [flat-triangle,\ default orientation], [same shape,\ `flip: true` in `base-style`], [arrow points\ right], [mirrored,\ not rotated],
)
