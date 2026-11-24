#import "@preview/simple-unimi-thesis:0.2.0": *
#import "@preview/zebraw:0.6.3": *

#show: zebraw
#let typst = {
  set text(
    size: 1.05em,
    weight: "bold",
    fill: rgb("#239dad"),
  )
  box({
    text("T")
    text("y")
    h(0.035em)
    text("p")
    h(-0.025em)
    text("s")
    h(-0.015em)
    text("t")
  })
}
#show "typst": typst
#show "Typst": typst

#show: unimi-thesis.with(
  title: {
    [Un template realizzato con Typst]
  },
  language: "it",
)

#show: frontmatter

#toc

#show: mainmatter

#include "sections/1_introduzione.typ"
#include "sections/2_stato_dellarte.typ"
#include "sections/3_tecnologie.typ"
#include "sections/4_nome.typ"
#include "sections/5_test.typ"
#include "sections/6_conclusioni.typ"

#show: appendix

#include "sections/A1_tirocinio.typ"
#include "sections/A2_documenti.typ"

#show: backmatter

#bibliography(full: true, "bibliography.bib")

#closingpage(..laboratories.adaptlab)
