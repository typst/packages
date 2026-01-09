#import "@preview/simple-plot:0.1.0": plot, scatter

#set page(width: auto, height: auto, margin: 0.5cm)

// Showcase different marker types
#plot(
  xmin: 0, xmax: 8,
  ymin: 0, ymax: 8,
  width: 8, height: 8,
  show-grid: "major",
  axis-x-pos: "bottom",
  axis-y-pos: "left",
  scatter(((1, 7),), mark: "o", mark-size: 0.2, mark-stroke: blue + 1pt),
  scatter(((2, 7),), mark: "*", mark-size: 0.2, mark-fill: blue),
  scatter(((3, 7),), mark: "square", mark-size: 0.2, mark-stroke: red + 1pt),
  scatter(((4, 7),), mark: "square*", mark-size: 0.2, mark-fill: red),
  scatter(((5, 7),), mark: "triangle", mark-size: 0.2, mark-stroke: green + 1pt),
  scatter(((6, 7),), mark: "triangle*", mark-size: 0.2, mark-fill: green),
  scatter(((1, 5),), mark: "diamond", mark-size: 0.2, mark-stroke: purple + 1pt),
  scatter(((2, 5),), mark: "diamond*", mark-size: 0.2, mark-fill: purple),
  scatter(((3, 5),), mark: "star", mark-size: 0.2, mark-stroke: orange + 1pt),
  scatter(((4, 5),), mark: "star*", mark-size: 0.2, mark-fill: orange),
  scatter(((5, 5),), mark: "+", mark-size: 0.2, mark-stroke: black + 1.5pt),
  scatter(((6, 5),), mark: "x", mark-size: 0.2, mark-stroke: black + 1.5pt),
)
