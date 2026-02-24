#import "@preview/simple-plot:0.1.0": plot

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: -3, xmax: 3,
  ymin: -1, ymax: 9,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: true,
  (fn: x => calc.pow(x, 2), stroke: blue + 1.5pt, label: $x^2$),
)
