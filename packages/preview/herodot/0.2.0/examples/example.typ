#import "lib.typ": *
#set text(font: "New Computer Modern")

// #set text(font: "Computer Modern")
// #show raw: set text(font: "New Computer Modern Mono", size: 12pt)
#show heading: set block(above: 1.4em, below: 1em)
#show figure: set block(spacing: 0.8cm)


= Example with default package style settings
The default settings for the styling in the package, that
is provided if the properties are left unset by the writer
in the function call.

#let testevent = event(
  title: "testing",
  year: 570,
  month: 4,
  day: 16
)


#let test = timeline(
  startyear: 0,
  interval: 100,
  endyear: 600,
  events: (
    // event("birth of jesus", 0, 12, 24),
    // event(title: "death of jesus",  year: 40, month: 5, day: 12),
    event(title:"First space ship sighting", year: 570, month: 4, day: 16),
  ),
  eventspans: (
    eventspan(
      title: "Viking period",
      start-point: 3,
      end-point: 50,
    ),
    eventspan(
        title: "Random romans ",
        start-point: 100,
        end-point: 300,
      )
    ),
)

#test

= Vertical example using rotate with event-rotation and span-rotation manually set


#let temp2 = timeline(
  startyear: 0,
  endyear: 50,
  numbering-rotation: 90deg,
  event-rotation: 90deg,
  span-rotation: 90deg,
  length-of-timeline: 12,
  events:
    (
      event(year: 8, title: "event 1"),
      event(year: 24, title: "event 2"),
    ),
  eventspans: (
    eventspan(start-point: 12, end-point: 14, title: "span 1" ),
    eventspan(start-point: 20, end-point: 45, title: "span 2"),
  ),
)


#grid(
  columns: (40%, auto),
  [
    #rotate(
      90deg,
      reflow: true,
      temp2,
    )
  ],
  [
  #v(10em)
  The vertical timeline is made by wrapping a timeline function
  in a `#rotate(90deg)` function, and with the rotation of the text
  for the events and eventspans with the `event-rotation` and
  `span-rotation` fields in the timeline function manually set. ]
)



= Example with day and month fields

In previous example it is only the year field that is being set
for the events, here the day and month field are also set.

#let date-distiction = timeline(
  startyear: 10,
  endyear: 15,
  interval: 1,
  events: (
    event(day: 15, month: 7, year: 12, title: "July"),
    event(day: 15, month: 10, year: 12, title: "October"),
  )
)

#date-distiction

= Example with setting alternative colors for the event spans


#let eventspanlist = (
  eventspan(title: "Boring period", start-point: 400, end-point: 600, color: blue),
  eventspan(title: "Happy period", start-point: 700, end-point: 1000,)
)


#let alternative-colors = timeline(
  interval: 300,
  startyear: -200,
  endyear: 1000,
  events: (
    event(title: "The calendar starts", year: 0),
    event(title: "Breaking bad -  old school", year: 300)),
  eventspans: (
    eventspan(title: "Viking period", start-point: 0, end-point: 900, color: green),
    eventspan(title: "Random stuff", start-point: -100, end-point: -30)
  ),
)


#alternative-colors

= Examples of alternative spannheights

#let testw = timeline(
  interval: 300,
  startyear: -200,
  endyear: 1000,
  events: (
    event(title: "The calendar starts", year: 0),
    event(title: "Breaking bad -  old school", year: 300)
  ),

  eventspans: (
    eventspan(
      title: "Viking period",
      start-point: 0,
      end-point: 900,
      color: green
    ),
    eventspan(
      title: "Random roman stuff",
      start-point: -100,
      end-point: -30
    )
  ),
  spanheight-positive-y: 0.5
)

#let testw2 = timeline(
  interval: 300,
  startyear: -200,
  endyear: 1000,
  events: (
    event(title: "The calendar starts", year: 0),
    event(title: "Breaking bad -  old school", year: 300)
  ),
  eventspans: (
    eventspan(
      title: "Viking period",
      start-point:  0,
      end-point: 900,
      color: green),
    eventspan(
      title: "Random roman stuff",
      start-point: -100,
      end-point: -30)
    ),
  spanheight-positive-y: 0,
  spanheight-negative-y: 0.3
)

#let testw3 = timeline(
  interval: 300,
  startyear: -200,
  endyear: 1000,
  events: (
    event(title: "The calendar starts", year: 0),
    event(title: "Breaking bad -  old school", year: 300)
  ),
  eventspans: (
    eventspan(title: "Viking period", start-point: 0, end-point: 900, color: green),
    eventspan(title: "Random roman stuff", start-point: -100, end-point: -30)),
  spanheight-positive-y: 0.6,
  spanheight-negative-y: 0.3
)

#testw
#testw2
#testw3




