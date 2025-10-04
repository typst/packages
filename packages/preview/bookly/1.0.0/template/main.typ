#import "@preview/bookly:1.0.0": *
// #import "../src/bookly.typ": *
// #import "custom-theme.typ": *

#let config-colors = (
  primary: rgb("#1d90d0"),
  secondary: rgb("#dddddd").darken(15%)
)

#show: bookly.with(
  author: "Author Name",
  lang: "en",
  // colors: config-colors,
  title-page: book-title-page(
    series: "Typst book series",
    institution: "Typst community",
    logo: image("images/typst-logo.svg"),
    cover: image("images/book-cover.jpg", width: 45%)
  )
)

#show: front-matter

#include "front_matter/front_main.typ"

#show: main-matter

#tableofcontents

#listoffigures

#listoftables

#part("First part")

#include "chapters/ch_main.typ"

#part("Second part")

#show: appendix

#include "appendix/app_main.typ"

// #bibliography("bibliography/sample.yml")
#bibliography("bibliography/sample.bib")


#back-cover(resume: lorem(100), abstract: lorem(100), logo: (align(left)[#image("images/typst-logo.svg", width: 50%)], align(right)[#image("images/typst-logo.svg", width: 50%)]))
