#import "@preview/ribon:0.1.0": *

#set page(width: 140mm, height: 70mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let reference = "(((...)))(((...)))"
#let alternative = "((....)).(((...)))"

#align(center + horizon, compare-structures(
  sequence,
  reference,
  alternative,
  width: 136mm,
  height: 66mm,
  legend: false,
  numbering: none,
  show-ends: false,
))
