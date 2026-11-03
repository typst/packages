// Wall-calendar layout: ISO 8601 week numbers in a leading column.

#import "@preview/calendaring:0.1.0": month-grid

#set page(paper: "a4", margin: 1.5cm)

#align(center, text(22pt, weight: "bold")[June 2026])

#v(0.4cm)

#month-grid(
  2026, 6,
  cell-width: 1fr,
  cell-height: 2.6cm,
  week-numbers: true,
)
