#import "@preview/simple-plot:0.9.0": plot, zoom

#set page(width: auto, height: auto, margin: 0.5cm)

// Rectangular spy glass — vertex zoom on a parabola
#plot(
  xmin: -4, xmax: 4, ymin: -2, ymax: 6,
  show-grid: "major",
  (fn: x => x * x, stroke: blue + 1.5pt, label: $x^2$, label-pos: 0.85, label-side: "above-right"),
  zoom(center: (0, 0.1), size: 0.9, magnification: 4, at: "top-right"),
)

// Circular spy glass — sine near zero
#plot(
  xmin: -5, xmax: 5, ymin: -2, ymax: 2,
  (fn: x => calc.sin(x), stroke: blue + 1.5pt, label: $sin(x)$, label-pos: 0.88),
  zoom(region: (-0.5, -0.6, 0.5, 0.6),
       lens-shape: "circle", magnification: 5,
       at: (3, 1.2), accent: red),
)
