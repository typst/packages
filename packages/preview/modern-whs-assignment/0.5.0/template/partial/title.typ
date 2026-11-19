#let title(title, subtitle, author, submission-date, course, lecturer) = {
  set align(center)

  v(30pt)
  image("../images/logo.png", width: 55%)

  v(70pt)
  text(size: 26pt, weight: 700)[#title]

  if (subtitle != none and subtitle.len() > 0) {
    v(0pt)
    text(size: 17pt, weight: 700)[#subtitle]
  }

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
