#import "@preview/cetz:0.4.2"
#import "util.typ": content-if-fits, date-coord
#import "datetime.typ": month-length

#let _default-gridlines = (
  table: (stroke: black, thickness: 1pt),
  years: (stroke: (paint: luma(66%), thickness: 1pt)),
  months: (stroke: (paint: luma(66%), thickness: 0.7pt)),
  weeks: (stroke: (paint: luma(66%), thickness: 0.2pt)),
  days: (stroke: (paint: luma(66%), thickness: 0.1pt)),
)

/// Creates all the information needed for a custom header for the default drawer.
///
/// If you just want to change the formatting of the year, month, week, or day
/// heading, see @create-custom-year-header, @create-custom-month-header,
/// @create-custom-week-header, @create-custom-day-header.
/// -> function
#let create-header(
  /// A function of signature `(datetime) -> datetime` to determine the next
  /// datetime that this header is for
  ///
  /// The month header has the following implementation:
  ///
  /// ```typc
  /// date => {
  ///   if date.month() == 12 {
  ///     datetime(year: date.year() + 1, month: 1, day: 1)
  ///   } else {
  ///     datetime(year: date.year(), month: date.month() + 1, day: 1)
  ///   }
  /// }
  /// ```
  ///
  /// -> function
  next,
  /// A function of signature `(datetime) => content` for providing the content
  /// to display within the header.
  ///
  /// The month header has the following `get-content`:
  ///
  /// ```typc
  /// date => align(
  ///    center + horizon,
  ///    strong(date.display("[month repr:short]"))
  /// )
  /// ```
  /// -> function
  get-content,
  /// The style to use for the gridlines of this header.
  ///
  /// The month header uses `gantt.style.gridlines.months`
  /// -> style
  gridline-style,
  /// The style to use for the table elements
  /// -> style
  table-style: _default-gridlines.table,
  /// A name to identify this header internally within CeTZ. The month header
  /// uses `"month"`
  /// -> string
  name,
) = {
  import cetz.draw: *
  (gantt, anchor-obj) => {
    let date-range = gantt.end - gantt.start
    // TODO: DO NOT HARDCODE
    let height = measure([H]).height + 10pt

    rect(
      anchor-obj + ".north-west",
      (rel: (0, height), to: anchor-obj + ".north-east"),
      name: name + "-header",
      ..table-style,
    )

    let date = gantt.start
    while date < gantt.end {
      let next-date = calc.min(next(date), gantt.end)

      let header-north = name + "-header.north"
      let header-south = name + "-header.south"

      line(
        date-coord(gantt, header-north, date),
        date-coord(gantt, header-south, date),
        ..table-style,
      )
      content-if-fits(
        date-coord(gantt, header-south, date),
        date-coord(gantt, header-north, next-date),
        get-content(date),
      )
      line(
        date-coord(gantt, "field.north", date),
        date-coord(gantt, "field.south", date),
        ..gridline-style,
      )
      date = next(date)
    }
  }
}

/// Lets you create a custom month header for the default drawer.
///
/// Calls @create-header internally.
/// -> function
#let create-custom-month-header(
  /// See @create-header.get-content.
  /// -> function
  get-content,
  /// See @create-header.name.
  /// -> string
  name,
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.months,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => {
        if date.month() == 12 {
          datetime(year: date.year() + 1, month: 1, day: 1)
        } else {
          datetime(year: date.year(), month: date.month() + 1, day: 1)
        }
      },
      get-content,
      gridlines-style,
      name,
      table-style: table-style,
    )(gantt, anchor-obj)
  }
}

/// Draws a header showing the months
#let _draw-month-header(gantt, anchor-obj) = {
  create-custom-month-header(
    date => align(center + horizon, strong(date.display("[month repr:short]"))),
    "month",
  )(gantt, anchor-obj)
}

/// The default month header
#let default-month-header(
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.months,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = (
  name: "month",
  function: create-custom-month-header(
    date => align(center + horizon, strong(date.display("[month repr:short]"))),
    "month",
    gridlines-style: gridlines-style,
    table-style: table-style,
  ),
)

/// Lets you create a custom week header for the default drawer.
///
/// Calls @create-header internally.
/// -> function
#let create-custom-week-header(
  /// See @create-header.get-content.
  /// -> function
  get-content,
  /// See @create-header.name.
  /// -> string
  name,
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.weeks,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => date + duration(days: 8 - date.weekday()),
      get-content,
      gridlines-style,
      name,
      table-style: table-style,
    )(gantt, anchor-obj)
  }
}

/// The default week header.
#let default-week-header(
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.weeks,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = (
  name: "week",
  function: create-custom-week-header(
    date => pad(2pt, text(0.8em, align(left + horizon, str(date.day())))),
    "week",
    gridlines-style: gridlines-style,
    table-style: table-style,
  ),
)

/// Lets you create a custom year header for the default drawer.
///
/// Calls @create-header internally.
/// -> function
#let create-custom-year-header(
  /// See @create-header.get-content.
  /// -> function
  get-content,
  /// See @create-header.name.
  /// -> string
  name,
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.years,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => datetime(year: date.year() + 1, day: 1, month: 1),
      get-content,
      gridlines-style,
      name,
      table-style: table-style,
    )(gantt, anchor-obj)
  }
}

/// The default year header.
#let default-year-header(
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.years,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = (
  name: "year",
  function: create-custom-year-header(
    date => align(center + horizon, strong(str(date.year()))),
    "year",
    gridlines-style: gridlines-style,
    table-style: table-style,
  ),
)

/// Lets you create a custom day header for the default drawer.
///
/// Calls @create-header internally.
/// -> function
#let create-custom-day-header(
  /// See @create-header.get-content.
  /// -> function
  get-content,
  /// See @create-header.name.
  /// -> string
  name,
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.days,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => date + duration(days: 1),
      get-content,
      gridlines-style,
      name,
      table-style: table-style,
    )(gantt, anchor-obj)
  }
}

/// The default day header for the default drawer.
#let default-day-header(
  /// The style of the gridlines.
  /// -> style
  gridlines-style: _default-gridlines.table,
  /// The style of the table part of the header.
  /// -> style
  table-style: _default-gridlines.table,
) = (
  name: "day",
  function: create-custom-day-header(
    date => text(0.5em, align(center + horizon, str(date.day()))),
    "day",
    gridlines-style: gridlines-style,
    table-style: table-style,
  ),
)

/// The default drawer for the headers
/// -> cetz
#let default-headers-drawer(
  /// The gantt chart.
  /// -> gantt
  gantt,
  /// Which headers to draw.
  /// -> array
  headers: (
    default-month-header(),
    default-week-header(),
  ),
) = {
  let anchor-obj = "field"
  for header in headers.rev() {
    (header.function)(gantt, anchor-obj)
    anchor-obj = header.name + "-header"
  }
}
