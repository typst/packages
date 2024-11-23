#import "@preview/cineca:0.4.0": *

#set page(margin: 0.5in)

#let events = (
  (daytime("2024-2-1", "9:0:0"), [Lecture]),
  (daytime("2024-2-1", "10:0:0"), [Tutorial]),
  (daytime("2024-2-2", "10:0:0"), [Meeting]),
  (daytime("2024-2-10", "12:0:0"), [Lunch]),
  (daytime("2024-2-25", "8:0:0"), [Train]),
)

#calendar-month(
  events,
  sunday-first: false,
  template: (
    month-head: (content) => strong(content)
  )
)

= ICS

#let events2 = ics-parser(read("sample.ics")).map(event => (
  // add time attributes if missing
  datetime(
    year: event.dtstart.year() + 1, 
    month: event.dtstart.month(), 
    day: event.dtstart.day(), 
    hour: event.dtstart.hour(),
    minute: event.dtstart.minute(),
    second: 0
  ),
  event.summary
))

#calendar-month(
  events2,
  sunday-first: true,
  rows: (2em,) * 2 + (6.3em,),
  template: (
    day-body: (day, events) => {
      show: block.with(width: 100%, height: 100%, inset: 2pt)
      set align(left + top)
      stack(
        spacing: 2pt,
        pad(bottom: 4pt, text(weight: "bold", day.display("[day]"))),
        ..events.map(((d, e)) => {
          let col = if type(e) == array and e.len() > 1 { e.at(1) } else { yellow }
          show: block.with(
            fill: col.lighten(40%),
            stroke: col,
            width: 100%,
            inset: 2pt,
            radius: 2pt
          )
          d.display("[hour]")
          h(4pt)
          if type(e) == array { e.at(0) } else { e }
        })
      )
    }
  )
)
