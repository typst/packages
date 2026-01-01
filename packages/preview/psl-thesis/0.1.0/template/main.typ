#import "helpers.typ": *
#import "@preview/psl-thesis:0.1.0": psl-thesis-covers
#import "@preview/glossarium:0.5.3": make-glossary, register-glossary, print-glossary, gls, glspl
#show: make-glossary

#let glossary = (
  (
    key: "phd",
    short: "PhD",
    long: "philosophiæ doctor",
  ),
)

#register-glossary(glossary)

// Choose between fr and en to set the front cover language.
#set text(lang: "fr", font: "Montserrat", size: 11pt)

// Set chapter style for first level headings.
#set heading(numbering: "1.1")
#counter("chapter").update(0)
#show heading.where(level: 1): it => {
  pagebreak(to: "odd", weak: true)

  if it.numbering != none {
    counter("chapter").step()
    set text(size: 36pt)
    [Chapter]
    h(0.5em)
    text(context counter("chapter").display(), fill: colors.accent, size: 58pt, weight: "bold")
    h(0.5em)
  }

  v(0em)
  text(it.body, size: 36pt, weight: "light")
  v(1em)
}


#show: psl-thesis-covers.with(
  title: [Recherches sur les substances radioactives],
  author: [Marie Skłodowska-Curie],
  date: [le 25 juin 1903],
  doctoral-school: (name: [Faculté des sciences], number: [123]),
  institute: [à la Faculté des Sciences de Paris],
  institute-logo: image("./institute-logo.svg", height: 3.5cm),
  specialty: [Sciences Physiques],
  jury: (
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "President",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "MD, PhD, Affiliation",
      role: "Member",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "PhD supervisor",
    ),
  ),
  abstracts: (fr: lorem(128), en: lorem(128)),
  keywords: (fr: lorem(4), en: lorem(4)),
)

#counter(page).update(1)
#set page(numbering: "i")

#include "content/front/acknowledgments.typ"

// Table of contents and lists
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(title: "Table of contents")

#outline(
  title: "Figures",
  target: figure.where(kind: figure),
)

#outline(
  title: "Tables",
  target: figure.where(kind: table),
)

#heading(level: 1, "Glossary", numbering: none)
#print-glossary(glossary)

#counter(page).update(1)
#set page(numbering: "1")

#include "content/chapters/ch1.typ"
#include "content/back/conclusion.typ"
#include "content/back/publications.typ"

#bibliography(
  "bibliography.bib",
  title: "Bibliography",
  style: "ieee",
)

