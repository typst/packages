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
  gantt-chart(sales.schedule,
    width: W, bar-height: 14pt, gap: 3pt, today: 7, title: "gantt-chart (dark)", x-label: "Week", theme: dk,
  ),
  timeline-chart(sales.milestones,
    width: W, event-gap: 45pt, title: "timeline-chart", theme: lt,
  ),
  chord-diagram(codebase.dependencies,
    size: 220pt, arc-width: 12pt, title: "chord-diagram", theme: dk,
  ),
))
