#import "@preview/modern-tongji-thesis:0.2.0": *
#import "chapters/metadata.typ": *
#import "chapters/00_abstract.typ": *

#set pagebreak(weak: true)

#let field = "science"
#let fontset = "fandol"
#let bib-path = "ref.bib"
#let twoside = false

#show: thesis.with(
  school: school, major: major, id: id, student: student, advisor: advisor,
  title: title, subtitle: subtitle, title-english: title-english, subtitle-english: subtitle-english,
  date: date, abstract: abstract, keywords: keywords,
  abstract-english: abstract-english, keywords-english: keywords-english,
  infotype: infotype, infoabstract: infoabstract,
  infodrawings: infodrawings, infowordcount: infowordcount,
  infothesiswords: infothesiswords, infomaterials: infomaterials,
  abstract-title: abstract-title, abstract-subtitle: abstract-subtitle,
  abstract-title-english: abstract-title-english, abstract-subtitle-english: abstract-subtitle-english,
  field: field, fontset: fontset, bib-content: read(bib-path), twoside: twoside,
)

#include "chapters/01_intro.typ"
#newpage(twoside: twoside)

#include "chapters/02_math.typ"
#newpage(twoside: twoside)

#include "chapters/03_reference.typ"
#newpage(twoside: twoside)

#include "chapters/04_figure.typ"
#newpage(twoside: twoside)

#include "chapters/05_conclusion.typ"
#newpage(twoside: twoside)

#makereferences()
#newpage(twoside: twoside)

#appendix(humanities: field == "humanities")[
  #include "chapters/appendix.typ"
]
#newpage(twoside: twoside)

#include "chapters/acknowledgments.typ"
