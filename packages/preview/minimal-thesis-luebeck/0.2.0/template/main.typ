#import "@preview/abbr:0.1.1"
#import "utils/todo.typ": TODO
#import "utils/print-page-break.typ": print-page-break
#import "texts/metadata.typ": *
#import "utils/bib_state.typ": *

#set document(title: title-english, author: author)

// #############################################
// ################# Settings ##################
// #############################################
#let body-font = "New Computer Modern"
#let sans-font = "New Computer Modern Sans"
#set text(
  font: body-font, 
  size: 12pt, 
  lang: "en"
)
// Headings
#show heading: set block(below: 0.85em, above: 1.75em)
#show heading: set text(font: sans-font)
#set heading(numbering: "1.1")
// Reference first-level headings as "chapters"
#show ref: it => {
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
// Math
#show math.equation: set text(weight: 400)
// Paragraphs
#set par(leading: 1em)
// Citations
#set cite(style: "alphanumeric")
// Figures
#show figure: set text(size: 0.85em)
// Bibliography
#bib_state.update(none)
// #############################################
// ############## End of Settings ##############
// #############################################

// --- Title ---
#include "texts/titlepage.typ"
#print-page-break(print: is-print, to: "even")

// --- Disclaimer ---
#set page(
  margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
  numbering: "i",
  number-align: center,
)
#include "texts/disclaimer.typ"
#print-page-break(print: is-print)

// --- Acknowledgement ---
#include "texts/acknowledgement.typ"
#print-page-break(print: is-print)

// --- Abstract ---
#include "texts/abstract.typ"
#pagebreak()

// --- Table of contents ---
#include "texts/toc.typ"
#pagebreak()

// --- List of acronyms ---
#include "texts/acronyms.typ"
#abbr.list(title: "List of acronyms")
#pagebreak()

// --- Main body ---
#set par(justify: true, first-line-indent: 2em)
#set page(
  numbering: "1",
)
// start at page 1 again
#counter(page).update(1)

#include "thesis.typ"

// --- Bibliography ---
#pagebreak()
#bibliography("thesis.bib")

// --- List of figures ---
#pagebreak()
#heading(numbering: none)[List of Figures]
#outline(
  title:"",
  target: figure.where(kind: image),
)

// --- List of tables ---
#pagebreak()
#heading(numbering: none)[List of Tables]
#outline(
  title: "",
  target: figure.where(kind: table)
)

// --- Appendix ---
#pagebreak()
#include "texts/appendix.typ"