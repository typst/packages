#let _toDate = date => {
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
 * toDate is a helper function to convert strings to datetime.
 * The date parameter must be datetime|str.
 * If the date parameter is `str`, it must be of the format `yyyy-MM-dd`.
 * If the date parameter already is a datetime toDate just returns it.
 */
#let toDate = date => {
  let (date, error) = _toDate(date)
  assert.ne(date, none, message: "" + error)
  return date
}

/**
 * True if dateB is on the same day or later than dateA.
 * Expects both parameters to be datetimes.
 */
#let sameDayOrLater = (dateA, dateB) => {
  if dateA.year() > dateB.year() { return false }
  if dateA.year() < dateB.year() { return true }

  if dateA.month() > dateB.month() { return false }
  if dateA.month() < dateB.month() { return true }

  return dateA.day() <= dateB.day()
}
