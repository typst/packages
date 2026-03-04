// Radar charts: light, dark, 3-series, accessible
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#let data2 = (labels: ("Test Cov", "Doc", "Review", "Latency", "Churn", "Bugs"),
  series: (
    (name: "net", values: (85, 70, 92, 78, 65, 80)),
    (name: "mm", values: (72, 55, 88, 90, 45, 70)),
  ))

#let data3 = (labels: ("STR", "DEX", "CON", "INT", "WIS", "CHA"),
  series: (
    (name: "Fighter", values: (18, 12, 16, 10, 13, 8)),
    (name: "Wizard", values: (8, 14, 12, 18, 15, 11)),
    (name: "Barbarian", values: (20, 14, 18, 6, 10, 8)),
  ))

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  radar-chart(data2,
    size: 220pt, title: "radar-chart (light)", fill-opacity: 25%, theme: lt,
  ),
  radar-chart(data2,
    size: 220pt, title: "radar-chart (dark)", fill-opacity: 25%, theme: dk,
  ),
  radar-chart(data3,
    size: 220pt, title: "radar-chart (3-series)", fill-opacity: 25%, theme: lt,
  ),
  radar-chart(data3,
    size: 220pt, title: "radar-chart (accessible)", fill-opacity: 25%, theme: themes.accessible,
  ),
))
