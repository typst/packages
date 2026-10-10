#let _to-date = date => {
  if (type(date) != datetime and type(date) != str) {
    return (none, "date must be datetime or string, but got: " + str(type(date)))
  }

  if type(date) == datetime {
    return (date, none)
  }

  let parts = date.match(regex("^(\d{1,4})-(\d{1,2})-(\d{1,2})$"))
  if (parts == none) {
    return (none, "Expecting date string to obey format yyyy-mm-dd.")
  }

  let (year, month, day) = parts.captures
  return (datetime(year: int(year), month: int(month), day: int(day)), none)
}

/**
 * to-date is a helper function to convert strings to datetime.
 * The date parameter must be datetime|str.
 * If the date parameter is `str`, it must be of the format `yyyy-MM-dd`.
 * If the date parameter already is a datetime to-date just returns it.
 */
#let to-date = date => {
  let (date, error) = _to-date(date)
  assert.ne(date, none, message: "" + error)
  return date
}

/**
 * True if date-b is on the same day or later than date-a.
 * Expects both parameters to be datetimes.
 */
#let same-day-or-later = (date-a, date-b) => {
  if date-a.year() > date-b.year() { return false }
  if date-a.year() < date-b.year() { return true }

  if date-a.month() > date-b.month() { return false }
  if date-a.month() < date-b.month() { return true }

  return date-a.day() <= date-b.day()
}
