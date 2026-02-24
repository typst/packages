// install from typst univers
#import "@preview/minimal-unilim-thesis:0.1.1":*

// install in local version
// #import "@local/minimal-unilim-thesis:0.1.1":*

// local development 
// #import "../lib.typ":*

#set par(justify: true)
#set text(
  font: "Arial",
  size: 14pt,
)
#let epigra = (
  "citation":
  [
    Security is a state of mind, not a product.
  ], // <=== Your quote
  "author":
  [
Edward Snowden
  ] // <== Author
  )



#let acknow = include "parts/acknowlegments.typ"
#let intro = include "parts/introduction.typ"
#let my-content = include "parts/content.typ"
#let conclusion = include "parts/conclusion.typ"
#let glossary = include "parts/glossary.typ"
#let appendix = include "parts/appendix.typ"
#let data = yaml("./template.yml")

#let biblio = bibliography("my-biblio.bib",
  title: none
  )

#show: unilim-thesis-template.with(
  data,
  epigra,
  acknow,
  intro,
  my-content,
  conclusion,
  biblio,
  glossary,
  appendix
)
