#import "@preview/simple-plot:0.9.1": plot, zoom

#set page(width: auto, height: auto, margin: 0.5cm)

// Rectangular spy glass — vertex zoom on a parabola.
// The inset sits between the two arms where the canvas is empty.
#plot(
  xmin: -4, xmax: 4, ymin: -2, ymax: 6,
  show-grid: "major",
  (fn: x => x * x, stroke: blue + 1.5pt, label: $x^2$, label-pos: 0.9, label-side: "above-left"),
  zoom(center: (0, 0.1), size: 0.9, magnification: 3, at: "top"),
)

// Circular spy glass — sine near the origin, inset in the top-right corner
#plot(
  xmin: -5, xmax: 5, ymin: -2, ymax: 2,
  width: 12, height: 5,
  (fn: x => calc.sin(x), stroke: blue + 1.5pt, label: $sin(x)$, label-pos: 0.08),
  zoom(center: (0, 0), size: 1.2, magnification: 3,
       lens-shape: "circle", at: "top-right", accent: red),
)
