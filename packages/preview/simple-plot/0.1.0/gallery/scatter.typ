#import "@preview/simple-plot:0.1.0": plot, scatter

#set page(width: auto, height: auto, margin: 0.5cm)

#plot(
  xmin: 0, xmax: 10,
  ymin: 0, ymax: 10,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: true,
  axis-x-pos: "bottom",
  axis-y-pos: "left",
  scatter(
    ((1, 2), (2, 3.5), (3, 2.8), (4, 5.2), (5, 4.8), (6, 6.1), (7, 5.9), (8, 7.2), (9, 8.1)),
    mark: "*",
    mark-fill: blue,
    mark-size: 0.15,
  ),
)
