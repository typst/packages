#import "@preview/simple-plot:0.2.0": plot

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: -2 * calc.pi, xmax: 2 * calc.pi,
  ymin: -1.5, ymax: 1.5,
  width: 10, height: 5,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: "major",
  xtick: (-2*calc.pi, -calc.pi, 0, calc.pi, 2*calc.pi),
  xtick-labels: ($-2 pi$, $-pi$, $0$, $pi$, $2 pi$),
  (fn: x => calc.sin(x), stroke: blue + 1.2pt, label: $sin(x)$, label-pos: 0.85, label-side: "below-right"),
  (fn: x => calc.cos(x), stroke: red + 1.2pt, label: $cos(x)$, label-pos: 0.15, label-side: "above-right"),
)
