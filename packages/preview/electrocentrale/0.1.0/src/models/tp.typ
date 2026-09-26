// Modèle 1 : Rapport de Travaux Pratiques (TP) pour l'ECE Paris

#import "../theme.typ": *
#import "../utils.typ": *
#import "../i18n.typ": *
#import "../base.typ": *

// Page de garde spécifique au rapport de TP (sans encart résumé)
#let tp-cover(ctx) = {
  cover-header(ctx)

  align(center)[
    #text(size: 13pt, weight: "bold", fill: rgb("#444444"))[#ctx.type-doc]
    #v(0.6cm)
    #if ctx.tp-num != "" [
      #text(size: 20pt, weight: "bold", fill: ece)[#ctx.doc-prefix #ctx.tp-num : #ctx.title]
    ] else [
      #text(size: 20pt, weight: "bold", fill: ece)[#ctx.title]
    ]
  ]

  v(0.4cm)
  line(length: 100%, stroke: 1.5pt + black)
  v(0.8cm)

  if ctx.cover-image != none {
    align(center)[
      #_render-cover(ctx.cover-image)
    ]
  }

  cover-footer(ctx)
}

// Modèle de rapport de travaux pratiques
#let tp(..args) = {
  base-report(
    dict: i18n-tp,
    cover-image: auto,
    tp-num: none,
    table-of-contents: false,
    heading-sizes: (18pt, 16pt, 15pt),
    cover: tp-cover,
    ..args,
  )
}
