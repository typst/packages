#import "template/config/titlepage.typ": *
#import "template/config/disclaimer.typ": *
#import "template/config/acknowledgement.typ": acknowledgement as acknowledgement_config
#import "template/config/abstract.typ": *
#import "template/config/utils/print_page_break.typ": *
#import "@preview/abbr:0.1.1"

#let thesis(
  title: "",
  titleGerman: "",
  degree: "",
  program: "",
  supervisor: "",
  advisor: none,
  author: "",
  university: "",
  institute: "",
  company: none,
  submissionDate: datetime,
  abstract_en: "",
  abstract_de: "",
  acknowledgement: none,
  place: none,
  is_print: false,
  body,
) = {
  titlepage(
    title: title,
    titleGerman: titleGerman,
    degree: degree,
    program: program,
    supervisor: supervisor,
    advisor: advisor,
    author: author,
    university: university,
    institute: institute,
    company: company,
    submissionDate: submissionDate,
    place: place
  )

  print_page_break(print: is_print, to: "even")

  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: "i",
    number-align: center,
  )
  disclaimer(
    title: title,
    degree: degree,
    author: author,
    submissionDate: submissionDate
  )
  print_page_break(print: is_print)

  if acknowledgement != none {
    acknowledgement_config(acknowledgement)
    print_page_break(print: is_print)
  }

  abstract(lang: "en")[#abstract_en]
  abstract(lang: "de")[#abstract_de]
  pagebreak()

  let body-font = "New Computer Modern"
  let sans-font = "New Computer Modern Sans"

  set text(
    font: body-font, 
    size: 12pt, 
    lang: "en"
  )
  
  show math.equation: set text(weight: 400)

  // --- Headings ---
  show heading: set block(below: 0.85em, above: 1.75em)
  show heading: set text(font: sans-font)
  set heading(numbering: "1.1")
  // Reference first-level headings as "chapters"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      [Chapter ]
      numbering(
        el.numbering,
        ..counter(heading).at(el.location())
      )
    } else {
      it
    }
  }

  // --- Paragraphs ---
  set par(leading: 1em)

  // --- Citations ---
  set cite(style: "alphanumeric")

  // --- Figures ---
  show figure: set text(size: 0.85em)
  
  // --- Table of Contents ---
  [
    // Make chapter bold but only in the TOC
    #show outline.entry.where(
      level: 1
    ): it => {
      v(12pt, weak: true)
      strong(text(it, font: sans-font))
    }

    #outline(
      title: {
        text(font: body-font, 1.5em, weight: 700, "Contents")
        v(15mm)
      },
      indent: 2em
    )
  ]
  pagebreak()

  // List of acronyms
  include "template/config/acronyms.typ"
  abbr.list(title: "List of acronyms")

  pagebreak()

  // Main body.
  set par(justify: true, first-line-indent: 2em)
  set page(
    numbering: "1",
  )
  // start at page 1 again
  counter(page).update(1)

  body

  pagebreak()
  bibliography("template/thesis.bib")

  // List of figures.
  pagebreak()
  heading(numbering: none)[List of Figures]
  outline(
    title:"",
    target: figure.where(kind: image),
  )

  // List of tables.
  pagebreak()
  heading(numbering: none)[List of Tables]
  outline(
    title: "",
    target: figure.where(kind: table)
  )

  // Appendix.
  pagebreak()
  include("template/texts/appendix.typ")
}
