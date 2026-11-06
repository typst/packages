// Demonstration of the fill and inset controls on inline marks.
#import "@preview/faboxyst:0.3.0": mark

#set page(paper: "a4", margin: 1.5cm)
#set text(size: 13pt)

= Filled marks

#mark(
  kind: "fan",
  colour: rgb("#7B2CBF"),
  fill: rgb("#D8B4FE"),
  inset: 0.12em,
)[
  Fan rempli avec une marge intérieure
]

#v(0.8cm)

#mark(
  kind: "bracket",
  colour: rgb("#006D77"),
  fill: rgb("#BEE3DB"),
  inset: (x: 0.18cm, y: 0.10cm),
)[
  Bracket rempli avec des marges différentes
]

#v(0.8cm)

= Other kinds

#mark(kind: "circle", colour: orange, inset: 0.14cm)[
  Circle avec inset vertical
]

#v(0.6cm)

#mark(kind: "wave", colour: rgb("#1565C0"), inset: 0.10cm)[
  Vague avec inset
]
