#let report(
  body,
  title: [My report],
  author: "Student Name",
  subtitle: none,
  date: datetime.today(),
  language: "en",
  font: "Libertinus Serif",
  text-size: 11pt,
  page-margin: 2.5cm,
  logo-size: 1cm,
  footer-font-size: 0.8em,
  cover-title-size: 30pt,
  cover-subtitle-size: 18pt,
  cover-page: true,
  outline-page: true,
  keywords: (),
  description: none,
  school-logo: none,
  company-logo: none,
  footer-content: none,
  highlight-color: rgb("#00727A"),
  bibliography: none,
) = {
  let display-date = if type(date) == datetime {
    date.display("[day] [month repr:long] [year]")
  } else {
    date
  }

  set page(paper: "a4", margin: page-margin)
  set text(size: text-size, lang: language, font: (font, "Libertinus Serif"))
  set par(justify: true, first-line-indent: (amount: 1.5em, all: true))
  set heading(numbering: "1.")
  set highlight(fill: highlight-color.lighten(75%))
  show heading: set text(fill: highlight-color)

  set document(
    title: title,
    author: author,
    date: if type(date) == datetime { date } else { auto },
    keywords: keywords,
    description: description,
  )

  let header-content = {
    set image(height: logo-size)
    grid(
      columns: (1fr, 1fr),
      align(left, if school-logo != none { school-logo }),
      align(right, if company-logo != none { company-logo }),
    )
  }
  let footer-layout = grid(
    columns: (1fr, auto, 1fr),
    align(left, text(size: footer-font-size, if footer-content == none { author } else { footer-content })),
    align(center, context counter(page).display()),
    align(right, text(size: footer-font-size, display-date)),
  )

  if cover-page {
    block(width: 100%, height: 100%)[
      #{
        set image(height: 2 * logo-size)
        header-content
      }
      #v(1fr)
      #align(center)[
        #text(size: cover-title-size, weight: "bold", fill: highlight-color)[#title]
        #if subtitle != none {
          v(0.6em)
          text(size: cover-subtitle-size, weight: "medium")[#subtitle]
        }
        #v(1.6em)
        #text(size: 13pt, weight: "semibold")[#author]
        #v(0.5em)
        #text(size: 12pt)[#display-date]
      ]
      #v(1fr)
    ]
    pagebreak()
  }

  set page(header: header-content, footer: footer-layout)

  if outline-page {
    outline()
    pagebreak()
  }

  body

  if bibliography != none {
    pagebreak()
    bibliography
  }
}
