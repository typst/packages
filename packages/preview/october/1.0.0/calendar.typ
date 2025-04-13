#let calendar(year: "", body) = {

  set document(title: str(year) + " calendar")

  for month in range(1, 13) [

    #let month_date = datetime(
      year: year,
      month: month,
      day: 1,
    )

    #let monthly_days = ()

    #for day in range(0, 31) [
      #let month_accumulator = (month_date + duration(days: day))
      #if month_accumulator.month() != month {
        break
      }
      #monthly_days.push(month_accumulator)
    ]

    #align(center)[
      #heading(level: 1)[
        #text(size: 27pt)[#month_date.display("[month repr:long] [year]")
        ]
      ]
    ]

    #let first_monday = {
      int(monthly_days.first().display("[weekday repr:monday]"))
    }

    #show table.cell.where(y: 0): strong
    #pad(
      y: 20pt,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        rows: (0.4fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 12pt,
        table.header(
          [Monday],
          [Tuesday],
          [Wednesday],
          [Thursday],
          [Friday],
          [Saturday],
          [Sunday],
        ),
        ..range(1, first_monday).map(empty_day => []),
        ..monthly_days.map(day => [#day.display("[day padding:none]")])
      ),
    )

    #pagebreak(weak: true)
  ]
}
