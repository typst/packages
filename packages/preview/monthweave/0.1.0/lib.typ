// MonthWeave: deterministic civil calendar data and printable layout helpers.

#let month-names = (
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
)

#let weekday-names = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

/// Return whether a Gregorian year has 366 days.
#let is-leap-year(year) = {
  assert(year >= 1, message: "year must be at least 1")
  calc.rem(year, 400) == 0 or (calc.rem(year, 4) == 0 and calc.rem(year, 100) != 0)
}

/// Return the number of days in a Gregorian month.
///
/// `year` must be positive and `month` must be between 1 and 12.
#let days-in-month(year, month) = {
  assert(year >= 1, message: "year must be at least 1")
  assert(month >= 1 and month <= 12, message: "month must be between 1 and 12")
  if month == 2 {
    if is-leap-year(year) { 29 } else { 28 }
  } else if month == 4 or month == 6 or month == 9 or month == 11 {
    30
  } else {
    31
  }
}

#let days-before-year(year) = {
  let prior = year - 1
  365 * prior + calc.floor(prior / 4) - calc.floor(prior / 100) + calc.floor(prior / 400)
}

#let ordinal-day(year, month, day) = {
  assert(day >= 1 and day <= days-in-month(year, month), message: "day is outside the selected month")
  let ordinal = day
  for current in range(1, month) {
    ordinal += days-in-month(year, current)
  }
  ordinal
}

/// Return a Sunday-zero weekday index for a valid Gregorian date.
///
/// Sunday is 0, Monday is 1, and Saturday is 6.
#let weekday-index(year, month, day) = {
  calc.rem(days-before-year(year) + ordinal-day(year, month, day), 7)
}

#let shift-date(year, month, day, offset) = {
  let y = year
  let m = month
  let d = day + offset
  while d < 1 {
    if m == 1 {
      y -= 1
      m = 12
    } else {
      m -= 1
    }
    d += days-in-month(y, m)
  }
  while d > days-in-month(y, m) {
    d -= days-in-month(y, m)
    if m == 12 {
      y += 1
      m = 1
    } else {
      m += 1
    }
  }
  (year: y, month: m, day: d)
}

#let iso-week(year, month, day) = {
  let iso-weekday = if weekday-index(year, month, day) == 0 { 7 } else { weekday-index(year, month, day) }
  let thursday = shift-date(year, month, day, 4 - iso-weekday)
  let iso-year = thursday.year
  let jan-fourth-weekday = if weekday-index(iso-year, 1, 4) == 0 { 7 } else { weekday-index(iso-year, 1, 4) }
  let first-monday = days-before-year(iso-year) + ordinal-day(iso-year, 1, 4) - jan-fourth-weekday
  let absolute-day = days-before-year(year) + ordinal-day(year, month, day) - 1
  (year: iso-year, week: calc.floor((absolute-day - first-monday) / 7) + 1)
}

/// Return a customizable, presentation-neutral theme for rendered tables.
#let calendar-theme(
  title-size: 16pt,
  heading-fill: rgb("E8EEF5"),
  day-fill: white,
  weekend-fill: rgb("F6F8FB"),
  outside-fill: rgb("F0F2F5"),
  heading-color: rgb("15263A"),
  text-color: rgb("182230"),
  muted-color: rgb("697586"),
  event-color: rgb("A12B35"),
  border: 0.6pt + rgb("CBD5E1"),
  cell-padding: 5pt,
) = (
  title-size: title-size,
  heading-fill: heading-fill,
  day-fill: day-fill,
  weekend-fill: weekend-fill,
  outside-fill: outside-fill,
  heading-color: heading-color,
  text-color: text-color,
  muted-color: muted-color,
  event-color: event-color,
  border: border,
  cell-padding: cell-padding,
)

#let default-theme = calendar-theme()

#let validate-labels(labels, expected, what) = {
  assert(labels.len() == expected, message: what + " must contain " + str(expected) + " labels")
}

/// Build a deterministic month-grid data model without rendering it.
///
/// `week-start` is Sunday-zero (0–6). `rows` can be `auto`, `5`, or `6`.
/// `events` is a tuple of records with `year`, `month`, `day`, `label`, and
/// optional `marker` fields. Weekday and month labels can be localized by the
/// caller. Outside-month dates stay in the model even when their numbers are
/// hidden from the rendered grid.
#let calendar-grid(
  year,
  month,
  week-start: 0,
  rows: auto,
  show-outside: true,
  blank: false,
  week-numbers: false,
  events: (),
  weekdays: weekday-names,
  months: month-names,
) = {
  assert(year >= 1, message: "year must be at least 1")
  assert(month >= 1 and month <= 12, message: "month must be between 1 and 12")
  assert(week-start >= 0 and week-start <= 6, message: "week-start must be between 0 and 6")
  validate-labels(weekdays, 7, "weekdays")
  validate-labels(months, 12, "months")
  let count = days-in-month(year, month)
  let leading = calc.rem(weekday-index(year, month, 1) - week-start + 7, 7)
  let required-rows = calc.max(5, calc.floor((leading + count + 6) / 7))
  let row-count = if rows == auto { required-rows } else { rows }
  assert(row-count == 5 or row-count == 6, message: "rows must be auto, 5, or 6")
  assert(required-rows <= row-count, message: "the selected month requires more rows")
  let ordered-weekdays = range(0, 7).map(offset => weekdays.at(calc.rem(week-start + offset, 7)))
  let weeks = ()
  for row in range(0, row-count) {
    let cells = ()
    let week-iso = none
    for column in range(0, 7) {
      let slot = row * 7 + column - leading + 1
      let in-month = slot >= 1 and slot <= count
      let actual-date = if in-month {
        (year: year, month: month, day: slot)
      } else {
        shift-date(year, month, 1, slot - 1)
      }
      let visible-date = if in-month or show-outside { actual-date } else { none }
      let labels = ()
      for event in events {
        if event.year == actual-date.year and event.month == actual-date.month and event.day == actual-date.day {
          labels.push(event)
        }
      }
      let iso = iso-week(actual-date.year, actual-date.month, actual-date.day)
      // The row's Thursday identifies the ISO week even for Sunday-first layouts.
      if column == 3 { week-iso = iso }
      cells.push((
        date: visible-date,
        day: if in-month or show-outside { actual-date.day } else { none },
        in-month: in-month,
        weekday: calc.rem(week-start + column, 7),
        weekend: calc.rem(week-start + column, 7) == 0 or calc.rem(week-start + column, 7) == 6,
        events: labels,
        iso-week: iso.week,
        iso-year: iso.year,
        blank: blank,
      ))
    }
    weeks.push((iso-week: week-iso.week, iso-year: week-iso.year, cells: cells))
  }
  (
    year: year,
    month: month,
    title: months.at(month - 1) + " " + str(year),
    week-start: week-start,
    weekday-labels: ordered-weekdays,
    rows: row-count,
    weeks: weeks,
    week-numbers: week-numbers,
    blank: blank,
  )
}

