#import "metadata.typ": title, author, lang, document-type, city, date, organisation
#import "@preview/optimal-ovgu-thesis:0.1.0": oot-expose

#oot-expose(
  title: title,
  author: author,
  lang: lang,
  document-type: document-type,
  city: city,
  date: date,
  organisation: [],
)[
  #include "chapter/01-Einleitung.typ"

  #pagebreak()
  #text(weight: "semibold", "Bibliography")
  #bibliography("thesis.bib")
]