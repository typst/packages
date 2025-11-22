#import "helpers.typ": *
#import "pages/title-page.typ": *
#import "pages/outlines.typ": *
#import "pages/main.typ": *
#import "pages/appendices.typ": *
#import "pages/abstract.typ": *


#let template(title, authors, adviser, college, degree-program, month, year, abstract, keywords, doc) = {
  set page(
    paper: "us-letter", margin: (left: 1.5in, rest: 1in),
    // Page count before the actual manuscript should be in small roman numeral
    // as per university's manual.
    numbering: "i", footer: context[
      #let page-number = counter(page).at(here()).first()
      #let match-list = query(selector(<turn-on-page-numbering>).before(here()))
      #if match-list == () { return none }
      #align(center, counter(page).display("i"))
    ],
  )

  set text(font: "Arial", size: 11pt)

  title-page(title, authors, college, degree-program, month, year)

  show heading: it => [
    // the configuration in par() above also affects headings, the
    // option below reverted some of the changes
    #set par(leading: 1em, first-line-indent: 0em, justify: false)

    // Rule: everything (including heading) must be in 11pt font size
    #set text(size: 11pt)

    #it.body
  ]

  if abstract != [] {
    abstract-section(
      title,
      authors,
      degree-program,
      year,
      adviser,
      abstract,
      keywords,
    )
  }

  table-of-contents(abstract)

  set par(leading: 1.5em, justify: true, spacing: 2em)

  list-of-tables()
  list-of-figures()

  show: main-content
  doc
}
