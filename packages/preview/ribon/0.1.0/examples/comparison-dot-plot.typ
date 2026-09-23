#import "@preview/ribon:0.1.0": *

#set page(width: 104mm, height: 104mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GGGAAACCCGGGAAACCC"
#let untreated = analyze(sequence)
#let treated = analyze(
  sequence,
  constraints: folding-constraints(force-unpaired: (1, 2)),
)

#align(center + horizon, dot-plot(
  sequence,
  probabilities: untreated,
  comparison: treated,
  width: 100mm,
  height: 100mm,
  threshold: 0.005,
  legend: false,
  x-label: none,
  y-label: none,
  x-axis: axis-style(label: none, show-labels: false),
  y-axis: axis-style(label: none, show-labels: false),
))
