#let title-page(title, authors, college, degree-program, month, year) = {
  show heading: it => [
    #set text(size: 14pt)
    #it.body
  ]
  title = upper(title)

  align(center)[
    #v(6em)
    #hide(heading("TITLE PAGE")) \
    #heading(outlined: false, title)

    #v(6em)
    A Thesis Proposal \
    Presented to the Faculty of the \
    #college \
    Polytechnic University of the Philippines

    #v(6em)
    In Partial Fulfillment \
    of the Requirements for the Degree \
    #degree-program \

    #v(8em)
    by

    #v(4em)
    #for author in authors [
      #strong(author) \
    ]

    #v(2em)
    #month #year
  ]

  pagebreak(weak: true)
}
