// The cell-content callback receives a `datetime`, so the weekday
// can be computed directly without closing over year/month.

#import "@preview/calendaring:0.1.0": month-grid

#set page(paper: "a4", margin: 2cm)

#align(center, text(16pt, weight: "bold")[June 2026])

#v(0.3cm)

#month-grid(
  2026, 6,
  cell-width: 1fr,
  cell-height: 2cm,
  cell-content: date => {
    if date.weekday() >= 6 {
      table.cell(fill: luma(240))[
        #text(8pt, weight: "bold", fill: luma(110))[#date.day()]
      ]
    } else {
      text(8pt, weight: "bold")[#date.day()]
    }
  },
)
