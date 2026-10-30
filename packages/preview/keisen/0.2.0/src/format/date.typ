///! Date formatting.
///!
///! A date is opaque content: there is no decimal point to line up on, so a date
///! column follows the column alignment like any other text.
///!
///! ISO-8601 strings are accepted because that is how dates arrive from a file,
///! and they are parsed by pre-check rather than attempted: Typst has no `try`,
///! so `datetime` is only ever constructed from parts already known to be whole
///! numbers in range.

#import "../utils/errors.typ": fail, fail-type
#import "number.typ": format

// Date, optional time, optional seconds, optional UTC marker. The date and the
// time may be joined by a T or by a space, which is what SQL and spreadsheet
// exports write.
#let _ISO = regex("^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2}))?(?:\.\d+)?Z?)?$")

// Days in each month, so a date that does not exist is refused rather than
// handed to `datetime`, which panics on one and cannot be caught.
#let _days(year, month) = {
  let lengths = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if month != 2 { return lengths.at(month - 1) }
  if calc.rem(year, 400) == 0 or (calc.rem(year, 4) == 0 and calc.rem(year, 100) != 0) { 29 } else { 28 }
}

#let _parse(value) = {
  let found = value.match(_ISO)
  if found == none { return none }

  let part(index) = {
    let text = found.captures.at(index)
    if text == none { 0 } else { int(text) }
  }
  let (year, month, day) = (part(0), part(1), part(2))
  let (hour, minute, second) = (part(3), part(4), part(5))

  if month < 1 or month > 12 { return none }
  if day < 1 or day > _days(year, month) { return none }
  if hour > 23 or minute > 59 or second > 59 { return none }

  datetime(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
}

#let to-datetime(value) = {
  if type(value) == datetime { return value }
  if type(value) == str { return _parse(value) }
  none
}

// `pattern` is Typst's own, so anything `datetime.display` accepts works here.
// An invalid pattern is reported by Typst rather than pre-checked: its grammar
// is Typst's to define, and duplicating it here would drift.
#let format-date(columns, rows: auto, pattern: "[year]-[month]-[day]") = format(
  columns,
  rows: rows,
  scope: "format-date",
  value => {
    if type(value) != datetime and type(value) != str {
      fail-type(
        "format-date",
        "value",
        value,
        "a datetime or an ISO-8601 string",
        hint: "Write \"2026-08-26\" in the data, or datetime(year: 2026, month: 8, day: 26).",
      )
    }
    let moment = to-datetime(value)
    if moment == none {
      fail(
        "format-date",
        "value is not a date",
        value: value,
        hint: "Give a datetime, or a string such as 2026-08-14 or 2026-08-14T09:30:00.",
      )
    }
    [#moment.display(pattern)]
  },
)
