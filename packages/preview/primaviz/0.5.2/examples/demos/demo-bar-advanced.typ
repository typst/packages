// Advanced bar charts: grouped-stacked + diverging, light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  grouped-stacked-bar-chart(sales.channels,
    width: W, height: H, title: "grouped-stacked (light)", x-label: "Quarter", y-label: "Revenue ($K)", theme: lt,
  ),
  grouped-stacked-bar-chart(sales.channels,
    width: W, height: H, title: "grouped-stacked (dark)", x-label: "Quarter", y-label: "Revenue ($K)", theme: dk,
  ),
  diverging-bar-chart(
    (..sales.satisfaction, left-label: "Detractors", right-label: "Promoters"),
    width: W, height: H, title: "diverging-bar (light)", x-label: "Responses", theme: lt,
  ),
  diverging-bar-chart(
    (..sales.satisfaction, left-label: "Detractors", right-label: "Promoters"),
    width: W, height: H, title: "diverging-bar (dark)", x-label: "Responses", theme: dk,
  ),
))
