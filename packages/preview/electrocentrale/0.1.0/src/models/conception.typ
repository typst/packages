// Modèle 3 : Document de Conception pour l'ECE Paris

#import "../theme.typ": *
#import "../utils.typ": *
#import "../i18n.typ": *
#import "../base.typ": *

// Page de garde spécifique au Document de Conception
#let conception-cover(ctx) = {
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
    v(0.8cm)
    pad(x: -0.5cm)[
      #rect(
        fill: verylightgray,
        stroke: none,
        width: 100%,
        inset: (x: 20pt, y: 14pt),
        radius: 4pt,
      )[
        #set par(justify: true, leading: 0.65em)
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

// Modèle de document de conception
#let conception(..args) = {
  base-report(
    dict: i18n-conception,
    cover-image: none,
    table-of-contents: true,
    numbering-format: "1.1",
    heading-sizes: (16pt, 14pt, 12pt),
    cover: conception-cover,
    ..args,
  )
}

#let document-conception = conception
#let dossier-conception = conception
