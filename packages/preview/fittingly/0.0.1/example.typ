#import "fittingly.typ" as fy
#import "@preview/lilaq:0.5.0" as lq

#let x = (1, 2, 3, 4)
#let y = (2, 3, 4, 9)
#let y_vars = (2, 2, 4, 0.5)

#let fit = fy.weighted_least_squares(x, y, y_vars.map(x => 1 / (x * x)))

#let y_fit = x.map(value => fit.a + fit.b * value)

#let xs = lq.linspace(x.first(), x.last())
#let (upper, lower) = fy.confidence_interval(xs, fit, sigma: 2)

#lq.diagram(
  width: 100%,
  height: 10cm,
  xaxis: (format-ticks: none),
  yaxis: (format-ticks: none),
  legend: (position: bottom + right),
  lq.fill-between(xs, upper, y2: lower, fill: silver.transparentize(40%), label: [$95%$ Confidence Region of Fit]),
  lq.line((x.first(), y_fit.first()), (x.last(), y_fit.last()), stroke: (dash: "dashed"), label: [Linear Fit]),
  lq.plot(x, y, yerr: y_vars, stroke: none, label: [Experimental Data], mark-size: 1em),
)

