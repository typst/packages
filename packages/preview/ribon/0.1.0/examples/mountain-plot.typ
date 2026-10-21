#import "@preview/ribon:0.1.0": *

#set page(width: 150mm, height: 58mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let result = analyze(sequence)

#align(center + horizon, mountain-plot(
  sequence,
  probabilities: result,
  reference-structures: (),
  width: 146mm,
  height: 54mm,
  legend: false,
  x-label: none,
  y-label: none,
  x-axis: axis-style(label: none, show-labels: false),
  y-axis: axis-style(label: none, show-labels: false, minor-tick-step: 0.5, grid: "both"),
  layout: plot-layout(aspect: 2.7),
))
