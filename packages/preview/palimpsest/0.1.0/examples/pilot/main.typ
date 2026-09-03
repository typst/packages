#import "@preview/palimpsest:0.1.0": *

// Stand-in for a real Universe template — swap this for your journal's
// actual template (arkheion, a two-column class, etc.). The only
// contract `revisions` needs from `template:` is `content -> content`,
// same as anything used with `#show:`.
#let my-template(title: none, authors: (), body) = {
  set page(width: 14cm, height: auto, margin: 1.5cm)
  set text(size: 10pt)
  set heading(numbering: "1.")
  align(center, text(size: 1.6em, weight: "bold")[#title])
  v(0.3em)
  align(center, authors.map(a => a.name).join(", "))
  v(1.5em)
  body
}

#show: revisions.with(
  template: my-template.with(
    title: [Emulating a target trial of early vasopressors],
    authors: ((name: "D. H.", affiliation: "Sorbonne Université"),),
  ),
  exchanges: include "responses.typ",
  round: 1,
)

#include "manuscript.typ"
