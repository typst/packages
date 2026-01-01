#import "@preview/cineca:0.5.0": calendar, events-to-calendar-items, ics-parser

#set page(margin: 0.5in, height: 25cm)

#let events = (
  ("2024-1-1", 8.00, 10.00, [Lecture 1]),
  ("2024-1-1", "10:15", "11:10", [Tutorial]),
  ("2024-1-1", (11, 35), (12, 35), [Shopping]),
  ("2024-1-1", 13.55, 15.00, [Lecture 2]),
  ("2024-1-2", 9.30, 11.30, [Lecture 2]),
  ("2024-1-2", 13.45, 14.30, [Tutorial]),
)

#calendar(events, hour-range: (8, 15), datetime-format: "[day]/[month]/[year]")

= ICS

#let events2 = ics-parser(read("sample.ics")).map(event => (
  event.dtstart,
  event.dtstart,
  event.dtend,
  event.summary
))

#calendar(events2, hour-range: (10, 14))
