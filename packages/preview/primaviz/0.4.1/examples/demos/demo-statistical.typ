// Statistical: histogram, box-plot, violin, waterfall
#import "../../src/lib.typ": *
#import "../demo-data.typ": league, sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  histogram(league.goals-per-match,
    width: W, height: H, title: "histogram", bins: 12, theme: lt,
  ),
  box-plot(league.minutes-played,
    width: W, height: H, title: "box-plot", show-grid: true, theme: dk,
  ),
  violin-plot(league.ratings,
    width: W, height: H, title: "violin-plot", y-label: "Rating", x-label: "Width = density", show-grid: true, theme: lt,
  ),
  waterfall-chart(sales.waterfall,
    width: W, height: H, title: "waterfall-chart", theme: dk,
  ),
))
