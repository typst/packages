#import "@preview/cineca:0.2.1": calendar, events-to-calendar-items

#set page(margin: 0.5in, height: 15cm)

#let events = (
  (1, 8.00, 10.00, [Lecture 1]),
  (1, 10.00, 11.00, [Tutorial]),
  (1, 11.30, 12.30, [Shopping]),
  (1, 13.55, 15.00, [Lecture 2]),
  (1, 15.00, 16.20, [Project 1]),
  (2, 9.30, 11.30, [Lecture 2]),
  (2, 13.45, 14.30, [Tutorial]),
  (2, 18.00, 20.00, [Dinner with friends]),
)

#calendar(events, hour-range: (8, 14))
