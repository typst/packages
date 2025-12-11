#let new(year: none, month: none, day: none, hour: none, minute: none, second: none) = {
  assert(type(year) == std.int or year == none, message: "datetime.new: year must be type of int or none")
  assert(type(month) == std.int or month == none, message: "datetime.new: month must be type of int or none")
  assert(type(day) == std.int or day == none, message: "datetime.new: day must be type of int or none")
  assert(type(hour) == std.int or hour == none, message: "datetime.new: hour must be type of int or none")
  assert(type(minute) == std.int or minute == none, message: "datetime.new: minute must be type of int or none")
  assert(type(second) == std.int or second == none, message: "datetime.new: second must be type of int or none")

  (
    "typed-type": "datetime",
    "year": year,
    "month": month,
    "day": day,
    "hour": hour,
    "minute": minute,
    "second": second,
  )
}

/// Encode a datetime into a CBOR-compatible dictionary.
///
/// - datetime (datetime): A datetime.
/// -> dictionary
#let encode(datetime) = {
  assert(type(datetime) == std.datetime, message: "datetime.encode: datetime must be type of datetime")

  new(year: datetime.year(), month: datetime.month(), day: datetime.day(), hour: datetime.hour(), minute: datetime.minute(), second: datetime.second())
}
