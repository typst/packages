// Theme comparison: same charts across all 6 themes + with-theme demo
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.4cm, paper: "a4")
#set text(size: 7pt)

#let sample = (labels: sales.monthly.labels.slice(0, 4), values: sales.monthly.values.slice(0, 4))
#let W = 170pt
#let H = 100pt

#let theme-list = (
  ("default", themes.default),
  ("minimal", themes.minimal),
  ("dark", themes.dark),
  ("presentation", themes.presentation),
  ("print", themes.print),
  ("accessible", themes.accessible),
)

// Row 1: bar chart across all 6 themes
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 6pt,
  row-gutter: 6pt,
  ..theme-list.map(((name, t)) => {
    bar-chart(sample, width: W, height: H, title: name, y-label: "Value", theme: t)
  })
)

#v(4pt)

// Row 2: line chart across all 6 themes
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 6pt,
  row-gutter: 6pt,
  ..theme-list.map(((name, t)) => {
    line-chart(sample, width: W, height: H, title: name, y-label: "Value", theme: t)
  })
)

#v(4pt)

// Row 3: with-theme — all charts inherit dark theme
#text(size: 8pt, weight: "bold")[with-theme: all charts below inherit dark theme]
#v(2pt)
#with-theme(themes.dark)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 6pt,
    bar-chart(sample, width: W, height: H, title: "bar (inherited)"),
    line-chart(sample, width: W, height: H, title: "line (inherited)"),
    pie-chart(sample, size: 70pt, title: "pie (inherited)"),
  )
]
