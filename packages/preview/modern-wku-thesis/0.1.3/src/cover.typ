// Cover pages: the front cover and the back of the cover page.

// The front cover page.
#let cover-page(title: none, author: none, degree: none, department: none, university: none, supervisor: none, month: none, year: none) = {
  set text(size: 14pt)
  align(center)[
    #text(size: 21pt, weight: "bold")[#title]

    #text(size: 12pt)[by:]

    #text(weight: "bold")[#author]

    #v(3em)

    #text(size: 12pt)[
      A Thesis Submitted in Fulfillment of the Requirements for the Degree of
    ]

    #text(weight: "bold")[#degree]

    #v(3em)

    // University logo
    #image("assets/logo.png", width: 100pt)

    #v(3em)

    #department

    #university

    #v(2em)

    Supervised By: \ *#supervisor*

    #v(2em)

    ©#month #year
  ]
  pagebreak()
}

// The back of the cover page (title page).
#let back-cover-page(title: none, author: none, university: none, supervisor: none, program-type: none, degree-year: none, degree-type: none, degree-department: none) = {
  set text(size: 12pt)
  grid(
    columns: (1fr, 1fr),
    column-gutter: auto,
    row-gutter: 1.5em,
    align: (left, right),
    [
      #program-type (#degree-year)
      #linebreak()
      #degree-department
    ],
    [
      #university
      #linebreak()
      Wenzhou, China
    ],
  )
  v(5em)
  grid(
    columns: (0.5fr, 1fr),
    column-gutter: auto,
    row-gutter: 3em,
    align: (left, left),
    [TITLE:],
    [#title],
    [AUTHOR:],
    [
      #author
      #linebreak()
      #degree-type, (#degree-department)
      #linebreak()
      #university
      #linebreak()
      Wenzhou, China
    ],
    [SUPERVISORS:],
    [#supervisor],
    // Number of pages row - auto-generated
    [NUMBER OF PAGES:],
    [
      #context counter(page).final().first()
    ],
  )
  pagebreak()
}
