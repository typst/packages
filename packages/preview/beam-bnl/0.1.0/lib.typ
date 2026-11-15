#let bnl-letter(
  comment: none,
  address: [Building XXX\
    P.O. Box 5000\
    Upton, NY 11973-5000\
    Phone: your phone number\
    your.name\@bnl.gov],
  department: [Your department],
  logo: none,
  signature: none,
  info: [Your name\
    Your title\
    Your group\
    Brookhaven National Laboratory],
  fontsize: 10pt,
  headerfontsize: 7pt,
  date: none,
  references: none,
  body) = {

set par(justify: true)
set text(font: ("Arial", "Liberation Sans"),
          size: fontsize,
          weight: "regular")

set page(
  paper: "us-letter",
  number-align: center,
  numbering: "1 / 1",
)

place(top, text(headerfontsize)[#department],
     dy: -20pt)

if logo != none {
  place(top, box(width: 2.13in, logo), dx: -38pt, dy: 10pt)
}

align(right, text(headerfontsize)[
  #address
  
  managed by Brookhaven Science Associates\
  for the U.S. Department of Energy
  
  #link("https://www.bnl.gov")
])

let format-date(date) = {
  let day = date.day()
  let ord = if 10 < day and day < 20 {
    "th"
  } else if calc.rem(day, 10) == 1 {
    "st"
  } else if calc.rem(day, 10) == 2 {
    "nd"
  } else if calc.rem(day, 10) == 3 {
    "rd"
  } else {
    "th"
  }
  [#date.display("[month repr:long]") #day#super[#ord], #date.year()]
}

if date == none {
  format-date(datetime.today())
}
else if type(date) == datetime {
  format-date(date)
}
else {date}

v(20pt)
if comment != none [
  #comment
  #v(20pt)
]
body

if signature != none [
  #signature
  ]
info

if references != none {
  references
}

}
