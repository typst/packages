#let format-date(date, language) = if type(date) != datetime {
  date
} else if language == "ger" {
  date.display("[day].[month repr:numerical].[year]")
} else {
  date.display("[month repr:long] [day], [year]")
}

#let text-roboto(body) = {
  set text(font: "Roboto")
  body
}

#let text-xcharter(body) = {
  set text(font: "XCharter")
  body
}