#import "@preview/simple-plot:0.1.0": plot

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: -2, xmax: 3,
  ymin: -2, ymax: 5,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: true,
  (fn: x => calc.exp(x), stroke: green + 1.5pt, label: $e^x$, label-pos: 0.3),
  (fn: x => if x > 0 { calc.ln(x) } else { float.nan },
   domain: (0.01, 3), stroke: orange + 1.5pt, label: $ln(x)$),
)
