#import "@preview/simple-plot:0.2.0": plot

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: -5, xmax: 5,
  ymin: -3, ymax: 5,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: true,
  axis-x-extend: 0.5,
  axis-y-extend: 0.5,
  (fn: x => 0.2 * calc.pow(x, 2) - 2, stroke: blue + 1.5pt, label: $f$, label-pos: 0.9, label-side: "below-right"),
  (fn: x => -0.5 * x + 1, stroke: red + 1.5pt, label: $g$, label-pos: 0.2, label-side: "above-right"),
)
