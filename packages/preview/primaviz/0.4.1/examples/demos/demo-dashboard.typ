// Dashboard: metric-row, word-cloud, sparklines-table, progress-bars
#import "@preview/primaviz:0.4.1": *
#import "../demo-data.typ": sales, words
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  [
    #text(size: 9pt, weight: "bold")[metric-row]
    #v(4pt)
    #metric-row(sales.kpis,
      width: 250pt, gap: 5pt, theme: lt,
    )
  ],
  word-cloud(words,
    width: W, height: 300pt, title: "word-cloud (dark, circle)", shape: "circle", theme: dk,
  ),
  [
    #text(size: 9pt, weight: "bold")[sparkline / sparkbar / sparkdot]
    #v(4pt)
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      [*Metric*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [Networking], [#sparkline(sales.sparklines.networking, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.networking, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.networking, color: rgb("#e15759"), width: 50pt, height: 12pt)],
      [Memory], [#sparkline(sales.sparklines.memory, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.memory, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.memory, color: rgb("#59a14f"), width: 50pt, height: 12pt)],
      [Storage], [#sparkline(sales.sparklines.storage, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.storage, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.storage, color: rgb("#59a14f"), width: 50pt, height: 12pt)],
    )
  ],
  progress-bars(sales.targets,
    width: W, title: "progress-bars", theme: dk,
  ),
))
