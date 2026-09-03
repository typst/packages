#import "@preview/palimpsest:0.1.0": *

#let my-template(title: none, authors: (), body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  set heading(numbering: "1.")
  align(center, text(size: 1.3em, weight: "bold")[#title])
  v(0.5em)
  body
}

#let my-letter-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  default-letter-template(body)
}

#show: revisions.with(
  template: my-template.with(title: [A Minimal Study]),
  letter-template: my-letter-template,
  exchanges: include "shared/responses.typ",
)

#include "shared/manuscript.typ"
