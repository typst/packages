#let datetime-display(date) = {
  date.display("[year]年[month padding:none]月[day padding:none]日")
}

#let datetime-display-without-day(date) = {
  date.display("[year]年[month padding:none]月")
}

#let datetime-en-display(date) = (
  if date.day() == 1 or date.day() == 21 or date.day() == 31 {
    date.display("[month repr:long]") + " " + $date.display("[day padding:none]")^"st"$ + ", " + date.display("[year]")
  } else if date.day() == 2 or date.day() == 22 {
    date.display("[month repr:long]") + " " + $date.display("[day padding:none]")^"nd"$ + ", " + date.display("[year]")
  } else if date.day() == 3 or date.day() == 23 {
    date.display("[month repr:long]") + " " + $date.display("[day padding:none]")^"rd"$ + ", " + date.display("[year]")
  } else {
    date.display("[month repr:long]") + " " + $date.display("[day padding:none]")^"th"$ + ", " + date.display("[year]")
  }
)

#let datetime-en-display-without-day(date) = {
  date.display("[month repr:long], [year]")
}
