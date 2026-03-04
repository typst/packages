// Scatter charts: scatter, dark scatter, multi-scatter, bubble
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  scatter-plot(
    (x: (12, 28, 45, 8, 35, 18, 52),
     y: (3, 12, 22, 2, 18, 8, 28)),
    width: W, height: H, title: "scatter-plot (light)",
    x-label: "Complexity", y-label: "Bugs", theme: lt,
  ),
  scatter-plot(
    (x: (12, 28, 45, 8, 35, 18, 52),
     y: (3, 12, 22, 2, 18, 8, 28)),
    width: W, height: H, title: "scatter-plot (dark)",
    x-label: "Complexity", y-label: "Bugs", theme: dk,
  ),
  multi-scatter-plot(
    (series: (
       (name: "net", points: ((5, 12), (8, 18), (12, 25), (15, 30))),
       (name: "fs", points: ((4, 8), (7, 14), (11, 16), (14, 22))),
       (name: "mm", points: ((3, 5), (6, 10), (10, 13), (13, 18))),
     )),
    width: W, height: H, title: "multi-scatter-plot",
    x-label: "Commits (K)", y-label: "Churn (K LoC)", theme: lt,
  ),
  bubble-chart(
    (x: (45, 85, 120, 65, 95),
     y: (12, 18, 8, 22, 15),
     size: (300, 180, 450, 120, 250),
     labels: ("net", "fs", "drv", "mm", "arch")),
    width: W, height: H, title: "bubble-chart (dark)",
    x-label: "Files (K)", y-label: "Open Bugs",
    show-labels: true, labels: ("net", "fs", "drv", "mm", "arch"), theme: dk,
  ),
))
