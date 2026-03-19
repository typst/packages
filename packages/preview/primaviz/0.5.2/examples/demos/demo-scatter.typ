// Scatter charts: scatter, dark scatter, multi-scatter, bubble
#import "../../src/lib.typ": *
#import "../demo-data.typ": league
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  scatter-plot(league.team-scatter,
    width: W, height: H, title: "scatter-plot (light)",
    x-label: "Goals Scored", y-label: "Goals Conceded", theme: lt,
  ),
  scatter-plot(league.team-scatter,
    width: W, height: H, title: "scatter-plot (dark)",
    x-label: "Goals Scored", y-label: "Goals Conceded", theme: dk,
  ),
  multi-scatter-plot(league.home-away,
    width: W, height: H, title: "multi-scatter-plot",
    x-label: "Goals Scored", y-label: "Goals Conceded", theme: lt,
  ),
  bubble-chart(league.team-bubble,
    width: W, height: H, title: "bubble-chart (dark)",
    x-label: "Goals", y-label: "Possession %",
    show-labels: true, labels: league.team-bubble.labels, theme: dk,
  ),
))
