#import "@preview/simple-plot:0.1.0": plot, line-plot

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: 0, xmax: 10,
  ymin: 0, ymax: 12,
  xlabel: [Time (s)],
  ylabel: [Distance (m)],
  show-grid: true,
  axis-x-pos: "bottom",
  axis-y-pos: "left",
  // Experimental data points
  line-plot(
    ((0, 0), (1, 0.5), (2, 1.8), (3, 4.2), (4, 5.1), (5, 6.8), (6, 8.2), (7, 9.5)),
    stroke: blue + 1pt,
    mark: "*",
    mark-fill: blue,
    label: [Data],
  ),
  // Theoretical model fit
  (fn: x => 0.15 * calc.pow(x, 2) + 0.3 * x,
   stroke: red + 1.2pt, label: [Model], label-pos: 0.9),
)
