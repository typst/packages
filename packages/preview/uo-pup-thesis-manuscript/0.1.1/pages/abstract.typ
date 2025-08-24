#let abstract-section(
  title,
  authors,
  degree,
  year,
  adviser,
  abstract,
  keywords
) = [
  #align(center)[
    #heading("ABSTRACT") <turn-on-page-numbering>
  ]
  #table(
    columns: (1in, 0.5cm, 1fr),
    inset: 3pt,
    stroke: none,
    row-gutter: 0.5em,
    [Title], [:], [#title],
    [Researchers], [:], [
      #for author in authors [
        #author \
      ]
    ],
    [Degree], [:], [#degree],
    [Institution], [:], [Polytechnic University of the Philippines],
    [Year], [:], [#year],
    [#if adviser != "" [Adviser]],
    [#if adviser != "" [:]],
    [#if adviser != "" [#adviser]]
  )

  #set par(leading: 1.5em, justify: true, spacing: 2em)

  #h(0.5in)#abstract

  #block[
    #set par(leading: 0.5em)
    Keywords: #for keyword in keywords [
      #keyword,
    ]
  ]

  #pagebreak(weak: true)
]
