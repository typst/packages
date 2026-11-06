// install from typst univers
#import "@preview/minimal-unilim-thesis:0.1.0":*

// install in local version
// #import "@local/minimal-unilim-thesis:0.1.0":*

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
#let path_biblio = "init-material/my-biblio.bib"
#let data = yaml("./template.yml")


#show: unilim-thesis-template.with(
  data,
  epigra,
  acknow,
  intro,
  my-content,
  conclusion,
  path_biblio,
  glossary,
  appendix
)
