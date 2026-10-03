// Modèle 2 : Rapport de Projet pour l'ECE Paris

#import "../theme.typ": *
#import "../utils.typ": *
#import "../i18n.typ": *
#import "../base.typ": *

// Page de garde spécifique au rapport de Projet
#let projet-cover(ctx) = {
  cover-header(ctx)

  align(center)[
    #text(size: 13pt, weight: "bold", fill: rgb("#444444"))[#ctx.type-doc]
    #v(0.6cm)
    #text(size: 22pt, weight: "bold", fill: ece)[#ctx.title]
  ]

  v(0.4cm)
  line(length: 100%, stroke: 1.5pt + black)

  let act_abstract = if ctx.abstract == false or ctx.abstract == "" {
    none
  } else if ctx.abstract != none {
    ctx.abstract
  } else {
    ctx.dict.default_abstract
  }

  if act_abstract != none {
    v(1cm)
    pad(x: -1cm)[
      #rect(
        fill: verylightgray,
        stroke: none,
        width: 100%,
        inset: (x: 24pt, y: 16pt),
        radius: 4pt,
      )[
        #align(left)[
          #text(weight: "bold")[#ctx.dict.abstract_title] -- #act_abstract
        ]
      ]
    ]
  }

  if ctx.cover-image != none {
    v(0.6cm)
    align(center)[
      #_render-cover(ctx.cover-image)
    ]
  }

  cover-footer(ctx)
}

// Modèle de rapport de projet
#let projet(..args) = {
  base-report(
    dict: i18n-projet,
    cover-image: none,
    table-of-contents: true,
    numbering-format: "1.1",
    heading-sizes: (18pt, 14pt, 12pt),
    cover: projet-cover,
    ..args,
  )
}
