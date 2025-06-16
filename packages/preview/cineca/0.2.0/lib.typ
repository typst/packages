#import "/util/utils.typ": *

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
                    (style.event)(..(minutes-to-datetime(y + minutes-offset), body))
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

// Make a month view of a calendar optionally with events
#let calendar-month-summary(
  // Event list.
  // Each element is a two-element array:
  //
  // - Day. A datetime object.
  // - Additional information for showing a day. It actually depends on the template `day-summary`. For the deafult template, it requires an array of two elements.
  //   - Shape. A function specify how to darw the shape, such as `circle`.
  //   - Arguments. Further arguments for render a shape.
  events: (),
  // Templates for headers, times, or events. It takes a dictionary of the following entries: `day-summary`, `day-head`, `month-head`, and `layout`.
  template: (:),
  // Whether to put sunday as the first day of a week.
  sunday-first: false,
  // Additional arguments for the calendar's grid.
  ..args
) = {
  let yearmonths = events.map(it => (it.at(0).year(), it.at(0).month())).dedup()
  let event-group = events.map(it => it.at(0).display("[year]-[month]"))
  let style = (
    day-summary: default-day-summary,
    day-head: default-month-day-head,
    month-head: default-month-head,
    layout: stack.with(dir: ltr, spacing: 1em),
    ..template
  )
  let calendars = yearmonths.map(((year, month)) => {
    // Get all dates between date-from and date-to
    let first-day = datetime(year: year, month: month, day: 1)
    let days = get-month-days(month, year)
    let last-day = first-day + duration(days: days - 1)
    let group-id = first-day.display("[year]-[month]")
    let month-events = event-group.enumerate().filter(((i, it)) => it == group-id).map(((i, it)) => events.at(i))
    let dates = range(first-day.day(), last-day.day() + 1).map(it => datetime(
      year: first-day.year(),
      month: first-day.month(),
      day: it
    ))
    let date-weekday = dates.map(it => it.weekday() + int(sunday-first)).map(i => if i > 7 { i - 7 } else { i })
    // Get the weekdays of the dates
    let nweek = dates.map(it => it.weekday()).filter(it => it == 1).len()
    if date-weekday.at(0) > 0 {
      nweek = nweek + 1
    }
    // Map the dates and weekdays
    let week-day-map = ()
    for (i, (d, w)) in dates.zip(date-weekday).enumerate() {
      if i == 0 or w == 1 {
        week-day-map.push(())
      }
      week-day-map.last().push((d, w))
    }
    let events-map = (:)
    for e in events {
      let key = e.at(0).display("[year]-[month]-[day]")
      events-map.insert(key, e.at(1))
    }
    let header = week-day-map.at(1).map(((d, w)) => (style.day-head)(d.display("[weekday repr:short]")))
    grid(
      columns: (2em,) * 7,
      rows: (1.1em,) * (nweek + 1),
      align: center + horizon,
      ..args,
      grid.cell(colspan: 7, (style.month-head)([#first-day.display() -- #last-day.display()])),
      ..header,
      ..week-day-map.map(week => {
      (
        range(1, week.first().at(1)).map(it => []),
        week.map(((day, w)) => {
          let day-str = day.display("[year]-[month]-[day]")
          if day-str in events-map.keys() {
            (style.day-summary)(day, events-map.at(day-str))
          } else {
            (style.day-summary)(day, none)
          }
        })
      ).join()
      }).flatten()
    )
  })
  (style.layout)(..calendars)
}

#let calendar-month(
  // Event list.
  // Each element is a two-element array:
  //
  // - Day. A datetime object.
  // - Additional information for showing a day. It actually depends on the template `day-body`. For the deafult template, it requires a content.
  events,
  // Templates for headers, times, or events. It takes a dictionary of the following entries: `day-body`, `day-head`, `month-head`, and `layout`.
  template: (:),
  // Whether to put sunday as the first day of a week.
  sunday-first: false,
  // Additional arguments for the calendar's grid.
  ..args
) = {
  events = events.sorted(key: ((x, _)) => int(x.display("[year][month][day][hour][minute][second]")))
  let style = (
    day-body: default-month-day,
    day-head: default-month-day-head,
    month-head: default-month-head,
    layout: stack,
    ..template
  )
  let yearmonths = events.map(it => (it.at(0).year(), it.at(0).month())).dedup()
  let event-group = events.map(it => it.at(0).display("[year]-[month]"))
  let calendars = yearmonths.map(((year, month)) => {
    let first-day = datetime(year: year, month: month, day: 1)
    let group-id = first-day.display("[year]-[month]")
    let days = get-month-days(month, year)
    let day-range = (first-day, first-day + duration(days: days - 1))
    let month-events = event-group.enumerate().filter(((i, it)) => it == group-id).map(((i, it)) => events.at(i))
    default-month-view(
      month-events,
      day-range,
      sunday-first: sunday-first,
      style-day-body: style.at("day-body"),
      style-day-head: style.at("day-head"),
      style-month-head: style.at("month-head"),
      ..args
    )
  })
  (style.layout)(..calendars)
}
