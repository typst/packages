// Line charts: single + multi-line, light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  line-chart(
    (labels: ("5.15", "5.19", "6.1", "6.3", "6.5", "6.7", "6.9"),
     values: (11.2, 11.8, 12.1, 12.5, 12.9, 13.2, 13.6)),
    width: W, height: H, title: "line-chart (light)", show-points: true, y-label: "M LoC", theme: lt,
  ),
  line-chart(
    (labels: ("5.15", "5.19", "6.1", "6.3", "6.5", "6.7", "6.9"),
     values: (11.2, 11.8, 12.1, 12.5, 12.9, 13.2, 13.6)),
    width: W, height: H, title: "line-chart (dark)", show-points: true, y-label: "M LoC", theme: dk,
  ),
  multi-line-chart(
    (labels: ("5.15", "6.0", "6.3", "6.6", "6.9"),
     series: (
       (name: "defconfig", values: (85, 92, 98, 105, 112)),
       (name: "allmodconfig", values: (340, 365, 390, 420, 445)),
       (name: "tinyconfig", values: (18, 19, 20, 21, 22)),
     )),
    width: W, height: H, title: "multi-line-chart (light)", theme: lt,
  ),
  multi-line-chart(
    (labels: ("5.15", "6.0", "6.3", "6.6", "6.9"),
     series: (
       (name: "defconfig", values: (85, 92, 98, 105, 112)),
       (name: "allmodconfig", values: (340, 365, 390, 420, 445)),
       (name: "tinyconfig", values: (18, 19, 20, 21, 22)),
     )),
    width: W, height: H, title: "multi-line-chart (dark)", theme: dk,
  ),
))
