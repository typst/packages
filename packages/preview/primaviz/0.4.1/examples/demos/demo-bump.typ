// Bump & funnel: bump light + dark, funnel light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": codebase, sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  bump-chart(codebase.rankings,
    width: W, height: H, title: "bump-chart (light)", dot-size: 4pt, theme: lt,
  ),
  bump-chart(codebase.rankings,
    width: W, height: H, title: "bump-chart (dark)", dot-size: 4pt, theme: dk,
  ),
  funnel-chart(sales.funnel,
    width: W, height: H, title: "funnel-chart (light)", theme: lt,
  ),
  funnel-chart(sales.funnel,
    width: W, height: H, title: "funnel-chart (dark)", theme: dk,
  ),
))
