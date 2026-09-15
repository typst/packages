#import "_helpers.typ": *

#set page(paper: "a4", margin: 1.4cm)
#set text(font: "DejaVu Sans", size: 10pt, lang: "fr")
#set par(justify: true)

#align(center)[
  #v(1.6cm)
  #text(size: 13pt, tracking: 3pt, fill: rgb("#1F3A68"))[FABOXYST 0.2.0]
  #v(0.4cm)
  #text(size: 28pt, weight: "bold")[Showcase complet]
  #v(0.25cm)
  #text(size: 12pt, fill: luma(70))[Syntaxe · paramètres · LTR / RTL · cadres de page]
  #v(0.8cm)
]

#fabox(
  title: [Mode d’emploi de ce document],
  colour: rgb("#1F3A68"),
  badge: [v0.3],
)[
  Chaque commande publique du package a *sa page*. En tête : la signature
  complète. En dessous : *chaque paramètre visuel* est montré au moins deux
  fois (valeur A / valeur B) en *LTR* et *RTL*, pour que le changement
  d’aspect soit lisible. Les bulles de discussion (références jointes) et
  les cadres pleine page ferment le volume.
]

#v(0.6cm)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 10pt,
  fabox(title: [Boxes], colour: rgb("#B03A2E"), width: 100%)[fabox, flag, lace, ornate, scrapbook…],
  fabox(title: [Bulles], colour: rgb("#E67E22"), width: 100%)[callout · speech-bubble · 5W],
  fabox(title: [Pages], colour: rgb("#1E5C4A"), width: 100%)[ornate-pages · book-cover · bound-page],
)

#v(1cm)
#align(center, text(size: 9pt, fill: luma(90))[Typst 0.15.1  ·  package local  ·  2026])
