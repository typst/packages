#import "@preview/ribon:0.1.0": *

#set page(width: 100mm, height: 70mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let result = analyze(sequence)

#align(center + horizon, render(
  result,
  which: "mea",
  width: 96mm,
  height: 66mm,
  theme: varna-theme,
  numbering: none,
  show-ends: false,
))
