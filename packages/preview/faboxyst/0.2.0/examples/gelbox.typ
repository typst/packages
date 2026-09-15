// faboxyst — gelbox: glossy aqua buttons after the I-Prof menu,
// plus fabox's new creusé / bombé reliefs.
#import "@preview/faboxyst:0.2.0": *

#set page(width: 9cm, height: 15cm, margin: 1cm, fill: rgb("#7B87F0"))
#set text(size: 10pt)

#align(center)[#gelbox(base: rgb("#17B598"), ball-x: 12%)[Votre Dossier]]

#v(0.9cm)

#align(center)[#gelbox(ball-x: 42%)[Vos Perspectives]]

#v(0.7cm)

#align(center)[#gelbox(ball-x: 55%)[Votre CV]]

#v(0.7cm)

#align(center)[#gelbox(ball-x: 70%)[Les Services]]

#v(0.7cm)

#align(center)[#gelbox(ball-x: 86%)[Les Guides]]

#v(0.8cm)

#align(center)[#text(fill: white, style: "italic", size: 8pt)[© I-Prof V4]]

#pagebreak()

#set page(fill: white)

#insetbox[
  Cette boîte a une ombre interne : le rendu « inset » de shadowed —
  un liseré sombre doux et symétrique, coins compris.
]

#v(0.4cm)

#insetbox(blur: 10pt, strength: 0.8)[
  La profondeur se règle : `blur` élargit le liseré, `strength` son
  opacité — ici une boîte nettement plus creuse.
]

#v(0.5cm)

#fabox(title: [Creusé], shadow: "creuse", colour: rgb("#4a7dbf"))[
  Une boîte creusée : l'ombre interne uniforme taille la surface dans
  la page.
]

#fabox(title: [Bombé], shadow: "bombe", colour: rgb("#bf8a4a"))[
  Une boîte bombée : liseré sombre en haut, reflet clair et fin en
  bas, ombre portée discrète — elle saillit du papier.
]
