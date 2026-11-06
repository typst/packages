#import "@preview/parcio-thesis:0.3.0": *

#show: parcio.with(
  title: "Title", 
  author: (
    name: "Author",
    mail: "author@ovgu.de"
  ),
  abstract: include "chapters/abstract.typ",
  reviewers: ("Prof. Dr. Musterfrau", "Prof. Dr. Mustermann", "Dr. Evil"),
)

#show: roman-numbering.with(reset: false)
#outline(depth: 3)

/* ---- Main matter of your thesis ---- */

#empty-page

// Set arabic numbering and alternate page number position.
#show: arabic-numbering

#include "chapters/introduction/intro.typ"

#include "chapters/background/background.typ"

#include "chapters/eval/eval.typ"

#include "chapters/conclusion/conc.typ"

/* ---- Back matter of your thesis ---- */

#empty-page

#bibliography("bibliography/refs.bib", style: "bibliography/apalike.csl")

#empty-page

#include "appendix.typ"

#empty-page

#include "legal.typ"