#let render-cell(cell, theme) = {
  let fill = if not cell.in-month and cell.date != none {
    theme.outside-fill
  } else if cell.weekend {
    theme.weekend-fill
  } else {
    theme.day-fill
  }
  table.cell(fill: fill, inset: theme.cell-padding, align: left + top)[
    #if cell.day != none and not cell.blank [
      #text(fill: if cell.in-month { theme.text-color } else { theme.muted-color }, weight: if cell.in-month { "medium" } else { "regular"})[#cell.day]
    ]
    #if cell.events.len() > 0 [
      #linebreak()
      #for event in cell.events [
        #text(size: 8pt, fill: theme.event-color)[#(if "marker" in event { event.marker } else { "•" }) #event.label]
        #linebreak()
      ]
    ]
  ]
}

/// Render a month as a seven-column calendar table.
///
/// Use `week-start: 1` for Monday-first and `week-start: 0` for Sunday-first.
/// `rows: auto` uses five or six complete rows; fixed rows validate that the
/// month fits. The theme is returned by `calendar-theme` and can be customized.
#let month-calendar(
  year,
  month,
  week-start: 0,
  rows: auto,
  show-outside: true,
  blank: false,
  week-numbers: false,
  events: (),
  weekdays: weekday-names,
  months: month-names,
  theme: default-theme,
) = {
  let model = calendar-grid(
    year,
    month,
    week-start: week-start,
    rows: rows,
    show-outside: show-outside,
    blank: blank,
    week-numbers: week-numbers,
    events: events,
    weekdays: weekdays,
    months: months,
  )
  align(center)[#text(size: theme.title-size, weight: "bold", fill: theme.heading-color)[#model.title]]
  let columns = if week-numbers { 8 } else { 7 }
  let table-items = ()
  if week-numbers {
    table-items.push(table.cell(fill: theme.heading-fill, inset: theme.cell-padding, align: center)[Wk])
  }
  for label in model.weekday-labels {
    table-items.push(table.cell(fill: theme.heading-fill, inset: theme.cell-padding, align: center)[#text(weight: "bold", fill: theme.heading-color)[#label]])
  }
  for week in model.weeks {
    if week-numbers {
      table-items.push(table.cell(fill: theme.heading-fill, inset: theme.cell-padding, align: center)[#text(size: 8pt, fill: theme.muted-color)[#week.iso-week]])
    }
    for cell in week.cells {
      table-items.push(render-cell(cell, theme))
    }
  }
  table(columns: columns, stroke: theme.border, gutter: 0pt, inset: 0pt, ..table-items)
}

/// Render a 12-month overview as a compact three-column group.
#let year-calendar(
  year,
  week-start: 0,
  rows: auto,
  week-numbers: false,
  weekdays: weekday-names,
  months: month-names,
  theme: default-theme,
  gutter: 12pt,
) = {
  grid(
    columns: 3,
    gutter: gutter,
    ..range(1, 13).map(month => month-calendar(
      year,
      month,
      week-start: week-start,
      rows: rows,
      show-outside: false,
      week-numbers: week-numbers,
      weekdays: weekdays,
      months: months,
      theme: calendar-theme(
        title-size: 10pt,
        heading-fill: theme.heading-fill,
        weekend-fill: theme.weekend-fill,
        outside-fill: theme.outside-fill,
        heading-color: theme.heading-color,
        text-color: theme.text-color,
        muted-color: theme.muted-color,
        event-color: theme.event-color,
        border: theme.border,
        cell-padding: 2pt,
      ),
    )),
  )
}

/// Render an undated planning grid for a month.
#let blank-calendar(year, month, week-start: 0, rows: auto, theme: default-theme) = {
  month-calendar(year, month, week-start: week-start, rows: rows, show-outside: false, blank: true, theme: theme)
}

/// Set a print page size and render a single month.
///
/// `format` accepts `a4-portrait`, `a4-landscape`, or `us-letter-portrait`.
#let printable-calendar(year, month, format: "a4-portrait", ..options) = {
  let dimensions = if format == "a4-portrait" {
    (210mm, 297mm)
  } else if format == "a4-landscape" {
    (297mm, 210mm)
  } else if format == "us-letter-portrait" {
    (8.5in, 11in)
  } else {
    panic("format must be a4-portrait, a4-landscape, or us-letter-portrait")
  }
  set page(width: dimensions.at(0), height: dimensions.at(1), margin: 14mm)
  month-calendar(year, month, ..options)
}
