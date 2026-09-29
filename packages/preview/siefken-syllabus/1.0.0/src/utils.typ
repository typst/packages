#import "types.typ": *

//
// UTILITY FUNCTIONS
//

/// Format a date for display in the syllabus.
#let format_date(date) = {
  let (_, date) = e.types.cast(date, datetime)
  date.display("[weekday], [month repr:short]. [day padding:none]")
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

/// Compute the last instant included in a range that ends at `end`.
///
/// If `end` has no hours, we want to add a day to it so that being in range (2025-9-30 to 2025-9-30)
/// is actually possible.
///
/// -> datetime
#let inclusive_end(
  /// End of the range
  /// -> datetime
  end,
) = {
  if end.hour() == none {
    date_to_datetime(end) + duration(days: 1, seconds: -1)
  } else {
    date_to_datetime(end)
  }
}

/// Compute the first and last instants covered by an event, taking its optional `duration`
/// into account. The returned end is inclusive, so an event without hours ends at 23:59:59
/// on its last day.
///
/// A `duration` means different things depending on whether the event has a time of day:
/// - An event *without* hours is a whole-day event, and its duration counts the day it starts
///   on. A one-day holiday on Sep. 3 covers Sep. 3 only; a five-day break starting Oct. 26
///   covers Oct. 26--30.
/// - An event *with* hours has its duration measured as elapsed time. An event starting at
///   5:10pm with a two-hour duration ends at 7:10pm the same day.
///
/// -> array
#let event_start_and_end(
  /// The event in question. This should be an `event` type (or a dictionary castable to one).
  /// -> event
  ev,
) = {
  let start = ev.date
  let dur = ev.at("duration", default: none)
  let end = if dur == none {
    start
  } else if start.hour() == none {
    // A whole-day event lasting `n` days ends `n - 1` days after it starts. Durations
    // shorter than a day still cover the day the event starts on.
    start + duration(days: calc.max(calc.ceil(dur.days()), 1) - 1)
  } else {
    start + dur
  }
  (date_to_datetime(start), inclusive_end(end))
}

/// Determine if an event overlaps a range at any point. Unlike `date_in_range`, this takes the
/// event's `duration` into account, so an event spanning a week boundary overlaps *both* weeks.
///
/// -> bool
#let event_overlaps_range(
  /// The event in question. This should be an `event` type (or a dictionary castable to one).
  /// -> event
  ev,
  /// Start of the range
  /// -> datetime
  start,
  /// End of the range
  /// -> datetime
  end,
) = {
  let (event_start, event_end) = event_start_and_end(ev)
  event_start <= inclusive_end(end) and event_end >= date_to_datetime(start)
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
  let end = inclusive_end(end)

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

/// The distance from the top of a line of text to the baseline its glyphs are drawn on.
///
/// Text set at a larger size has a taller ascender, so its first baseline sits lower. Comparing
/// this offset for two text styles says how far one must be shifted for their first baselines to
/// line up. Must be called from a context where `measure` is available.
///
/// -> length
#let first_baseline_offset(
  /// A function applying the text style in question to its argument, for example
  /// `body => text(size: 1.2em, body)`. Pass `body => body` for the surrounding style.
  /// -> function
  style,
) = {
  let probe = style([X])
  // With `top-edge: "baseline"` a line of text has no height above its baseline, so whatever
  // the measurement loses is exactly the height that sat above the baseline.
  let ascent = measure(probe).height - measure({
    set text(top-edge: "baseline")
    probe
  }).height

  // `text.baseline` draws glyphs off their baseline, and `measure` cannot see it, so read the
  // value back out of the style itself: a `context` placed inside the style can report it, and
  // encoding it as a block height carries it back out (heights cannot be negative, hence the
  // offset that is subtracted again).
  let drawn_offset = measure(style(context block(height: 1in + text.baseline))).height - 1in

  ascent + drawn_offset
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
    let (_, end) = event_start_and_end(ev)
    // Compare complete dates. Comparing the day of the month alone would treat, say,
    // Sep. 15--Oct. 15 as a single-day event and silently drop the end date.
    let multi_day_event = (
      (start.year(), start.month(), start.day()) != (end.year(), end.month(), end.day())
    )


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
