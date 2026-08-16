#import "@preview/calendaring:0.1.0": month-grid

#set page(paper: "a4", margin: 1.5cm)

#align(center, text(16pt, weight: "bold")[June 2026 — Daily Habits])

#v(0.3cm)

#let habits = ("Mobility", "Read 20m", "Walk", "Water 2L")

#month-grid(
  2026, 6,
  cell-width: 1fr,
  cell-height: 2.4cm,
  cell-content: date => {
    text(8pt, weight: "bold")[#date.day()]
    v(2pt)
    stack(spacing: 2pt, ..habits.map(h => text(6.5pt)[☐ #h]))
  },
)
