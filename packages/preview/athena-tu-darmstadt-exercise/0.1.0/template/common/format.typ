#let format-date(date, language) = {
  let date_cont = date.display("[month repr:long] [day], [year]")
  if (language == "ger") {
    date_cont = date.display("[day].[month repr:numerical].[year]")
  }
  return date_cont
}