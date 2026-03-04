// Multi-series bar charts: grouped + stacked, light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  grouped-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     series: (
       (name: "net", values: (1240, 1380, 1150, 1050)),
       (name: "fs", values: (780, 820, 910, 640)),
       (name: "mm", values: (620, 710, 680, 700)),
     )),
    width: W, height: H, title: "grouped-bar-chart (light)", theme: lt,
  ),
  grouped-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     series: (
       (name: "net", values: (1240, 1380, 1150, 1050)),
       (name: "fs", values: (780, 820, 910, 640)),
       (name: "mm", values: (620, 710, 680, 700)),
     )),
    width: W, height: H, title: "grouped-bar-chart (dark)", theme: dk,
  ),
  stacked-bar-chart(
    (labels: ("6.1", "6.2", "6.3", "6.4", "6.5"),
     series: (
       (name: "Memory", values: (42, 38, 35, 31, 28)),
       (name: "Concurrency", values: (28, 32, 25, 22, 19)),
       (name: "Logic", values: (55, 48, 52, 45, 40)),
     )),
    width: W, height: H, title: "stacked-bar-chart (light)", theme: lt,
  ),
  stacked-bar-chart(
    (labels: ("6.1", "6.2", "6.3", "6.4", "6.5"),
     series: (
       (name: "Memory", values: (42, 38, 35, 31, 28)),
       (name: "Concurrency", values: (28, 32, 25, 22, 19)),
       (name: "Logic", values: (55, 48, 52, 45, 40)),
     )),
    width: W, height: H, title: "stacked-bar-chart (dark)", theme: dk,
  ),
))
