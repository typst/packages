// helper: true if a value is missing (none or an empty string)
#let is-missing(value) = value == none or value == ""

// "bachelor" or "master" for final theses (Abschlussarbeiten), none for other papers (e.g. Hausarbeit, Praxisbericht).
// The Leitfaden has additional requirements for final theses, e.g. a Management Summary or Abstract and a guideline for
// the number of words.
#let final-thesis-level(thesis-type) = {
  let type = lower(thesis-type)
  if type.contains("bachelor") { "bachelor" } else if type.contains("master") { "master" } else { none }
}

// number with thousands separator, e.g. 12.000 (de) or 12,000 (en)
#let format-number(number, language) = {
  let digits = str(number)
  let separator = if language == "de" { "." } else { "," }
  let groups = ()
  while digits.len() > 3 {
    groups.insert(0, digits.slice(-3))
    digits = digits.slice(0, -3)
  }
  groups.insert(0, digits)
  groups.join(separator)
}

// guideline for the number of words of the main text (Leitfaden, Section 2.1)
#let word-guideline(thesis-type) = {
  let level = final-thesis-level(thesis-type)
  if level != none { (bachelor: 10000, master: 12000).at(level) }
}

// format a date: a datetime is formatted for the language (31.03.2026 or 31 March 2026), anything else (e.g. a
// string) is shown as it is
#let format-date(date, language) = {
  if type(date) != datetime { return date }
  if language == "de" { date.display("[day].[month].[year]") } else {
    date.display("[day padding:none] [month repr:long] [year]")
  }
}
