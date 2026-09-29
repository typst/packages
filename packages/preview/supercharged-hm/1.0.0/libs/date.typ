// Copyright 2026 Felix Schladt https://github.com/FelixSchladt

#let german-months = (
  "Januar",
  "Februar",
  "März",
  "April",
  "Mai",
  "Juni",
  "Juli",
  "August",
  "September",
  "Oktober",
  "November",
  "Dezember",
)

#let english-months = (
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
)

#let format-date(date, language, date-format) = {
  if type(date) != datetime {
    panic("date must be a datetime")
  }

  if type(date-format) == function {
    return date-format(date, language)
  }

  if date-format != auto {
    if type(date-format) != str {
      panic("date-format must be auto, a string, or a function")
    }
    return date.display(date-format)
  }

  if date.year() == none or date.month() == none or date.day() == none {
    panic("Localized date formatting requires year, month, and day")
  }

  let months = if language == "de" {
    german-months
  } else {
    english-months
  }
  let month = months.at(date.month() - 1)
  let day = if language == "de" {
    str(date.day()) + "." // german date notation does a dot normally
  } else {
    str(date.day())
  }

  day + " " + month + " " + str(date.year())
}
