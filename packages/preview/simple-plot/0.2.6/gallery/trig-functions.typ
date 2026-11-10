#import "@preview/simple-plot:0.2.6": plot

#set page(width: auto, height: auto, margin: 0.5cm)

// Showcases: custom tick labels, grid-label-break with pi notation
#plot(
  xmin: -2.0 * calc.pi, xmax: 2.0 * calc.pi,
  ymin: -1.5, ymax: 1.5,
  width: 10, height: 5,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: "major",
  show-origin: false,  // Avoid duplicate "0" with custom xtick-labels
  xtick: (-2.0*calc.pi, -calc.pi, calc.pi, 2.0*calc.pi),
  xtick-labels: ($-2 pi$, $-pi$, $pi$, $2 pi$),
  (fn: x => calc.sin(x), stroke: blue + 1.2pt, samples: 200, label: $sin(x)$, label-pos: 0.65, label-side: "below"),
  (fn: x => calc.cos(x), stroke: red + 1.2pt, samples: 200, label: $cos(x)$, label-pos: 0.9, label-side: "above"),
)
