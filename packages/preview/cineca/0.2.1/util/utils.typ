#let minutes-to-datetime(minutes) = {
  let h = calc.trunc(minutes / 60)
  let m = int(calc.round(calc.fract(minutes / 60) * 60))
  return datetime(hour: h, minute: m, second: 0)
}

#let events-to-calendar-items(events, start) = {
  let dict = (:)
  for value in events {
    if value.len() < 4 {
      continue
    }
    let kday = str(value.at(0))
    let stime = float(value.at(1))
    let etime = float(value.at(2))
    let body = value.at(3)
    if not dict.keys().contains(kday) {
      dict.insert(kday, (:))
    }
    let istart = calc.min((calc.trunc(stime) - start), 24) * 60 + calc.min(calc.round(calc.fract(stime) * 100), 60)
    let iend = calc.min((calc.trunc(etime) - start), 24) * 60 + calc.min(calc.round(calc.fract(etime) * 100), 60)
    let ilast = iend - istart
    if ilast > 0 {
      dict.at(kday).insert(str(istart), (ilast, body))
    }
  }
  dict
}

#let default-header-style(day) = {
  show: pad.with(y: 8pt)
  set align(center + horizon)
  set text(weight: "bold")
  [Day #{day+1}]
}

#let default-item-style(time, body) = {
  show: block.with(
    fill: white,
    height: 100%,
    width: 100%,
    stroke: (
      left: blue + 2pt,
      rest: blue.lighten(30%) + 0.4pt
    ),
    inset: (rest: 0.4pt, left: 2pt),
    clip: true
  )
  show: pad.with(2pt)
  set par(leading: 4pt)
  if time != none {
    terms(
      terms.item(time.display("[hour]:[minute]"), body)
    )
  } else {
    body
  }
}

#let default-time-style(time) = {
  show: pad.with(x: 2pt)
  move(dy: -4pt, time.display("[hour]:[minute]"))
}

#let get-month-days(month, year) = {
  if month in (1,3,5,7,8,10,12) {
    return 31
  } else if month in (4,6,9,11) {
    return 30
  } else {
    if (calc.fract(year / 4) == 0.0) and (calc.fract(year / 400) != 0.0) {
      return 29
    } else {
      return 28
    }
  }
}

#let default-month-day(day, events) = {
  set align(left + top)
  show: block.with(inset: 2pt, clip: true)
  stack(
    dir: ttb,
    spacing: 4pt,
    day.display("[day]"),
    ..events.map(((t, content)) => {
      stack(
        dir: ltr,
        spacing: 2pt,
        t.display("[hour]:[minute]"),
        content
      )
    })
  )
}

#let default-month-day-head(name) = {
  name
}

#let default-month-head(content) = {
  content
}

#let default-month-view(
  events,
  date-range,
  month-head: none,
  sunday-first: false,
  style-day-body: default-month-day,
  style-day-head: default-month-day-head,
  style-month-head: default-month-head,
  ..args
) = {
  let (date-from, date-to) = date-range
  let dates = range(date-from.day(), date-to.day() + 1).map(it => datetime(
    year: date-from.year(),
    month: date-from.month(),
    day: it
  ))
  let date-weekday = dates.map(it => it.weekday() + int(sunday-first)).map(i => if i > 7 { i - 7 } else { i })
  // [#date-weekday]
  let nweek = dates.map(it => it.weekday()).filter(it => it == 1).len()
  if date-from.weekday() > 1 {
    nweek = nweek + 1
  }
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
    if (key not in events-map.keys()) {
      events-map.insert(key, ())
    }
    events-map.at(key).push(e)
  }
  let header = week-day-map.at(1).map(((d, w)) => style-day-head(d.display("[weekday repr:short]")))
  let title = if type(month-head) == content or type(month-head) == str { month-head } else { date-from.display("[month repr:long]") }
  let body = grid(
    columns: (1fr,) * 7,
    rows: (2em,) * 2 + (4em,) * nweek,
    stroke: 1pt,
    align: center + horizon,
    ..args,
    grid.cell(colspan: 7, style-month-head(title)),
    ..header,
    ..week-day-map.map(week => {
      (
        range(1, week.first().at(1)).map(it => []),
        week.map(((day, w)) => {
          let day-str = day.display("[year]-[month]-[day]")
          if day-str in events-map.keys() {
            style-day-body(day, events-map.at(day-str))
          } else {
            style-day-body(day, ())
          }
        })
      ).join()
    }).flatten()
  )
  body
}

#let default-day-summary(day, shape) = {
  if type(shape) == array and type(shape.at(0)) == function {
    let (pen, args) = shape
    show: pen.with(..args)
    day.display("[day padding:none]")
  } else {
    day.display("[day padding:none]")
  }
}
