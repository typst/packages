/// Gets the length of the month in the datetime.
///
/// Note: this functions is made public only for niche usecases.
/// In all likelihood if you are using this you are probably using
/// `create-custom-header` instead of `create-custom-month-header`
/// -> function
#let month-length(
  /// A datetime for specific month (only year and month are used).
  /// -> datetime
  datetime,
) = {
  let year = datetime.year()
  let month = datetime.month()

  let leap-year = (
    (
      (calc.rem(year, 4) == 0) and not (calc.rem(year, 100) == 0)
    )
      or calc.rem(year, 400) == 0
  )

  let feb = if leap-year {
    29
  } else {
    28
  }

  (31, feb, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31).at(month - 1)
}

/// Parse an iso8601 datetime
///
/// Passes through actual datetime objects
#let parse-datetime(s) = {
  if type(s) == datetime {
    s
  } else {
    datetime(year: int(s.slice(0, 4)), month: int(s.slice(5, 7)), day: int(
      s.slice(8, 10),
    ))
  }
}

/// Gets the dat before the given datetime
#let yesterday(dt) = {
  dt - duration(days: 1)
}
