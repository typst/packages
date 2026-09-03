#import "@preview/palimpsest:0.1.0": *

#let my-template(title: none, authors: (), body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  body
}

// `template:` only wraps the manuscript -- the letter uses its own,
// separate `letter-template:` (defaulting to a minimal title-only
// template if not given), so the page setup has to be repeated here too.
#let my-letter-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  default-letter-template(body)
}

#show: revisions.with(
  template: my-template,
  letter-template: my-letter-template,
  exchanges: include "shared/biblio-letter/responses.typ",
)

#include "shared/biblio-letter/manuscript.typ"
