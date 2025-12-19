#import "types.typ": *

//
// UTILITY FUNCTIONS
//

/// Format a date for display in the syllabus.
#let format_date(date) = {
  let (_, date) = e.types.cast(date, datetime)
  date.display("[weekday], [month repr:short]. [day]")
}

/// Format a date's time for display in the syllabus.
#let format_hours(date) = {
  let (_, date) = e.types.cast(date, datetime)
  date.display("[hour repr:12 padding:none]:[minute][period case:lower]")
}

/// Convert a `date` to a `datetime` by adding 0 to each field.
/// This function is also okay to call on `datetime`s and won't change the value
/// of an existing datetime.
///
/// - date (date): The date to convert to a datetime.
/// -> datetime
#let date_to_datetime(date) = {
  datetime(
    year: date.year() + 0,
    month: date.month() + 0,
    day: date.day() + 0,
    hour: date.hour() + 0,
    minute: date.minute() + 0,
    second: date.second() + 0,
  )
}

/// Determine if a date is in a range, before a range, or after a range.
///
/// -> "before" | "during" | "after"
#let date_in_range(
  /// Datetime in question
  /// -> datetime
  date,
  /// Start of the range
  /// -> datetime
  start,
  /// End of the range
  /// -> datetime
  end,
) = {
  let date = date_to_datetime(date)
  let start = date_to_datetime(start)
  // If `end` has no hours, we want to add a day to it so that being in range (2025-9-30 to 2025-9-30)
  // is actually possible.
  let end = if end.hour() == none {
    date_to_datetime(end) + duration(days: 1, seconds: -1)
  } else {
    date_to_datetime(end)
  }

  if date < start {
    "before"
  } else if date > end {
    "after"
  } else {
    "during"
  }
}

/// Format a range of weeks into a human-readable string. For example `October 3-9`. If a month
/// boundary is crossed, the month is included in the end date. For example `September 26-October 3`.
///
/// -> content
#let format_week_range(start: datetime.today(), end: datetime.today()) = {
  let start_formatted = (
    start.display("[month repr:long]") + [~] + start.display("[day padding:none]")
  )
  let multi_month = start.month() != end.month()
  let end_formatted = if multi_month {
    end.display("[month repr:long]") + [~] + end.display("[day padding:none]")
  } else {
    end.display("[day padding:none]")
  }
  start_formatted + [--] + end_formatted
}

/// Format an event as a string. If the event includes a duration, it will be formatted with a start and end.
#let format_event_date(
  /// The event to format. This should be an `event` type.
  /// -> event
  ev,
) = {
  let (success, ev) = e.types.cast(ev, event)
  assert(success, message: if not success { ev } else { "" })
  let start = ev.date
  let has_hours = start.hour() != none

  // At this point we have a date. If it has a duration, specify a start and end.
  if ev.duration != none {
    let end = ev.date + ev.duration
    let multi_day_event = start.day() != end.day()


    if multi_day_event {
      if has_hours {
        (
          format_date(start)
            + " at "
            + format_hours(start)
            + " to "
            + format_date(end)
            + " at "
            + format_hours(end)
        )
      } else {
        format_date(start) + " to " + format_date(end)
      }
    } else {
      if has_hours {
        format_date(start) + " from " + format_hours(start) + " to " + format_hours(end)
      } else {
        format_date(start)
      }
    }
  } else {
    // We have no duration
    if has_hours {
      format_date(start) + " at " + format_hours(start)
    } else {
      format_date(start)
    }
  }

  //   if multi_day_event == false and has_hours {
  //     format_date(start) + " from " + format_hours(start) + " to " + format_hours(end)
  //   } else if multi_day_event {
  //     if has_hours {
  //       (
  //         format_date(start)
  //           + " at "
  //           + format_hours(start)
  //           + " to "
  //           + format_date(end)
  //           + " at "
  //           + format_hours(end)
  //       )
  //     } else {
  //       format_date(start) + " to " + format_date(end)
  //     }
  //   }
  // } else {
  //   if has_hours {
  //     format_date(start) + " at " + format_hours(start)
  //   } else {
  //     format_date(start)
  //   }
}
