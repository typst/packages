/// Format a date value into a localized string.
///
/// - date: auto | str | datetime
///   - auto → uses datetime.today()
///   - str  → returned as-is (user-supplied string like "15. März 2026")
///   - datetime → formatted according to lang
/// - lang: "de" | "en"
/// Returns a string like "15. März 2026" (de) or "March 15, 2026" (en)
#let format-date(date, lang: "de") = {
  if type(date) == str { return date }

  let d = if date == auto { datetime.today() } else { date }

  let months-de = (
    "Januar", "Februar", "März", "April", "Mai", "Juni",
    "Juli", "August", "September", "Oktober", "November", "Dezember",
  )
  let months-en = (
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  )

  if lang == "de" {
    str(d.day()) + ". " + months-de.at(d.month() - 1) + " " + str(d.year())
  } else {
    months-en.at(d.month() - 1) + " " + str(d.day()) + ", " + str(d.year())
  }
}
