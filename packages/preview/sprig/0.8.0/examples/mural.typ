// Sprig 0.8.0 — le tableau. Une carte `mindmap` réglée comme un mur de cartes
// d'un outil de travail collaboratif : des étiquettes sans bordure, un noyau
// en rectangle arrondi, des tuyaux épais et réguliers, une trame pointillée.
#import "@preview/sprig:0.8.0": *

// the trame pointillée d'un tableau : rien d'un logiciel, juste des cercles
// posés sur la page de fond, tous les 6,2 mm
#let dots = {
  for i in range(0, 52) {
    for j in range(0, 26) {
      place(top + left, dx: i * 0.62cm, dy: j * 0.62cm,
        circle(radius: 0.4pt, fill: rgb("#0000000C")))
    }
  }
}

#set page(width: 32cm, height: auto, margin: 1cm, fill: rgb("#FCFBF8"),
  background: dots)
#set text(font: ("New Computer Modern", "DejaVu Sans"), size: 10.5pt)

#align(center)[
  #text(size: 15pt, weight: "bold", fill: rgb("#1F2933"),
    [Sprint 12 — tableau de l'équipe]) \
  #text(size: 9.5pt, fill: rgb("#7B8794"),
    [la carte `mindmap`, réglée en tableau : aucune bordure de feuille, un
     noyau arrondi, des traits pleins et calmes])
]
#v(0.9cm)

// Trois colonnes, et rien d'autre : `layout: "both"` étale les branches de
// part et d'autre du noyau, `hub-shape: "rounded"` lui rend un rectangle
// arrondi, `shape: "none"` laisse les feuilles de dernier rang sans carte.
// Un tuyau régulier, c'est `wave: 0` et `bend: 0`; l'épaisseur ne se discute
// qu'avec `stalk`, et sa pointe avec `stalk-tip`.
#mindmap([*Sprint 12*],
  layout: "both",
  hub-shape: "rounded",
  shape: "round",
  leaf-width: auto,
  min-width: 2.2,
  stalk: 0.55,
  stalk-tip: 0.16,
  bend: 0.0,
  wave: 0.0,
  tint: 96%,
  weight: 0.9pt,
  gap: 0.42,
  shadow: true,
  palette: ("#4C7DF0", "#F0A93B", "#3FB27F", "#E4572E", "#7A5CE0"),
  branch(title: [*À faire*], icon: text(size: 0.9em, "□"), shape: "round",
    children: (
      branch([1,5 j · Nour], title: [Reprendre l'import], width: 4.6),
      branch([2 j · Sami], title: [Écrire la doc], width: 4.6),
      branch([0,5 j · Inès], title: [Cache HTTP], width: 4.6),
    )),
  branch(title: [*En cours*], icon: text(size: 0.9em, "▸"),
    children: (
      branch([3 j · Nour], title: [Analyseur RTL], width: 4.6,
        children: (branch([lexer], shape: "none"),
          branch([tests], shape: "none"))),
      branch([1 j · Sami], title: [Palette 2026], width: 4.6),
    )),
  branch(title: [*Fait*], icon: text(size: 0.9em, "☑"),
    children: (
      branch([rendu, revu], title: [Export PDF/A], width: 4.6, shape: "none"),
      branch([fusionnés], title: [Formats de noeud], width: 4.6, shape: "none"),
      branch([relu], title: [Guide imprimé], width: 4.6, shape: "none"),
    )),
)

#v(0.6cm)
#line(length: 100%, stroke: 0.6pt + rgb("#E4E7EB"))
#v(0.4cm)
// Ce que le réglage par feuille change : `leaf-width: auto` laisse chaque
// carte prendre la largeur de ses mots, et `width:` sur une branche fixe
// celle de cette carte seule — les deux se côtoient sans se gêner.
#mindmap([*Rétro*],
  layout: "right",
  hub-shape: "rounded",
  leaf-width: auto,
  min-width: 1.6,
  stalk: 0.45,
  stalk-tip: 0.14,
  wave: 0.0,
  tint: 97%,
  gap: 0.34,
  palette: ("#3FB27F", "#4C7DF0", "#E4572E"),
  branch(title: [Ce qui a plu], children: (
    branch([la trame, sans bordure]),
    branch([un seul réglage de largeur], width: 6.4),
  )),
  branch(title: [Ce qui a manqué], children: (
    branch([le minuteur]),
    branch([un export en PNG du tableau]),
  )),
  branch(title: [Prochaine fois], children: (
    branch([deux couleurs par colonne]),
  )),
)
