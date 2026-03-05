// Comparison: slope, dumbbell, lollipop, bullet
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales, codebase
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  slope-chart(
    (..sales.slope, start-label: "H1", end-label: "H2"),
    width: W, height: H, title: "slope-chart", theme: lt,
  ),
  dumbbell-chart(
    (..sales.dumbbell, start-label: "Q1", end-label: "Q4"),
    width: W, height: H, title: "dumbbell-chart", show-values: true, theme: dk,
  ),
  lollipop-chart(codebase.subsystems,
    width: W, height: H, title: "lollipop-chart", theme: lt,
  ),
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[bullet-chart (dark)]
    #v(6pt)
    #bullet-chart(sales.revenue-target.actual, sales.revenue-target.target, sales.revenue-target.ranges, width: 210pt, height: 28pt, title: "Revenue", theme: dk)
    #v(6pt)
    #bullet-chart(82, 90, (60, 80, 100), width: 210pt, height: 28pt, title: "Satisfaction", theme: dk)
    #v(6pt)
    #bullet-chart(45, 50, (25, 40, 60), width: 210pt, height: 28pt, title: "Customers", theme: dk)
  ],
))
