#import "@preview/datify:1.0.1": custom-date-format

/// Constructs a `datetime` from separate components.
///
/// Shorthand for the verbose `datetime(year: ..., month: ..., day: ...)` constructor.
/// Pass to any `time:` or `date:` parameter in this library.
///
/// === Example
/// ```typst
/// #date(15, 3, 2025)                  // 15 March 2025 at midnight
/// #date(15, 3, 2025, time: (13, 30))  // 15 March 2025 at 13:30
/// ```
///
/// - day (int): Day of the month (1-31).
/// - month (int): Month (1-12).
/// - year (int): Full year, e.g. `2026`.
/// - time (array): Optional `(hour)`, `(hour, minute)`, or `(hour, minute, second)`.
/// -> datetime
#let date(day, month, year, time: none) = {
  let (h, m, s) = if time != none {
    let time = (time,).flatten()
    if time.len() == 3 {
      time
    } else if time.len() == 2 {
      (time.at(0), time.at(1), 0)
    } else if time.len() == 1 {
      (time.at(0), 0, 0)
    }
  } else {
    (0, 0, 0)
  }

  datetime(
    year: year,
    month: month,
    day: day,
    hour: h,
    minute: m,
    second: s,
  )
}
