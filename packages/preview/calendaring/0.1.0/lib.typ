#let _weekday-names-mon = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
#let _weekday-names-sun = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

#let _days-in-month(year, month) = {
  let next = if month == 12 {
    datetime(year: year + 1, month: 1, day: 1)
  } else {
    datetime(year: year, month: month + 1, day: 1)
  }
  (next - duration(days: 1)).day()
}

#let _dates-equal(a, b) = {
  a.year() == b.year() and a.month() == b.month() and a.day() == b.day()
}

#let _events-for(date, events) = {
  events
    .filter(((d, _)) => _dates-equal(d, date))
    .map(((_, content)) => content)
}

#let _default-render(date, today, events, today-fill) = {
  let day-events = _events-for(date, events)
  let is-today = today != none and _dates-equal(date, today)

  let body = {
    text(8pt, weight: "bold")[#date.day()]
    if day-events.len() > 0 {
      v(1pt)
      stack(spacing: 1pt, ..day-events.map(e => text(6.5pt)[#e]))
    }
  }

  if is-today {
    table.cell(fill: today-fill)[#body]
  } else {
    body
  }
}

#let month-grid(
  year,
  month,
  cell-height: 3.3cm,
  cell-width: 3.5cm,
  week-start: "mon",
  rotated: false,
  header-fill: luma(230),
  today-fill: luma(220),
  stroke: 0.5pt,
  inset: 3pt,
  weekday-names: none,
  cell-content: none,
  today: none,
  events: (),
) = {
  assert(type(month) == int and 1 <= month and month <= 12,
    message: "month must be an integer between 1 and 12")
  assert(week-start == "mon" or week-start == "sun",
    message: "week-start must be \"mon\" or \"sun\"")

  let first = datetime(year: year, month: month, day: 1)
  let first-weekday = first.weekday()

  let leading = if week-start == "sun" {
    calc.rem(first-weekday, 7)
  } else {
    first-weekday - 1
  }

  let n-days = _days-in-month(year, month)
  let total = leading + n-days
  let rows-needed = calc.ceil(total / 7)
  let trailing = rows-needed * 7 - total

  let default-names = if week-start == "sun" {
    _weekday-names-sun
  } else {
    _weekday-names-mon
  }
  let names = if weekday-names == none { default-names } else { weekday-names }
  assert(names.len() == 7,
    message: "weekday-names must have exactly 7 entries")

  let header-cells = names.map(d => table.cell(fill: header-fill)[
    #align(center, text(8pt, weight: "bold")[#d])
  ])

  let render = if cell-content == none {
    (date) => _default-render(date, today, events, today-fill)
  } else {
    cell-content
  }

  let day-cells = range(1, n-days + 1).map(d => {
    render(datetime(year: year, month: month, day: d))
  })

  let blank = []
  let body-cells = (
    ..((blank,) * leading),
    ..day-cells,
    ..((blank,) * trailing),
  )

  let tbl = table(
    columns: (cell-width,) * 7,
    rows: (auto,) + (cell-height,) * rows-needed,
    align: top + left,
    inset: inset,
    stroke: stroke,
    ..header-cells,
    ..body-cells,
  )

  if rotated {
    rotate(90deg, reflow: true, tbl)
  } else {
    tbl
  }
}

#let year-grid(year, columns: 3) = {
  let month-name(m) = datetime(year: year, month: m, day: 1)
    .display("[month repr:long]")
  grid(
    columns: (1fr,) * columns,
    column-gutter: 0.4cm,
    row-gutter: 0.5cm,
    ..range(1, 13).map(m => [
      #align(center, text(9pt, weight: "bold")[#month-name(m)])
      #v(2pt)
      #month-grid(year, m, cell-width: 1fr, cell-height: 0.55cm, inset: 1pt)
    ])
  )
}
