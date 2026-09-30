#let _weekday-names-mon = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
#let _weekday-names-sun = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

// Gregorian leap year: divisible by 4, except century years not divisible by 400.
#let is-leap-year(year) = {
  (calc.rem(year, 4) == 0 and calc.rem(year, 100) != 0) or calc.rem(year, 400) == 0
}

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

// ISO 8601 week number: the week of a date is the week of its Thursday;
// week 1 is the week containing the first Thursday of the year.
#let _iso-week(date) = {
  let days-to-thursday = 4 - date.weekday()
  let thursday = date + duration(days: days-to-thursday)
  let year-start = datetime(year: thursday.year(), month: 1, day: 1)
  let diff = (thursday - year-start) / duration(days: 1)
  calc.floor(diff / 7) + 1
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
  week-numbers: false,
  week-number-width: 0.8cm,
) = {
  assert(type(year) == int,
    message: "year must be an integer")
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

  let default-names = if week-start == "sun" {
    _weekday-names-sun
  } else {
    _weekday-names-mon
  }
  let names = if weekday-names == none { default-names } else { weekday-names }
  assert(names.len() == 7,
    message: "weekday-names must have exactly 7 entries")

  let day-cell-styled = (d => table.cell(fill: header-fill)[
    #align(center, text(8pt, weight: "bold")[#d])
  ])
  let header-cells = names.map(day-cell-styled)
  let header-row = if week-numbers {
    (table.cell(fill: header-fill)[
      #align(center, text(7pt, weight: "bold", fill: luma(110))[Wk])
    ],) + header-cells
  } else {
    header-cells
  }

  let render = if cell-content == none {
    (date) => _default-render(date, today, events, today-fill)
  } else {
    cell-content
  }

  // Build row-by-row so a week-number cell can be prepended per row.
  let mon-col-offset = if week-start == "mon" { 0 } else { 1 }
  let body-cells = ()
  for row in range(0, rows-needed) {
    if week-numbers {
      let row-monday = first + duration(days: row * 7 + mon-col-offset - leading)
      body-cells.push(table.cell(align: center + horizon)[
        #text(7pt, fill: luma(110))[#_iso-week(row-monday)]
      ])
    }
    for col in range(0, 7) {
      let pos = row * 7 + col
      if pos < leading or pos >= leading + n-days {
        body-cells.push([])
      } else {
        let d = pos - leading + 1
        body-cells.push(render(datetime(year: year, month: month, day: d)))
      }
    }
  }

  let columns = if week-numbers {
    (week-number-width,) + (cell-width,) * 7
  } else {
    (cell-width,) * 7
  }

  let tbl = table(
    columns: columns,
    rows: (auto,) + (cell-height,) * rows-needed,
    align: top + left,
    inset: inset,
    stroke: stroke,
    ..header-row,
    ..body-cells,
  )

  if rotated {
    rotate(90deg, reflow: true, tbl)
  } else {
    tbl
  }
}

#let year-grid(
  year,
  columns: 3,
  cell-height: 0.55cm,
  inset: 1pt,
  month-label-size: 9pt,
) = {
  assert(type(year) == int, message: "year must be an integer")
  assert(type(columns) == int and 1 <= columns and columns <= 12,
    message: "columns must be an integer between 1 and 12")

  let month-name(m) = datetime(year: year, month: m, day: 1)
    .display("[month repr:long]")
  grid(
    columns: (1fr,) * columns,
    column-gutter: 0.4cm,
    row-gutter: 0.5cm,
    ..range(1, 13).map(m => [
      #align(center, text(month-label-size, weight: "bold")[#month-name(m)])
      #v(2pt)
      #month-grid(
        year, m,
        cell-width: 1fr,
        cell-height: cell-height,
        inset: inset,
      )
    ])
  )
}
