// Couverture Sprig 0.8.0 — carte de sa syntaxe, dessinée avec le paquet.
// Rebuild with `scripts/build.sh`; the raster is kept for the README and guide.
#import "@preview/sprig:0.8.0": *

#set page(width: auto, height: auto, margin: 1.0cm,
  fill: rgb("#F7F5EF"))
#set text(font: "New Computer Modern", size: 10pt, fill: rgb("#263746"))
#set par(justify: false, leading: 0.62em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.78em)

#let code(s) = raw(s)
#let palettes = (
  rgb("#1972B5"), rgb("#E7892E"), rgb("#78A913"), rgb("#7447AA"),
  rgb("#1A9B9A"), rgb("#D64F8B"), rgb("#DBAA21"), rgb("#57806D"),
  rgb("#4C7DF0"), rgb("#C66743"),
)

#align(center)[
  #mindmap(
    align(center)[
      #text(size: 15pt, weight: "bold", fill: white)[sprig]
      #linebreak()
      #text(size: 7.8pt, fill: rgb("#D8E9FC"))[0.8.0 · cartes adaptatives]
      #linebreak()
      #text(size: 7pt, fill: rgb("#D8E9FC"))[#raw("#mindmap(...)")]
    ],
    hub-ratio: 1.28,
    hub-fill: rgb("#0B3C7A"), hub-ink: rgb("#7FADE0"), hub-text: white,
    palette: palettes, shape: "round", theme: auto,
    leaf-width: auto, min-width: 2.8, max-width: 4.2,
    min-height: 1.25, max-height: 3.2,
    weight: 1.15pt, gap: 0.32, stalk: 0.34, stalk-tip: 0.12,
    bend: 0.035, wave: 0.028, waves: 1.6, tint: 87%,
    start: 90deg, spread: 360deg, shadow: true,

    branch(title: [Six vues])[
      #code("mindmap · mindgrid · blossom")
      #linebreak()
      #code("sticky · tikzmap · buzan")
    ],
    branch(title: [Dimensions])[
      #code("leaf-width: auto") — chaque feuille suit ses mots.
    ],
    branch(title: [Limites])[
      #code("min/max-width") · #code("min/max-height")
    ],
    branch(title: [26 contours])[
      Six nouvelles formes : #code("leaf"), #code("diamond"),
      #code("ticket"), #code("bookmark"), #code("document"),
      #code("parallelogram").
    ],
    branch(title: [Blossom])[
      Le texte se place vers le bord du pétale et suit sa rotation.
    ],
    branch(title: [Buzan + nibart])[
      Trait à pointe variable, avec #code("cloud") pour le moyeu.
    ],
    branch(title: [TikZ-map])[
      Concepts imbriqués · #code("clearance") · #code("sibling-angle").
    ],
    branch(title: [Styles])[
      #code("poster") · #code("print") · #code("rough") · palettes.
    ],
    branch(title: [RTL])[
      #code("dir: rtl") — branches et lecture s’adaptent au sens.
    ],
    branch(title: [Feuilles sûres])[
      Cartes et nuages gardent une zone d’écriture généreuse.
    ],
  )
]

#v(0.35cm)
#align(center)[
  #text(size: 10pt, weight: "bold", fill: rgb("#31465E"))[sprig]
  #text(size: 9pt, style: "italic", fill: rgb("#66717A"))[
    — la carte de sa propre syntaxe, dessinée par lui-même.
  ]
]
