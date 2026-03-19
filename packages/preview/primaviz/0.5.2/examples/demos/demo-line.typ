// Line charts: single + multi-line, light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  line-chart(sales.monthly,
    width: W, height: H, title: "line-chart (light)", show-points: true, x-label: "Session", y-label: "Revenue ($K)", theme: lt,
  ),
  line-chart(sales.monthly,
    width: W, height: H, title: "line-chart (dark)", show-points: true, x-label: "Session", y-label: "Revenue ($K)", theme: dk,
  ),
  multi-line-chart(sales.monthly-series,
    width: W, height: H, title: "multi-line-chart (light)", x-label: "Gameweek", y-label: "Goals", theme: lt,
  ),
  multi-line-chart(sales.monthly-series,
    width: W, height: H, title: "multi-line-chart (dark)", x-label: "Gameweek", y-label: "Goals", theme: dk,
  ),
))
