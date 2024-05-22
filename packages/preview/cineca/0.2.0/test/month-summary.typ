#import "@preview/cineca:0.2.0": *

#set page(margin: 0.5in, height: 13cm, width: 14cm)

#let events = (
  (datetime(year: 2024, month: 05, day: 21), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 22), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 27), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 28), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 05, day: 29), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 03), (circle, (stroke: color.blue, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 04), (circle, (stroke: color.yellow, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 05), (circle, (stroke: color.yellow, inset: 2pt))),
  (datetime(year: 2024, month: 06, day: 10), (circle, (stroke: color.red, inset: 2pt))),
)

#calendar-month-summary(
  events: events
)

#calendar-month-summary(
  events: events,
  sunday-first: true
)

// An empty calendar
#calendar-month-summary(
  events: (
    (datetime(year: 2024, month: 05, day: 21), (none,)),
  ),
  stroke: 1pt,
)