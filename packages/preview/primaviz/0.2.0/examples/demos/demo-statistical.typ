// Statistical: histogram, box-plot, violin, waterfall
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  histogram(
    (2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8,
     9, 9, 10, 10, 11, 12, 14, 15, 18, 22, 25, 30, 35, 42, 55, 70, 95),
    width: W, height: H, title: "histogram", bins: 12, theme: lt,
  ),
  box-plot(
    (labels: ("CFS", "EEVDF", "BPF", "RT"),
     boxes: (
       (min: 5, q1: 12, median: 18, q3: 28, max: 45),
       (min: 3, q1: 8, median: 14, q3: 22, max: 38),
       (min: 2, q1: 6, median: 11, q3: 18, max: 30),
       (min: 1, q1: 3, median: 5, q3: 8, max: 15),
     )),
    width: W, height: H, title: "box-plot", show-grid: true, theme: dk,
  ),
  violin-plot(
    (labels: ("Group A", "Group B", "Group C"),
     datasets: (
       (5, 8, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 52, 55),
       (10, 15, 20, 22, 25, 25, 28, 30, 30, 32, 35, 35, 38, 40, 42, 45, 50, 55, 60, 65),
       (2, 5, 8, 10, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 38, 42, 48, 55, 62, 70),
     )),
    width: W, height: H, title: "violin-plot", y-label: "Value", x-label: "Width = density", show-grid: true, theme: lt,
  ),
  waterfall-chart(
    (labels: ("Start", "+Sales", "+Svc", "-COGS", "-OpEx", "Total"),
     values: (1200, 350, 180, -280, -150, 1300)),
    width: W, height: H, title: "waterfall-chart", theme: dk,
  ),
))
