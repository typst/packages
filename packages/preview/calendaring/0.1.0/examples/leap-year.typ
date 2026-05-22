// February renders correctly in both leap and non-leap years.
// The `is-leap-year` helper is exported for user code.

#import "@preview/calendaring:0.1.0": month-grid, is-leap-year

#set page(paper: "a4", margin: 1.5cm)

#align(center, text(18pt, weight: "bold")[February 2024 — leap year])
#align(center, text(10pt, fill: luma(120))[is-leap-year(2024) = #is-leap-year(2024)])

#v(0.3cm)

#month-grid(
  2024, 2,
  cell-width: 1fr,
  cell-height: 2.2cm,
  events: (
    (datetime(year: 2024, month: 2, day: 29), [Leap day]),
  ),
)

#pagebreak()

#align(center, text(18pt, weight: "bold")[February 2025 — not a leap year])
#align(center, text(10pt, fill: luma(120))[is-leap-year(2025) = #is-leap-year(2025)])

#v(0.3cm)

#month-grid(
  2025, 2,
  cell-width: 1fr,
  cell-height: 2.2cm,
)
