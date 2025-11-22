#import "@preview/cineca:0.4.0": *

#set page(width: 20cm, height: 18cm, flipped: false, margin: 0.5in)

#let events = (
  (day("2024-02-21"), (circle, (stroke: color.green, inset: 2pt))),
  (day("2024-02-22"), (circle, (stroke: color.green, inset: 2pt))),
  (day("2024-05-27"), (circle, (stroke: color.green, inset: 2pt))),
  (day("2024-05-28"), (circle, (stroke: color.blue, inset: 2pt))),
  (day("2024-05-29"), (circle, (stroke: color.blue, inset: 2pt))),
  (day("2024-06-03"), (circle, (stroke: color.blue, inset: 2pt))),
  (day("2024-06-04"), (circle, (stroke: color.yellow, inset: 2pt))),
  (day("2024-06-05"), (circle, (stroke: color.yellow, inset: 2pt))),
  (day("2024-06-10"), (circle, (stroke: color.red, inset: 2pt))),
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

= ICS

#let events2 = ics-parser(read("sample.ics")).map(event => (
  // add time attributes if missing
  event.dtstart, (circle, (stroke: color.blue))
))

#calendar-month-summary(
  events: events2,
  stroke: 0pt,
)