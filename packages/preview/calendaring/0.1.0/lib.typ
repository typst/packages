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

#let _default-cell(n) = text(8pt, weight: "bold")[#n]

#let month-grid(
  year,
  month,
  cell-height: 3.3cm,
  cell-width: 3.5cm,
  week-start: "mon",
  rotated: false,
  header-fill: luma(230),
  stroke: 0.5pt,
  inset: 3pt,
  cell-content: _default-cell,
) = {
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

  let names = if week-start == "sun" {
    _weekday-names-sun
  } else {
    _weekday-names-mon
  }

  let header-cells = names.map(d => table.cell(fill: header-fill)[
    #align(center, text(8pt, weight: "bold")[#d])
  ])

  let blank = []
  let body-cells = (
    ..((blank,) * leading),
    ..range(1, n-days + 1).map(cell-content),
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
