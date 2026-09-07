#import "@preview/simple-plot:1.0.0": plot

#set page(width: auto, height: auto, margin: 0.5cm)

// Showcases: domain restriction, grid-label-break
#plot(
  xmin: -2, xmax: 3,
  ymin: -2, ymax: 5,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: "both",
  minor-grid-step: 5,
  (fn: x => calc.exp(x), stroke: green + 1.5pt, label: $e^x$, label-pos: 0.65, label-side: "left"),
  (fn: x => if x > 0 { calc.ln(x) } else { float.nan },
   domain: (0.01, 3), stroke: orange + 1.5pt, label: $ln(x)$, label-pos: 0.9, label-side: "above-right"),
)
