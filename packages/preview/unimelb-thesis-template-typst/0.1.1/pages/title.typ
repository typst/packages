#import "../utils/style.typ": thesis-style, format-date, unimelb-logo

#let title-page(
  title: none,
  subtitle: none,
  author: none,
  degree: none,
  department: none,
  school: none,
  university: none,
  supervisor: none,
  co_supervisor: none,
  submission_date: none,
  blind: false,
) = {
  align(center)[
    #text(size: 24pt, weight: "bold", fill: thesis-style.colors.primary)[
      The University of Melbourne
    ]
    #v(1em)
    #image("../assets/logos/unimelb-logo-official.svg", width: 120pt)
    #v(2em)
  ]

  align(center)[
    #text(size: 18pt, weight: "bold")[#title]
    #if subtitle != none {
      v(0.5em)
      text(size: 14pt, style: "italic")[#subtitle]
    }
    #v(2em)
  ]

  align(center)[
    #text(size: 14pt)[A thesis submitted in fulfilment of the requirements]
    #v(0.5em)
    #text(size: 14pt)[for the degree of #degree]
    #v(1em)
    #text(size: 14pt)[in the #department]
    #v(0.5em)
    #text(size: 14pt)[#school]
    #v(1em)
    #text(size: 14pt)[#university]
    #v(2em)
  ]

  align(center)[
    #text(size: 16pt)[
      #if blind {
        [Author]
      } else {
        [#author]
      }
    ]
    #v(2em)
  ]

  align(center)[
    #text(size: 12pt)[Supervisor: #supervisor]
    #if co_supervisor != none {
      v(0.5em)
      text(size: 12pt)[Co-supervisor: #co_supervisor]
    }
    #v(1em)
    #text(size: 12pt)[#format-date(submission_date)]
  ]

  pagebreak()
}
