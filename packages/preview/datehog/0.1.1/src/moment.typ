// The moment type: an instant in UTC, carried as a plain dictionary.
//
// A moment is a value, not an opaque handle, so it prints under `repr`,
// compares with `==`, and — because every constructor here is a pure function —
// gets memoised by Typst. Building the same moment twice costs one build.
//
// The calendar half of the work is done by Typst's native `datetime` (see
// `civil.typ`). The one thing native datetimes cannot carry is milliseconds —
// they have second resolution — so a moment tracks the day count and the
// intraday milliseconds itself and only reaches for `datetime` at the
// date boundary.

#import "civil.typ": (
  EPOCH, MAX-DAYS, MAX-YEAR, MIN-DAYS, MIN-YEAR, civil-from-days, days-from-civil,
  days-in-month, is-days-in-range, is-valid-date, is-year-in-range, ordinal-from-civil,
  weekday-from-days,
)

#let MS-PER-SECOND = 1000
#let MS-PER-MINUTE = 60000
#let MS-PER-HOUR = 3600000
#let MS-PER-DAY = 86400000

/// Millisecond bounds corresponding to the representable date range.
#let MIN-MS = MIN-DAYS * MS-PER-DAY
#let MAX-MS = (MAX-DAYS + 1) * MS-PER-DAY - 1

/// Is `value` a moment produced by this package?
#let is-moment(value) = type(value) == dictionary and value.at("datehog", default: none) == "moment"

/// Build a moment from milliseconds since the Unix epoch (UTC).
///
/// `ms` may be an int or a float; it is floored to whole milliseconds, so
/// sub-millisecond precision is discarded exactly as `new Date(ms)` does.
/// Returns `none` for non-finite input or an instant outside the representable
/// range, mirroring JavaScript's `Invalid Date` — and, importantly, never
/// panicking: Typst's datetime overflow is a compiler panic, not a catchable
/// error, so the bound is checked here.
#let from-ms(ms) = {
  if ms == none { return none }
  if type(ms) != int and type(ms) != float { return none }
  if type(ms) == float and (ms.is-nan() or ms.is-infinite()) { return none }

  let total = if type(ms) == int { ms } else { int(calc.floor(ms)) }
  if total < MIN-MS or total > MAX-MS { return none }

  let days = calc.div-euclid(total, MS-PER-DAY)
  let rest = total - days * MS-PER-DAY // [0, 86399999]
  let civil = civil-from-days(days)
  if civil == none { return none }
  let (year, month, day) = civil

  (
    datehog: "moment",
    ms: total,
    year: year,
    month: month,
    day: day,
    hour: calc.div-euclid(rest, MS-PER-HOUR),
    minute: calc.rem-euclid(calc.div-euclid(rest, MS-PER-MINUTE), 60),
    second: calc.rem-euclid(calc.div-euclid(rest, MS-PER-SECOND), 60),
    millisecond: calc.rem-euclid(rest, MS-PER-SECOND),
    weekday: weekday-from-days(days),
    ordinal: ordinal-from-civil(year, month, day),
  )
}

/// Build a moment from UTC calendar parts.
///
/// Out-of-range components normalise into neighbouring units the way
/// `Date.UTC` does — `from-parts(2020, 13, 1)` is 2021-01-01, and
/// `from-parts(2020, 1, 0)` is 2019-12-31. Native `datetime` construction
/// rejects those outright, so the month is folded into range arithmetically
/// and the day is carried as a duration from the first of the month, which
/// keeps every constructed datetime valid.
#let from-parts(year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0) = {
  if type(year) != int or type(month) != int or type(day) != int { return none }
  let mz = month - 1
  let y = year + calc.div-euclid(mz, 12)
  let m = calc.rem-euclid(mz, 12) + 1
  if not is-year-in-range(y) { return none }
  let first = days-from-civil(y, m, 1)
  if first == none { return none }
  from-ms(
    (first + day - 1) * MS-PER-DAY
      + hour * MS-PER-HOUR
      + minute * MS-PER-MINUTE
      + second * MS-PER-SECOND
      + millisecond,
  )
}

/// Milliseconds since the Unix epoch, or `none` for a non-moment.
#let to-ms(moment) = if is-moment(moment) { moment.ms } else { none }

/// Whole seconds since the Unix epoch (floored).
#let to-seconds(moment) = if is-moment(moment) { calc.div-euclid(moment.ms, MS-PER-SECOND) } else { none }

/// Days since 1970-01-01 (floored).
#let to-days(moment) = if is-moment(moment) { calc.div-euclid(moment.ms, MS-PER-DAY) } else { none }

#let _pad(n, width) = {
  let s = str(calc.abs(n))
  let sign = if n < 0 { "-" } else { "" }
  while s.len() < width { s = "0" + s }
  sign + s
}

/// Zero-padded decimal, exposed because callers formatting their own date
/// strings invariably need it.
#let pad = _pad

/// ISO 8601 with a `Z` suffix, matching JavaScript's `Date.toISOString()`:
/// `YYYY-MM-DDTHH:mm:ss.sssZ`.
#let to-iso(moment) = {
  if not is-moment(moment) { return none }
  (
    _pad(moment.year, 4) + "-" + _pad(moment.month, 2) + "-" + _pad(moment.day, 2) + "T" +
    _pad(moment.hour, 2) + ":" + _pad(moment.minute, 2) + ":" + _pad(moment.second, 2) + "." +
    _pad(moment.millisecond, 3) + "Z"
  )
}

/// Date part only: `YYYY-MM-DD`.
#let to-iso-date(moment) = {
  if not is-moment(moment) { return none }
  _pad(moment.year, 4) + "-" + _pad(moment.month, 2) + "-" + _pad(moment.day, 2)
}

/// Shift a moment by a whole number of milliseconds.
#let add-ms(moment, ms) = if is-moment(moment) { from-ms(moment.ms + ms) } else { none }

/// Shift a moment by whole days.
#let add-days(moment, days) = add-ms(moment, days * MS-PER-DAY)

/// Shift by calendar months, clamping the day to the target month's length so
/// that Jan 31 + 1 month is Feb 28/29 rather than spilling into March.
#let add-months(moment, months) = {
  if not is-moment(moment) { return none }
  let mz = moment.month - 1 + months
  let year = moment.year + calc.div-euclid(mz, 12)
  let month = calc.rem-euclid(mz, 12) + 1
  from-parts(
    year, month, calc.min(moment.day, days-in-month(year, month)),
    hour: moment.hour, minute: moment.minute,
    second: moment.second, millisecond: moment.millisecond,
  )
}

/// Convert to a Typst `datetime`. Lossy: Typst datetimes carry no
/// milliseconds, so those are dropped.
#let to-typst-datetime(moment) = {
  if not is-moment(moment) { return none }
  datetime(
    year: moment.year, month: moment.month, day: moment.day,
    hour: moment.hour, minute: moment.minute, second: moment.second,
  )
}

/// Convert from a Typst `datetime`. A date-only datetime is taken as UTC
/// midnight. Returns `none` if the value carries neither date nor time.
#let from-typst-datetime(value) = {
  if type(value) != datetime { return none }
  let y = value.year()
  if y == none { return none }
  // A date-only `datetime` returns `none` from the time accessors.
  let or0(v) = if v == none { 0 } else { v }
  from-parts(
    y, value.month(), value.day(),
    hour: or0(value.hour()), minute: or0(value.minute()), second: or0(value.second()),
  )
}
