#import "/util/utils.typ": minutes-to-datetime, events-to-calendar-items, default-header-style, default-item-style, default-time-style

// Make a calendar with events.
#let calendar(
  // Event list.
  // Each element is a four-element array:
  //
  // - Index of day. Start from 0.
  // - Float-style start time.
  // - Float-style end time.
  // - Event body. Can be anything. Passed to the template.body to show more details.
  //
  // Float style time: a number representing 24-hour time. The integer part represents the hour. The fractional part represents the minute.
  events,
  // Then range of hours, affacting the range of the calendar.
  hour-range: (8, 20),
  // Height of per minute. Each minute occupys a row. This number is to control the height of each row.
  minute-height: 0.8pt,
  // Templates for headers, times, or events. It takes a dictionary of the following entries: `header`, `time`, and `event`.
  template: (:),
  // A stroke style to control the style of the default stroke, or a function taking two parameters `(x, y)` to control the stroke. The first row is the dates, and the first column is the times.
  stroke: none
) = {
  let items = events-to-calendar-items(events, hour-range.at(0))
  let days = items.keys().len()
  let hours = hour-range.at(1) - hour-range.at(0)
  let style = (
    header: default-header-style,
    time: default-time-style,
    event: default-item-style,
    ..template
  )
  let minutes-offset = hour-range.at(0) * 60
  let stroke-shape = if type(stroke) == "stroke" { stroke } else { 0.1pt + black }
  let stroke-rule = if type(stroke) == "function" { stroke } else { (x, y) => (
    right: if y < (hours * 60 + 1) { stroke-shape } else { 0pt },
    top: if x > 0 { if y < 1 { stroke-shape } else if calc.fract((y - 1) / 60) == 0 { stroke-shape } else { 0pt } }
  ) }
  grid(
    columns:(auto,) + (1fr,)*days,
    rows: (auto, ) + (minute-height,) * hours * 60 + (8pt,),
    fill: white,
    stroke: stroke-rule,
    [], ..array.range(days).map(d => (style.header)(d)),
    ..array.range(hours * 60 + 1).map(y => {
      array.range(days + 1).map(x => {
        if x == 0 {
          if calc.fract(y / 60) == 0 {
            let hour = calc.trunc(y / 60) + hour-range.at(0)
            let t = datetime(hour: hour, minute: 0, second: 0)
            (style.time)(t)
          } else []
        } else {
          if items.keys().contains(str(x)) {
            if items.at(str(x)).keys().contains(str(y)) {
              let (last, body) = items.at(str(x)).at(str(y))
              show: block.with(inset: (x: 2pt, y: 0pt), width: 100%)
              place({
                block(
                  width: 100%, 
                  height: (last) * minute-height,
                  {
                    (style.event)(time: minutes-to-datetime(y + minutes-offset), body)
                  }
                )
              })
            }
          }
        }
      })
    }).flatten()
  )
}
