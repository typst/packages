#import "@preview/ribon:0.1.0": *

#set page(width: 140mm, height: 82mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let structure = "(((...)))(((...)))"
#let values = (
  0.02, 0.08, 0.12, 0.86, 0.91, 0.72, 0.15, 0.09, 0.03,
  0.04, 0.11, 0.18, 0.79, 0.94, 0.83, 0.17, 0.07, 0.02,
)
#let scale = color-scale(minimum: 0, maximum: 1)

#align(center + horizon, draw(
  sequence,
  structure: structure,
  width: 136mm,
  height: 60mm,
  numbering: none,
  show-ends: false,
  annotations: value-annotations(values, scale: scale),
  legend: legend-style(stroke: none),
))
