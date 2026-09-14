#let datetime-display(date) = {
  date.display("[year]年[month]月[day]日")
}

#let datetime-display-without-day(date) = {
  date.display("[year]年[month]月")
}

#let datetime-en-display(date) = (
  if date.day() == 1 or date.day() == 21 or date.day() == 31 {
    date.display("[month repr:long]") + " " + $date.display("[day]")^"st"$ + ", " + date.display("[year]")
  } else if date.day() == 2 or date.day() == 22 {
    date.display("[month repr:long]") + " " + $date.display("[day]")^"nd"$ + ", " + date.display("[year]")
  } else if date.day() == 3 or date.day() == 23 {
    date.display("[month repr:long]") + " " + $date.display("[day]")^"rd"$ + ", " + date.display("[year]")
  } else {
    date.display("[month repr:long]") + " " + $date.display("[day]")^"th"$ + ", " + date.display("[year]")
  }
)

#let datetime-en-display-without-day(date) = {
  date.display("[month repr:long], [year]")
}
