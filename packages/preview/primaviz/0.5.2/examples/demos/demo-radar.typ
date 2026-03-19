// Radar charts: light, dark, 3-series, accessible
#import "../../src/lib.typ": *
#import "../demo-data.typ": league
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#let two-series = (
  labels: league.player-stats.labels,
  series: league.player-stats.series.slice(0, 2),
)

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  radar-chart(two-series,
    size: 200pt, title: "radar-chart (light)", fill-opacity: 15%, theme: lt,
  ),
  radar-chart(two-series,
    size: 200pt, title: "radar-chart (dark)", fill-opacity: 15%, theme: dk,
  ),
  radar-chart(league.player-stats,
    size: 200pt, title: "radar-chart (3-series)", fill-opacity: 15%, theme: lt,
  ),
  radar-chart(league.player-stats,
    size: 200pt, title: "radar-chart (accessible)", fill-opacity: 15%, theme: themes.accessible,
  ),
))
