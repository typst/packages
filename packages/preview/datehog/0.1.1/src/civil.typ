// Calendar arithmetic, on Typst's native `datetime` and `duration`.
//
// Typst can subtract two datetimes to get a duration and add a duration back,
// which covers every conversion between a calendar date and a day count. That
// is used directly here rather than reimplementing the calendar: the built-in
// is the same `time` crate the rest of Typst dates on, so there is one
// definition of the Gregorian calendar in play instead of two.
//
// Two things the built-in does *not* give us, and this module has to:
//
//   * **Validation.** `datetime(year: 2020, month: 2, day: 30)` is an error,
//     and Typst has no way to catch it — a bad cell in a data table would
//     abort the whole document. So nothing here constructs a datetime without
//     checking it first, which is why the month-length table survives.
//   * **Range guarding.** Native datetimes span years -9999 to 9999. Going
//     past the top does not raise a Typst error, it *panics the compiler*
//     (a Rust panic inside the `time` crate), so the bounds are checked
//     rather than trusted.

/// The reference instant for every day count in this package.
#let EPOCH = datetime(year: 1970, month: 1, day: 1)

/// Representable year bounds, imposed by Typst's `datetime`.
#let MIN-YEAR = -9999
#let MAX-YEAR = 9999

/// Day-count bounds corresponding to [`MIN-YEAR`] / [`MAX-YEAR`].
#let MIN-DAYS = int((datetime(year: MIN-YEAR, month: 1, day: 1) - EPOCH).days())
#let MAX-DAYS = int((datetime(year: MAX-YEAR, month: 12, day: 31) - EPOCH).days())

/// Is `year` inside the representable range?
#let is-year-in-range(year) = type(year) == int and year >= MIN-YEAR and year <= MAX-YEAR

/// Is `days` inside the representable range?
#let is-days-in-range(days) = type(days) == int and days >= MIN-DAYS and days <= MAX-DAYS

/// Is `year` a leap year?
///
/// Asks the calendar rather than restating its rule: a leap year is one whose
/// 31 December is the 366th day.
#let is-leap-year(year) = {
  if not is-year-in-range(year) { return false }
  datetime(year: year, month: 12, day: 31).ordinal() == 366
}

#let _MONTH_LENGTHS = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

/// Number of days in `month` (1-12) of `year`, or 0 for a bad month.
///
/// Kept as a table because it is the *precondition* for constructing a
/// datetime safely — deriving it from datetime arithmetic would mean
/// constructing one first, which is the thing being guarded against.
#let days-in-month(year, month) = {
  if type(month) != int or month < 1 or month > 12 { return 0 }
  if month == 2 and is-leap-year(year) { 29 } else { _MONTH_LENGTHS.at(month - 1) }
}

/// Is (year, month, day) a real, representable calendar date?
#let is-valid-date(year, month, day) = (
  type(year) == int and type(month) == int and type(day) == int
    and is-year-in-range(year)
    and month >= 1 and month <= 12
    and day >= 1 and day <= days-in-month(year, month)
)

/// Days since 1970-01-01, or `none` if the date is invalid or out of range.
#let days-from-civil(year, month, day) = {
  if not is-valid-date(year, month, day) { return none }
  int((datetime(year: year, month: month, day: day) - EPOCH).days())
}

/// Inverse of [`days-from-civil`]: `(year, month, day)`, or `none` out of range.
#let civil-from-days(days) = {
  if not is-days-in-range(days) { return none }
  let d = EPOCH + duration(days: days)
  (d.year(), d.month(), d.day())
}

/// ISO weekday for a day count: Monday = 1 ... Sunday = 7. `none` out of range.
#let weekday-from-days(days) = {
  if not is-days-in-range(days) { return none }
  (EPOCH + duration(days: days)).weekday()
}

/// Day of the year, 1-366, or `none` if the date is invalid.
#let ordinal-from-civil(year, month, day) = {
  if not is-valid-date(year, month, day) { return none }
  datetime(year: year, month: month, day: day).ordinal()
}
