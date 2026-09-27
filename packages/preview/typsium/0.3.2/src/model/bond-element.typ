#import "@preview/elembic:1.1.1" as e

// #import "../utils.typ": (
//   get-arrow,
// )

#let bond(
  n: 1,
  length: 2.5em,
  spacing: 0.3em,
  stroke: 1pt,
) = { }

#let draw-bond(it) = box(
  // fill:red,
  height: 0.7em,
  align(horizon, stack(
    spacing: it.spacing,
    ..range(it.n).map(x=>
        line(
          length: it.length,
          stroke: if it.kind == x + 1{
            it.non-covalent-stroke
          }else {
            it.stroke
          },
        )
      )
  )),
)

#let bond = e.element.declare(
  "bond",
  prefix: "typsium",
  
  display: draw-bond,

  fields: (
    e.field("n", int, default: 1),
    e.field("kind", int, default: 0),
    e.field("length", relative, default: 0.5em),
    e.field("spacing", relative, default: 0.15em),
    e.field("stroke", e.types.option(stroke), default: (thickness: 0.5pt,)),
    e.field("non-covalent-stroke", e.types.option(stroke), default: (thickness: 0.5pt,dash: ("dot",),)),
  ),
)