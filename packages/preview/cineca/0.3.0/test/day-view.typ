#import "@preview/cineca:0.3.0": calendar, events-to-calendar-items, ics-parser

#set page(margin: 0.5in, height: 25cm)

#let events = (
  (1, 8.00, 10.00, [Lecture 1]),
  (1, 10.00, 11.00, [Tutorial]),
  (1, 11.30, 12.30, [Shopping]),
  (1, 13.55, 15.00, [Lecture 2]),
  (2, 9.30, 11.30, [Lecture 2]),
  (2, 13.45, 14.30, [Tutorial]),
)

#calendar(events, hour-range: (8, 15))

= ICS

#let events2 = ics-parser(read("sample.ics")).map(event => (
  event.dtstart.weekday() - 4, 
  event.dtstart.hour() + event.dtstart.minute() / 100,
  event.dtend.hour()   + event.dtend.minute()   / 100,
  event.summary
))

#calendar(events2, hour-range: (10, 14))
