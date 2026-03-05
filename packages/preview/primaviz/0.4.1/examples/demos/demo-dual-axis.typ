// Dual-axis chart: light, dark, presentation, minimal
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  dual-axis-chart(sales.dual-axis,
    width: W, height: H, title: "dual-axis (light)", theme: lt,
  ),
  dual-axis-chart(sales.dual-axis,
    width: W, height: H, title: "dual-axis (dark)", theme: dk,
  ),
  dual-axis-chart(sales.dual-axis,
    width: W, height: H, title: "dual-axis (presentation)", theme: themes.presentation,
  ),
  dual-axis-chart(sales.dual-axis,
    width: W, height: H, title: "dual-axis (minimal)", theme: themes.minimal,
  ),
))
