#import "@preview/bookcls:0.1.0": *
// #import "../src/book.typ": *

#let committee = (
  (
    name: "Hari Seldon",
    position: "Full Professor",
    affiliation: "Streeling university",
    role: "President",
  ),
  (
    name: "Gal Dornick",
    position: "Associate Professor",
    affiliation: "Synnax University",
    role: "Reviewer"
  ),
  (
    name: "Ford Prefect",
    position: "Associate Professor",
    affiliation: "Beltegeuse University",
    role: "Examiner"
  ),
  (
    name: "Paul Atreides",
    position: "Associate Professor",
    affiliation: "Caladan University",
    role: "Examiner"
  ),
)


#let config-colors = (
  primary: blue,
  secondary: blue.lighten(70%),
  header: blue.lighten(50%),
)

#show: book.with(
  author: "Author Name",
  book-config: (
    fonts: (
      body: "Lato",
      math: "Lete Sans Math"
    ),
    theme: "modern",
    lang: "en",
    // colors: config-colors,
    title-page: book-title-page(
      series: "Typst book series",
      institution: "Typst community",
      logo: image("images/typst-logo.svg"),
      cover: image("images/book-cover.jpg", width: 45%)
    )
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

// #bibliography("bibliography/sample.yml")
#bibliography("bibliography/sample.bib")

#part("Second part")

#show: appendix

#include "appendix/app_main.typ"

#back-cover(resume: lorem(100), abstract: lorem(100), logo: (align(left)[#image("images/typst-logo.svg", width: 50%)], align(right)[#image("images/typst-logo.svg", width: 50%)]))