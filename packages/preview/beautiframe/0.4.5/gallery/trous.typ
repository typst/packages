#import "@preview/beautiframe:0.4.5": *

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[Trous — Student and Instructor Builds]]

#v(0.5em)

#preset-french-math()
#beautiframe-setup(style: "cours")
#beautiframe-reset-french-math()

// ── Student build ───────────────────────────────────────────────────────────
*Student build* (`instructor-mode: false`) — the content is reserved as space:

#trou(hint: [un contre-exemple])[La fonction de Dirichlet.]

#trou(fill: "lines", height: 3cm)[
  On pose $u_n = 1/n$. La suite décroît vers $0$ sans jamais l'atteindre.
]

Une fonction #trou-inline[continue] sur $[a; b]$ y atteint ses bornes.

#v(0.6em)

// ── Instructor build ────────────────────────────────────────────────────────
#beautiframe-setup(instructor-mode: true)

*Instructor build* (`instructor-mode: true`) — same source, content printed:

#trou(hint: [un contre-exemple])[La fonction de Dirichlet.]

#trou(fill: "lines", height: 3cm)[
  On pose $u_n = 1/n$. La suite décroît vers $0$ sans jamais l'atteindre.
]

Une fonction #trou-inline[continue] sur $[a; b]$ y atteint ses bornes.

#beautiframe-setup(instructor-mode: false)

#v(0.6em)

// ── Inside an environment ───────────────────────────────────────────────────
*Inside an environment*, the trou drops the label column since it is taken:

#exemple(name: "Suite convergente")[
  Donner une suite qui converge vers $0$ sans jamais l'atteindre.
  #trou(fill: "lines", height: 2.4cm)[$u_n = 1/n$ pour $n >= 1$.]
]

// ── Dot grid ────────────────────────────────────────────────────────────────
*Dot grid* (`fill: "grid"`):

#trou(fill: "grid", height: 3cm, hint: [esquisse du graphe])[
  Une parabole tournée vers le bas, de sommet $(0; 4)$.
]
