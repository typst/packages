// Month and weekday name tables, and the lookups over them.
//
// Kept in one place because the parser and any formatter both need them, and
// because building the lookup dictionary once at module level means the cost
// is paid per compile rather than per call.

#let MONTH-NAMES = (
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
)

#let MONTH-ABBR = (
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
)

#let WEEKDAY-NAMES = (
  "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
)

#let WEEKDAY-ABBR = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

// Lowercased name -> month number. Includes both the full names and the
// three-letter abbreviations, plus "sept", which appears in the wild often
// enough to be worth the one extra entry.
#let _MONTH-LOOKUP = {
  let m = (:)
  for (i, name) in MONTH-NAMES.enumerate() { m.insert(lower(name), i + 1) }
  for (i, name) in MONTH-ABBR.enumerate() { m.insert(lower(name), i + 1) }
  m.insert("sept", 9)
  m
}

/// Month number (1-12) for a month name or abbreviation, else `none`.
/// Case-insensitive; a trailing `.` is tolerated (`"Jan."`).
#let month-from-name(name) = {
  if type(name) != str { return none }
  let key = lower(name.trim().trim(".", at: end))
  _MONTH-LOOKUP.at(key, default: none)
}

/// English month name for 1-12, else `none`.
#let month-name(month, abbreviated: false) = {
  if type(month) != int or month < 1 or month > 12 { return none }
  if abbreviated { MONTH-ABBR.at(month - 1) } else { MONTH-NAMES.at(month - 1) }
}

/// English weekday name for ISO weekday 1-7 (Monday = 1), else `none`.
#let weekday-name(weekday, abbreviated: false) = {
  if type(weekday) != int or weekday < 1 or weekday > 7 { return none }
  if abbreviated { WEEKDAY-ABBR.at(weekday - 1) } else { WEEKDAY-NAMES.at(weekday - 1) }
}
