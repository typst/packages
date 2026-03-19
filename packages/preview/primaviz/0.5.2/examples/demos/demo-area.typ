// Area charts: single + stacked, light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  area-chart(sales.monthly,
    width: W, height: H, title: "area-chart (light)", fill-opacity: 40%, x-label: "Month", y-label: "Revenue ($K)", theme: lt,
  ),
  area-chart(sales.monthly,
    width: W, height: H, title: "area-chart (dark)", fill-opacity: 40%, x-label: "Month", y-label: "Revenue ($K)", theme: dk,
  ),
  stacked-area-chart(sales.monthly-series,
    width: W, height: H, title: "stacked-area-chart (light)", x-label: "Month", y-label: "Commits", theme: lt,
  ),
  stacked-area-chart(sales.monthly-series,
    width: W, height: H, title: "stacked-area-chart (dark)", x-label: "Month", y-label: "Commits", theme: dk,
  ),
))
