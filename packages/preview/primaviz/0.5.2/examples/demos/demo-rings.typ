// Rings & treemap: ring-progress light + dark, treemap light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": league, sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  ring-progress(league.season-targets,
    size: 180pt, ring-width: 16pt, title: "ring-progress (light)", theme: lt,
  ),
  ring-progress(league.season-targets,
    size: 180pt, ring-width: 16pt, title: "ring-progress (dark)", theme: dk,
  ),
  treemap(sales.expenses,
    width: W, height: H, title: "treemap (light)", theme: lt,
  ),
  treemap(sales.expenses,
    width: W, height: H, title: "treemap (dark)", theme: dk,
  ),
))
