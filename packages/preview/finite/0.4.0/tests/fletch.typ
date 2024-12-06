//#import "@preview/finite:0.3.0": automaton, layout
#import "../src/finite.typ": *

#let aut = (
  q0: (q1: "b", q3: "a", q10: "x"),
  q1: (q1: "b", q2: "a"),
  q2: (q1: "b"),
  q3: (q3: "a,b"),
  q10: (),
)

#let style = (
  q0-q1: (curve: 0),
  q0-q3: (curve: 0),
  q3-q3: (anchor: bottom),
  q0: (
    stroke: 1pt + red,
    initial: (
      anchor: top + right,
      label: "XXX",
      stroke: 1pt + blue,
      scale: 1.2,
    ),
  ),
)

#automaton-fletcher(
  aut,
  layout: layout.grid.with(columns: 3, spacing: (2, -4)),
  style: style,
)
