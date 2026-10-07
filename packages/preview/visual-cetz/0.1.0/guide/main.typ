#import "tpl.typ": *
#show: conf

// --- Page de titre, sans en-tête ni pied ---
#page(header: none, footer: none, margin: (x: 2cm, y: 2cm))[

#align(center)[
  #v(1.2cm)
  #text(size: 30pt, weight: "bold", fill: acc)[Visual CeTZ]
  #v(-6pt)
  #text(size: 15pt)[Guide visuel de #raw("cetz:0.5.2") pour Typst 0.15.1]
  #v(4pt)
  #text(size: 12pt)[#emoji.hand.write FERGOUS Abdelhak]
  #v(6pt)
  #text(size: 10pt, fill: rgb("#555"))[
    Chaque construction est montrée par son code et son rendu, côte à côte. \
    Dans l'esprit de #link("https://ctan.org/pkg/visualtikz")[VisualTikZ] pour TikZ.
  ]
  #v(10pt)
  #block(width: 80%, inset: 8pt, stroke: 0.5pt + bd, radius: 4pt, fill: bg,
    align(left, text(size: 9pt)[
      *Comment lire ce guide.* Le code de gauche est exactement le contenu d'un
      `cetz.canvas({ ... })` après `import cetz.draw: *`. Le rendu de droite en est
      la sortie réelle, compilée avec CeTZ 0.5.2. Les exemples sont autonomes~:
      copiez-collez, ça marche.
    ]))
]

#v(1fr)
#align(center, cetz.canvas(length: 1cm, {
  import cetz.draw: *
  set-style(stroke: (thickness: .8pt))

  // grille de fond
  grid((-1, -3.2), (9, 3.2), stroke: rgb("#e6ebf1") + .4pt)

  // axes
  line((-1, 0), (9, 0), stroke: rgb("#b9c2cc") + .5pt, mark: (end: ">"))
  line((0, -3.2), (0, 3.2), stroke: rgb("#b9c2cc") + .5pt, mark: (end: ">"))

  // courbe de hobby
  hobby((0, .4), (2, 2.2), (4, -.6), (6, 1.8), (8, .2),
    stroke: rgb("#1f6feb") + 1.4pt, mark: (end: ">"))

  // formes échantillons
  circle((1.4, -1.8), radius: .7, fill: rgb("#ffd9c2"), stroke: rgb("#c2410c"))
  rect((2.9, -2.5), (4.3, -1.1), radius: .25,
    fill: rgb("#cfe4ff"), stroke: rgb("#1f6feb"))
  n-star((5.6, -1.8), 5, radius: .8, inner-radius: 45%,
    fill: rgb("#fff0a8"), stroke: rgb("#b58900"))
  arc((7.6, -1.8), start: 20deg, stop: 160deg, radius: .85, mode: "PIE",
    anchor: "origin", fill: rgb("#c8ead6"), stroke: rgb("#128a4d"))
}))
#v(1fr)
]

#[
  #set heading(numbering: none)
  #outline(depth: 2, indent: 1em, title: [Table des matières])
]

#include "ch01.typ"
#include "ch02.typ"
#include "ch03.typ"
#include "ch04.typ"
#include "ch05.typ"
#include "ch06.typ"
#include "ch07.typ"
#include "ch08.typ"
#include "ch10.typ"
#include "ch11.typ"
#include "ch12.typ"
#include "ch13.typ"
#include "ch14.typ"
#include "ch15.typ"
#include "ch16.typ"
#include "ch09.typ"
