#import "@preview/cineca:0.2.1": *

#set page(margin: 0.5in)

#let events = (
  (datetime(year: 2024, month: 2, day: 1, hour: 9, minute: 0, second: 0), [Lecture]),
  (datetime(year: 2024, month: 2, day: 1, hour: 10, minute: 0, second: 0), [Tutorial]),
  (datetime(year: 2024, month: 2, day: 2, hour: 10, minute: 0, second: 0), [Meeting]),
  (datetime(year: 2024, month: 2, day: 10, hour: 12, minute: 0, second: 0), [Lunch]),
  (datetime(year: 2024, month: 2, day: 25, hour: 8, minute: 0, second: 0), [Train]),
)

#calendar-month(
  events,
  sunday-first: false,
  template: (
    month-head: (content) => strong(content)
  )
)

#let events2 = (
  (datetime(year: 2024, month: 5, day: 1, hour: 9, minute: 0, second: 0), ([Lecture], blue)),
  (datetime(year: 2024, month: 5, day: 1, hour: 10, minute: 0, second: 0), ([Tutorial], red)),
  (datetime(year: 2024, month: 5, day: 1, hour: 11, minute: 0, second: 0), [Lab]),
)

#calendar-month(
  events2,
  sunday-first: true,
  rows: (2em,) * 2 + (8em,),
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
