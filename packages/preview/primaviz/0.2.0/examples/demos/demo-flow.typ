// Flow & timeline: sankey, gantt, timeline, chord
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  sankey-chart(
    (nodes: ("Budget", "Salary", "Invest", "Rent", "Food", "Save", "Stocks", "Bonds"),
     flows: (
       (from: 0, to: 1, value: 5000),
       (from: 0, to: 2, value: 2000),
       (from: 1, to: 3, value: 2000),
       (from: 1, to: 4, value: 1500),
       (from: 1, to: 5, value: 1500),
       (from: 2, to: 6, value: 1200),
       (from: 2, to: 7, value: 800),
     )),
    width: W, height: H, title: "sankey-chart", show-labels: true, theme: lt,
  ),
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[gantt-chart (dark)]
    #v(4pt)
    #gantt-chart(
      (tasks: (
        (name: "Research", start: 0, end: 3, group: "Plan"),
        (name: "Design", start: 2, end: 5, group: "Plan"),
        (name: "Backend", start: 4, end: 9, group: "Dev"),
        (name: "Frontend", start: 5, end: 10, group: "Dev"),
        (name: "Testing", start: 8, end: 12, group: "QA"),
        (name: "Launch", start: 12, end: 13, group: "Ship"),
       ),
       time-labels: ("W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10", "W11", "W12", "W13")),
      width: 214pt, bar-height: 14pt, gap: 3pt, today: 7, title: none, theme: dk,
    )
  ],
  timeline-chart(
    (events: (
       (date: "Jan 2024", title: "Kickoff", description: "Project started"),
       (date: "Mar 2024", title: "Alpha", description: "First release"),
       (date: "Jun 2024", title: "Beta", description: "Public beta"),
       (date: "Sep 2024", title: "v1.0", description: "Stable release"),
     )),
    width: W, event-gap: 45pt, title: "timeline-chart", theme: lt,
  ),
  chord-diagram(
    (labels: ("Web", "API", "DB", "Cache", "Queue"),
     matrix: (
       (0, 25, 15, 10, 5),
       (20, 0, 30, 8, 12),
       (10, 25, 0, 20, 5),
       (8, 5, 15, 0, 10),
       (3, 10, 5, 8, 0),
     )),
    size: 220pt, arc-width: 12pt, title: "chord-diagram", theme: dk,
  ),
))
