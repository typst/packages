#import "@preview/ribon:0.1.0": *

#set page(width: 140mm, height: 70mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let structure = "(((...)))(((...)))"

#align(center + horizon, draw(
  sequence,
  structure: structure,
  width: 136mm,
  height: 66mm,
  theme: varna-theme,
  numbering: none,
  show-ends: false,
  annotations: (
    highlight(4, 6, fill: rgb("#ffe082").transparentize(25%)),
    base-annotation(13, fill: rgb("#313695"), text-contrast: "aaa"),
    pair-annotation(10, 18, stroke: (paint: red, thickness: 1.2pt)),
    interaction-annotation(5, 14),
  ),
))
