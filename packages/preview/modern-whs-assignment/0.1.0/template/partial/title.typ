#let title(title, author, submission-date, course, lecturer) = {
  set align(center)

  v(30pt)
  image("../images/logo.png", width: 55%)

  v(70pt)
  text(size: 26pt, weight: 700)[#title]

  v(20pt)
  text(size: 12pt, weight: 500)[

    #author\

    Version vom #submission-date.display("[day].[month].[year]")
  ]

  set align(bottom + left)

  text(size: 12pt, weight: 500)[
    #course \
    #lecturer
  ]

  pagebreak(weak: false)
}
