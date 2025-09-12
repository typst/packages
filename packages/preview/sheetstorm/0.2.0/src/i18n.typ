#let default-date() = {
  if text.lang == "de" { "[day].[month].[year]" }
  else { "[day] [month repr:long] [year]" }
}

#let task() = {
  if text.lang == "de" { "Aufgabe" }
  else { "Task" }
}

#let point() = {
  if text.lang == "de" { "Punkt" }
  else { "Point" }
}

#let points() = {
  if text.lang == "de" { "Punkte" }
  else { "Points" }
}
