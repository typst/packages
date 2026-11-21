/// Parse a journal date into numeric day, month, and year parts.
///
/// Accepted inputs are `YYYY-MM-DD`, `DD/MM/YY`, or `DD/MM/YYYY`, optionally
/// preceded by a weekday and comma or space. Two-digit years are interpreted
/// as 20xx. An empty string returns `none`, which lets draft entries appear in
/// the index's Undated group. Invalid formats and impossible calendar dates
/// raise an assertion error. The returned month and day are validated against
/// the selected year, including Gregorian leap-year rules.
///
/// - date (str): date string to parse; empty is allowed
/// -> dictionary or none: `(day:, month:, year:)` for a dated entry, otherwise
///   `none`
#let journal-date-parts(date) = {
  assert(type(date) == str, message: "journal-entry date must be a string.")
  if date == "" { return none }

  let clean = date
  let comma-parts = clean.split(", ")
  assert(comma-parts.len() <= 2, message: "Journal dates may have one optional weekday prefix.")
  if comma-parts.len() == 2 { clean = comma-parts.last() }
  let word-parts = clean.split(" ")
  assert(word-parts.len() <= 2, message: "Journal dates may have one optional weekday prefix.")
  if word-parts.len() == 2 { clean = word-parts.last() }

  let year = 0
  let month = 0
  let day = 0
  if clean.matches(regex("^\\d{4}-\\d{2}-\\d{2}$")).len() == 1 {
    let parts = clean.split("-")
    year = int(parts.at(0))
    month = int(parts.at(1))
    day = int(parts.at(2))
  } else {
    assert(clean.matches(regex("^\\d{1,2}/\\d{1,2}/(\\d{2}|\\d{4})$")).len() == 1,
      message: "Journal date must use YYYY-MM-DD or DD/MM/YY (or DD/MM/YYYY), optionally preceded by a weekday.")
    let parts = clean.split("/")
    day = int(parts.at(0))
    month = int(parts.at(1))
    let year-text = parts.at(2)
    year = int(if year-text.len() == 2 { "20" + year-text } else { year-text })
  }

  assert(month >= 1 and month <= 12, message: "Journal date month must be from 1 to 12.")
  let leap = calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0)
  let days-in-month = (
    31,
    if leap { 29 } else { 28 },
    31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
  )
  assert(day >= 1 and day <= days-in-month.at(month - 1),
    message: "Journal date day is outside the selected month.")
  (day: day, month: month, year: year)
}
