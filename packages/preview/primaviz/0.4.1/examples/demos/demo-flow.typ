// Flow & timeline: sankey, gantt, timeline, chord
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales, codebase
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  sankey-chart(sales.budget-flow,
    width: W, height: H, title: "sankey-chart", show-labels: true, theme: lt,
  ),
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[gantt-chart (dark)]
    #v(4pt)
    #gantt-chart(sales.schedule,
      width: 214pt, bar-height: 14pt, gap: 3pt, today: 7, title: none, theme: dk,
    )
  ],
  timeline-chart(sales.milestones,
    width: W, event-gap: 45pt, title: "timeline-chart", theme: lt,
  ),
  chord-diagram(codebase.dependencies,
    size: 220pt, arc-width: 12pt, title: "chord-diagram", theme: dk,
  ),
))
