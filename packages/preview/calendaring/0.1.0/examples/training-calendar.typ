// Periodization view: events render below the day number,
// and `today` highlights the current training day.

#import "@preview/calendaring:0.1.0": month-grid

#set page(paper: "a4", margin: 1.5cm)

#align(center, text(16pt, weight: "bold")[June 2026 — Training Calendar])

#v(0.3cm)

#month-grid(
  2026, 6,
  cell-width: 1fr,
  cell-height: 2.4cm,
  today: datetime(year: 2026, month: 6, day: 11),
  events: (
    (datetime(year: 2026, month: 6, day: 1),  [Peak block]),
    (datetime(year: 2026, month: 6, day: 7),  [1RM test]),
    (datetime(year: 2026, month: 6, day: 15), [Deload]),
    (datetime(year: 2026, month: 6, day: 21), [Race]),
    (datetime(year: 2026, month: 6, day: 22), [Recovery]),
  ),
)
