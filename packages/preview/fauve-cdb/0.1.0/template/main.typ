#import "@preview/fauve-cdb:0.1.0": matisse-thesis

#let jury-content = [
  #text(size: 1.3em)[*Rapporteurs avant soutenance :*]
  #v(-1em)
  #table(
    columns: 2,
    column-gutter: 1.5em,
    stroke: 0pt,
    inset: (x: 0pt, y: .2em),
    "Isaac Newton", "M.Sc. -- Oxford",
    "René Descartes", "Professeur des Universités -- Univ. Rennes",
  )

  #text(size: 1.3em)[*Composition du jury :*]
  #v(-1em)
  #table(
    columns: 3,
    column-gutter: 2em,
    stroke: 0pt,
    inset: (x: 0pt, y: .2em),
    "Président :", "Marie Curie", "Joueuse de fléchettes -- UCLA",
    "Examinateurs :", "Archimède", "Expert comptable -------- Durand & Durant",
    "", "Elizabeth II", "BEP sabotier -- à son compte",
    "Dir. de thèse :", "Alan Turing", "Eleveur d'huîtres -- CNRS",
    "Co-dir. de thèse :", "Mère Teresa", "Manutentionnaire -- Total",
  )

  #text(size: 1.3em)[*Invité(s) :*]
  #v(-1em)
  #table(
    columns: 2,
    column-gutter: 1.5em,
    stroke: 0pt,
    inset: (x: 0pt, y: .2em),
    "Jean-René", "Au chômage",
  )
]

#show: matisse-thesis.with(
  author: "Leonardo da Vinci",
  affiliation: "IRISA (UMR 6074)",
  jury-content: jury-content,
  acknowledgements: [

  ],
  defense-place: "Rennes",
  defense-date: "23 octobre 2024",
  draft: true,
  // french info
  title-fr: "La quadrature du cercle. Parfois nous, les scientifiques, avons tendance à faire des titres très longs. Trop long. Absolument !",
  keywords-fr: lorem(12),
  abstract-fr: lorem(80),
  // english info
  title-en: "Squaring the circle.",
  keywords-en: lorem(12),
  abstract-en: lorem(60),
)

#heading(numbering: none, outlined: false)[Remerciements]

J'aimerais remercier Jean-René.

#pagebreak()

// table of contents
#outline(indent: auto)

#pagebreak()


= Introduction

== Le couscous

buenos dias #footnote[Bonjour in French]

#lorem(1500)

#pagebreak()

= La sauce de soja

#smallcaps[Hello World]

#lorem(1500)
