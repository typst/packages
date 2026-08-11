#import "@preview/simple-unimi-thesis:0.1.0": *

#show: project.with(
  printedtitle: {
    let typst = {
      set text(
        size: 1.05em,
        weight: "bold",
        fill: rgb("#239dad"),
      )
      box({
        text("t")
        text("y")
        h(0.035em)
        text("p")
        h(-0.025em)
        text("s")
        h(-0.015em)
        text("t")
      })
    }
    [Un template realizzato \ con #typst]
  },
  language: "it",
)

#show: frontmatter

#include "sections/dedica.typ"

#show: acknowledgements

#include "sections/ringraziamenti.typ"

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

#bibliography(full: true, "bibliografia.bib")

#closingpage("adaptlab")
