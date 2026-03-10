#import "@preview/cetz:0.4.1"
#import "util.typ": content-if-fits, gantt-range
#import "datetime.typ": month-length

/// Creates all the information needed for a custom header.
///
/// If you just want to change the formatting of the year, month, week, or day
/// heading, see @create-custom-year-header, @create-custom-month-header,
/// @create-custom-week-header, @create-custom-day-header.
/// -> function
#let create-header(
  /// A function of signature `(datetime) => bool` that determines whether or
  /// not the given datetime falls at the start of this period. So, for example,
  /// the month header includes the identifier:
  ///
  /// ```typc
  /// date => date.day() == 1
  /// ```
  /// -> function
  identifier,
  /// A function to give the duration that a header will span from the given date.
  /// The function is of signature `(gantt: dictionary, date: datetime, first: bool`
  /// where `gantt` is a copy of the gantt chart as a whole; `date` is the datetime
  /// that starts this header; and `first` is whether or not this is the first
  /// header chronologically.
  ///
  /// The month header has the following `duration-func`:
  ///
  /// ```typc
  /// (gantt, date, first) => {
  ///   let length = calc.min(month-length(date), (end - date).days())
  ///   if first {
  ///     length += 1 - start.day()
  ///   }
  ///   length
  /// }
  /// ```
  /// -> function
  duration-func,
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
  gridline-style,
  /// A name to identify this header internally within CeTZ. The month header
  /// uses `"month"`
  /// -> string
  name,
) = {
  import cetz.draw: *
  (gantt, anchor-obj) => {
    let (start, end, end-m1) = gantt-range(gantt)
    let date-range = (end - start)
    let height = measure([H]).height + 10pt

    rect(
      anchor-obj + ".north-west",
      (rel: (0, height), to: anchor-obj + ".north-east"),
      name: name + "-header",
      ..gantt.style.gridlines.table,
    )
    let first = true
    let acc = 0.0
    for rel-day in range(int((end - start).days())) {
      let date = start + duration(days: rel-day)
      if identifier(date) or first {
        let dur = duration-func(gantt, date, first)

        let x = (acc / date-range.days()) * 100%
        let x1 = ((acc + dur) / date-range.days()) * 100%

        line(
          (name + "-header.north-west", x, name + "-header.north-east"),
          (name + "-header.south-west", x, name + "-header.south-east"),
          ..gantt.style.gridlines.table,
        )
        content-if-fits(
          (name + "-header.south-west", x, name + "-header.south-east"),
          (name + "-header.north-west", x1, name + "-header.north-east"),
          get-content(date),
        )
        line(
          ("bars.north-west", x, "bars.north-east"),
          ("bars.south-west", x, "bars.south-east"),
          ..gridline-style,
        )
        acc += dur
      }
      first = false
    }
  }
}

/// Lets you create a custom month header.
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
) = {
  (gantt, anchor-obj) => {
    let (start, end, end-m1) = gantt-range(gantt)
    create-header(
      date => date.day() == 1,
      (gantt, date, first) => {
        let length = calc.min(month-length(date), (end - date).days())
        if first {
          length += 1 - start.day()
        }
        length
      },
      get-content,
      gantt.style.gridlines.months,
      name,
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

/// Lets you create a custom week header.
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
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => date.weekday() == 1,
      (gantt, date, first) => {
        let (start, end, end-m1) = gantt-range(gantt)
        let end-date = date + duration(days: 7)
        if first {
          end-date -= duration(days: date.weekday() - 1)
        }
        (calc.min(end-m1, end-date) - date).days()
      },
      get-content,
      gantt.style.gridlines.weeks,
      name,
    )(gantt, anchor-obj)
  }
}

/// Draw a header showing the first day of each week
#let _draw-week-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-custom-week-header(
    date => pad(2pt, text(0.8em, align(left + horizon, str(date.day())))),
    "week",
  )(gantt, anchor-obj)
}

/// Lets you create a custom year header.
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
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => date.day() == 1 and date.month() == 1,
      (gantt, date, first) => {
        let (start, end, end-m1) = gantt-range(gantt)
        let end-date = datetime(year: date.year() + 1, month: 1, day: 1)
        (calc.min(end-m1, end-date) - date).days()
      },
      get-content,
      gantt.style.gridlines.years,
      name,
    )(gantt, anchor-obj)
  }
}

/// Draws a header showing the years
#let _draw-year-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-custom-year-header(
    date => align(center + horizon, strong(str(date.year()))),
    "year",
  )(gantt, anchor-obj)
}

/// Lets you create a custom day header.
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
) = {
  (gantt, anchor-obj) => {
    create-header(
      date => true,
      (gantt, date, first) => 1,
      get-content,
      gantt.style.gridlines.days,
      name,
    )(gantt, anchor-obj)
  }
}

/// Draws a header showing the days
#let _draw-day-header(gantt, anchor-obj) = {
  import cetz.draw: *

  create-custom-day-header(
    date => text(0.5em, align(center + horizon, str(date.day()))),
    "day",
  )(gantt, anchor-obj)
}

/// Draws all the headers in the gantt chart
#let draw-headers(gantt) = {
  let anchor-obj = "bars"
  for header in gantt.headers.rev() {
    if header == "month" {
      _draw-month-header(gantt, anchor-obj)
      anchor-obj = "month-header"
    } else if header == "week" {
      _draw-week-header(gantt, anchor-obj)
      anchor-obj = "week-header"
    } else if header == "year" {
      _draw-year-header(gantt, anchor-obj)
      anchor-obj = "year-header"
    } else if header == "day" {
      _draw-day-header(gantt, anchor-obj)
      anchor-obj = "day-header"
    } else if type(header) == dictionary {
      (header.function)(gantt, anchor-obj)
      anchor-obj = header.name + "-header"
    } else {
      panic("Unknown header", header)
    }
  }
}
