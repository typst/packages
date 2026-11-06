#import "@preview/cineca:0.3.0": *

#set page(width: 20cm, height: 18cm, flipped: false, margin: 0.5in)

#let events = (
  (datetime(year: 2024, month: 02, day: 21), (circle, (stroke: color.green, inset: 2pt))),
  (datetime(year: 2024, month: 02, day: 22), (circle, (stroke: color.green, inset: 2pt))),
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

= ICS

#let events2 = ics-parser(read("sample.ics")).map(event => (
  // add time attributes if missing
  datetime(
    year: event.dtstart.year() + 1, 
    month: event.dtstart.month(), 
    day: event.dtstart.day(), 
    hour: 0, minute: 0, second: 0
  ),
  (circle, (stroke: color.blue))
))

#calendar-month-summary(
  events: events2,
  stroke: 0pt,
)