// gallery/cover.typ — the cover image: sprig's own syntax, as a sprig map.
//
// The obvious thing to draw for a mind-map package, and a genuine test of
// it: eleven branches, every one of them a real parameter, and the hub
// carries the call itself. If the diagram is readable, the package works.
#import "@preview/sprig:0.1.0": *

#set page(width: 30cm, height: auto, margin: 1.1cm, fill: rgb("#F7F5F0"))
#set text(font: ("New Computer Modern",), size: 8.5pt, fill: rgb("#22201E"))
#set par(justify: false, leading: 0.68em)

#let k(t) = text(font: "DejaVu Sans Mono", size: 0.88em, weight: "bold", t)
// NOT `v`: that is Typst's vertical-space function, and shadowing it makes
// every `#v(0.4cm)` below fail with "expected content, found length".
#let o(t) = text(font: "DejaVu Sans Mono", size: 0.82em,
  fill: rgb("#555"), t)

#align(center, mindmap(
  {
    set text(font: "DejaVu Sans Mono", size: 0.94em)
    text(size: 1.15em, weight: "bold")[#sym.hash mindmap(] + linebreak()
    text(size: 0.86em)[hub, ..branches,] + linebreak()
    text(size: 0.86em)[key: value, …] + linebreak()
    text(size: 1.15em, weight: "bold")[)]
  },
  hub-shape: "rounded", hub-ratio: 1.15, radius: 2.5,
  leaf-width: 5.4, weight: 1.1pt, palette: "poster", wave: 0.05,

  branch(title: k[sides], at: "north")[
    #o[auto] · un côté par branche — la règle \
    #o[3 … n] · un nombre imposé
  ],
  branch(title: k[hub-shape])[
    #o["box"] #o["rounded"] #o["circle"] \
    #o["ellipse"] · #o[n] · #o[(r, ph) => pts] \
    avec #k[hub-ratio] pour la proportion
  ],
  branch(title: k[shape])[
    #o["round"] #o["sharp"] #o["pill"] #o["tag"] \
    #o["shield"] #o["cloud"] #o["banner"] #o["wave"] \
    ou #o[(w, h, r) => pts]
  ],
  branch(title: k[palette])[
    #o["poster"] #o["warm"] #o["cool"] \
    #o["pastel"] #o["ink"] #o["mono"] \
    ou #o[(rouge, bleu, …)]
  ],
  branch(title: k[theme])[
    #o[auto] · en couleur \
    #o["print"] · aucun fond, pour le papier
  ],
  branch(title: k[weight] + [ · ] + k[tint])[
    #o[0pt … 3pt] · l'épaisseur du filet \
    #o[0% … 100%] · l'éclaircissement du fond \
    #k[leaf-fill] #k[leaf-ink] · en absolu
  ],
  branch(title: k[hub-fill] + [ · ] + k[hub-ink] + [ · ] + k[hub-text])[
    une couleur, ou #o["palette"] \
    le texte suit la luminance du fond
  ],
  branch(title: k[stalk] + [ · ] + k[wave])[
    #o[0.34] #o[0.11] · racine et pointe \
    #o[0.045] #o[1.6] · l'ondulation \
    #k[bend] · la cambrure
  ],
  branch(title: k[start] + [ · ] + k[spread] + [ · ] + k[dir])[
    #o[90deg] · la première branche \
    #o[360deg] · l'arc partagé \
    #o[ltr] #o[rtl] #o[auto] · le sens
  ],
  branch(title: k[rough] + [ · ] + k[roughness])[
    #o[true] · le tracé tremble \
    #o[0.5 … 2.5] · son intensité \
    #k[hand] #k[bowing] · le moteur
  ],
  branch(title: k[branch(..)], at: "north-east", children-at: "north",
    spread: 120deg, child-dist: 3.4, child-width: 3.0, children: (
    branch[#k[at] #o["se"] #o["ouest"]],
    branch[#k[dist] #k[dx] #k[dy]],
    branch[#k[children]],
  ))[
    #k[title] #k[colour] #k[shape] #k[width] \
    #k[angle] · et les trois ci-dessous
  ],
))

#v(0.4cm)
#align(center, text(size: 9.5pt, style: "italic", fill: rgb("#6B6259"))[
  #text(font: "DejaVu Sans Mono", weight: "bold")[sprig] — la carte de sa
  propre syntaxe, dessinée par lui-même.
])
