// Multi-series bar charts: grouped + stacked, light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  grouped-bar-chart(sales.quarterly,
    width: W, height: H, title: "grouped-bar-chart (light)", x-label: "Quarter", y-label: "Count", theme: lt,
  ),
  grouped-bar-chart(sales.quarterly,
    width: W, height: H, title: "grouped-bar-chart (dark)", x-label: "Quarter", y-label: "Count", theme: dk,
  ),
  stacked-bar-chart(sales.quarterly,
    width: W, height: H, title: "stacked-bar-chart (light)", x-label: "Quarter", y-label: "Revenue", theme: lt,
  ),
  stacked-bar-chart(sales.quarterly,
    width: W, height: H, title: "stacked-bar-chart (dark)", x-label: "Quarter", y-label: "Revenue", theme: dk,
  ),
))
