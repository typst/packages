#import "@preview/calendaring:0.1.0": month-grid

#set page(paper: "a4")

= June 2026

#month-grid(2026, 6)

#pagebreak()

= February 2024 (leap day)

#month-grid(2024, 2)

#pagebreak()

= Sunday-first, smaller cells

#month-grid(2026, 1, week-start: "sun", cell-height: 1.8cm, cell-width: 2.5cm)

#pagebreak()

= Custom cell content (datetime callback)

#let rotation = ("KB-S&C", "KB-cond", "Cardio", "Gym", "Hyrox", "rest", "rest")

#month-grid(2026, 6, cell-height: 2.2cm, cell-content: date => [
  #text(8pt, weight: "bold")[#date.day()]
  #v(2pt)
  #text(7pt, fill: luma(120))[#rotation.at(date.weekday() - 1)]
])
