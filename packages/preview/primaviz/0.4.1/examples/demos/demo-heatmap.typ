// Heatmaps: heatmap light + dark, calendar-heatmap, correlation-matrix
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales, codebase
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  heatmap(sales.activity,
    cell-size: 42pt, title: "heatmap (light)", palette: "viridis", theme: lt,
  ),
  heatmap(sales.activity,
    cell-size: 42pt, title: "heatmap (dark)", palette: "viridis", theme: dk,
  ),
  calendar-heatmap(sales.daily-deals,
    cell-size: 16pt, title: "calendar-heatmap", palette: "heat", theme: lt,
  ),
  correlation-matrix(codebase.correlation,
    cell-size: 42pt, title: "correlation-matrix", theme: dk,
  ),
))
