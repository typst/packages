// Pie charts: standard + donut, light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  pie-chart(
    (labels: ("drivers", "arch", "fs", "net", "sound", "other"),
     values: (42, 16, 12, 10, 5, 15)),
    size: 220pt, title: "pie-chart (light)", theme: lt,
  ),
  pie-chart(
    (labels: ("drivers", "arch", "fs", "net", "sound", "other"),
     values: (42, 16, 12, 10, 5, 15)),
    size: 220pt, title: "pie-chart (dark)", theme: dk,
  ),
  pie-chart(
    (labels: ("merged", "rejected", "pending", "deferred"),
     values: (65, 15, 12, 8)),
    size: 220pt, title: "donut (light)", donut: true, donut-ratio: 0.5, theme: lt,
  ),
  pie-chart(
    (labels: ("merged", "rejected", "pending", "deferred"),
     values: (65, 15, 12, 8)),
    size: 220pt, title: "donut (dark)", donut: true, donut-ratio: 0.5, theme: dk,
  ),
))
