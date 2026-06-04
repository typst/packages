#import "@preview/simple-plot:0.2.6": plot

#set page(width: auto, height: auto, margin: 0.5cm)

// Showcases: major grid only, grid-label-break, axis extension, integer ticks
#plot(
  xmin: -3, xmax: 3,
  ymin: -1, ymax: 9,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: "major",
  (fn: x => calc.pow(x, 2), stroke: blue + 1.5pt, label: $x^2$, label-pos: 0.7, label-side: "below-right"),
)
