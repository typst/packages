#import "components.typ": sans-font, variable-pagebreak, author-fullname

#let oot-titlepage(
  title: "",
  document-type: "",
  supervisor: "",
  second-supervisor: "",
  advisors: (),
  author: none,
  city: none,
  date: none,
  organisation: [],
  organisation-logo: none,
  header-logo: none,
  is-doublesided: none,
  lang: "en",
) = {
  set page(numbering: none)

  set par(leading: 1em, first-line-indent: 0em, justify: false)

  align(center, header-logo)

  v(5mm)

  block(inset: 2cm)[
    #text(font: sans-font, 2em, weight: 700, document-type)
    #par(leading: 0.6em)[
      #text(font: sans-font, 1.6em, weight: 500, title)
    ]
    #v(1em)
    #text(font: sans-font, 1.2em, weight: 500, author-fullname(author))
    #if (city != none and date != none) [
      \
      #text(font: sans-font, 1.2em, weight: 500, city + ", " + date)
    ]
  ]

  pad(
    top: 0em,
    right: 15%,
    left: 15%,
    grid(columns: 2, gutter: 1em, strong(if (lang == "de") [
      Betreuer:
    ] else [
      Advisors:
    ]), advisors.join(", "), strong(if (lang == "de") [
      Themensteller:
    ] else [
      Supervisor:
    ]), supervisor, strong(if (lang == "de") [
      Zweitgutachter:
    ] else [
      Second Supervisor:
    ]), second-supervisor),
  )

  align(bottom)[
    #line(length: 100%)
    #grid(
      columns: 2,
      gutter: 1em,
      par(leading: 0.6em, organisation),
      align(right + top)[
        #move(dx: 1.2cm, dy: 0cm)[
          #organisation-logo
        ]
      ],
    )
  ]

  variable-pagebreak(is-doublesided)
}