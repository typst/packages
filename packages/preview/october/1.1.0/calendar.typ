#let calendar(year: "", sunday_as_start: false, body) = {
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

    #align(left)[
      #heading(level: 1)[
        #text(size: 27pt)[
          #h(0.4em)
          #month_date.display("[month repr:long]") #year
        ]
      ]
    ]

    #let start_of_week = if sunday_as_start { "sunday" } else { "monday" }
    #let first_day = int(monthly_days
      .first()
      .display("[weekday repr:" + start_of_week + "]"))

    #let week_header = (
      [Monday],
      [Tuesday],
      [Wednesday],
      [Thursday],
      [Friday],
      [Saturday],
      [Sunday],
    )
    #if sunday_as_start {
      week_header.insert(0, week_header.pop())
    }

    #let empty_cell = none

    #let monthly_days = (
      range(1, first_day).map(empty_day => empty_cell) + monthly_days
    )

    #show table.cell.where(y: 0): strong
    #pad(
      y: 5%,
      table(
        columns: (1fr,) * 7,
        rows: (0.4fr,) + 5 * (1fr,),
        inset: 0.8em,
        table.header(..week_header),
        ..monthly_days.map(day => {
          if type(day) == type(empty_cell) { return }
          [#day.display(
            "[day padding:none]",
          )]
        }),
        stroke: (x, y) => {
          if y == 0 { return none }
          let cell_index = (y - 1) * 7 + x
          if (
            type(monthly_days.at(cell_index, default: empty_cell))
              == type(empty_cell)
          ) {
            return none
          }
          (thickness: 1.5pt)
        },
      ),
    )

    #pagebreak(weak: true)
  ]
}
