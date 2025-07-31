#import "pages/title-page.typ": *
#import "pages/outlines.typ": *
#import "pages/main.typ": *
#import "pages/appendices.typ": *


#let template(title, authors, college, degree-program, date, doc) = {
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

  title-page(title, authors, college, degree-program, date)

  show heading: it => [
    // the configuration in par() above also affects headings, the
    // option below reverted some of the changes
    #set par(leading: 1em, first-line-indent: 0em, justify: false)

    // Rule: everything (including heading) must be in 11pt font size
    #set text(size: 11pt)

    #it.body
  ]

  table-of-contents()

  set par(leading: 1.5em, justify: true, spacing: 2em)

  list-of-tables()
  list-of-figures()

  show: main-content
  doc
}

#let chapter(number, title) = {
  pagebreak(weak: true)
  title = upper(title) // Rule: chapter title must be in uppercase
  align(center)[
    *Chapter #number*
    #v(-1em)
    #heading(title)
  ]
}

#let description(terms) = {
  show par: it => {
    block(inset: (left: 0.5in))[#it]
  }
  for term in terms [#par([#h(0.5in) *#term.term*. #term.desc])]
}
