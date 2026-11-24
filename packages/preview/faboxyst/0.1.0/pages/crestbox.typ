// ===========================================================================
//  crestbox — dedicated preview page
//
//    typst compile pages/crestbox.typ pages/crestbox.pdf --root . --font-path fonts
// ===========================================================================

#import "/lib.typ": *

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.65em)

#let titre(t) = block(above: 0.95em, below: 0.4em,
  text(size: 8pt, style: "italic", fill: rgb("#666"), t))

#let badge(n, fill: rgb("#1B3A8C")) = box(
  width: 0.52cm, height: 0.52cm,
  fill: fill, radius: 50%,
  align(center + horizon,
    text(fill: white, weight: "bold", size: 0.85em, dir: ltr, n)))

#let chip(fill, body) = grid(
  columns: (auto, 1fr), column-gutter: 0.22cm, align: (horizon, horizon),
  box(width: 0.36cm, height: 0.36cm, fill: fill, radius: 0.05cm,
    stroke: 0.6pt + fill.darken(25%)),
  body,
)

= crestbox — double frame + crest

#titre[1. the source plate, in English]

#crestbox(title: [Example])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1B3A8C"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith04}")
    ])
  #v(0.35em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.18em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #crestbox(title: [مثال])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1B3A8C"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith04}"))
      ])
    #v(0.35em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.18em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `title:` / `flourish:` — the crest on the top rule]

#crestbox(title: [Theorem])[A crest with the default palmettes.]
#v(0.35em)
#crestbox(title: [Lemma], flourish: false)[The same, without the curls.]
#v(0.35em)
#crestbox[No crest — just the notched frame.]

#titre[4. `colour`, `outer`, `fill` — the two strokes and the wash]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm, row-gutter: 0.4cm,
  crestbox(title: [Note], colour: rgb("#1565C0"), fill: rgb("#E3F2FD"),
    title-colour: rgb("#0D47A1"))[A cool wash.],
  crestbox(title: [Warn], colour: rgb("#C62828"), outer: rgb("#4E0000"),
    fill: rgb("#FFECB3"), title-colour: rgb("#B71C1C"))[A warm wash.],
)

#titre[5. `cut` / `pair` — chamfer, and the two inner strokes]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  crestbox(title: [Small], cut: 0.14cm)[A shallow chamfer.],
  crestbox(title: [Large], cut: 0.48cm)[A deep chamfer.],
)

#v(0.35em)
#crestbox(title: [Pair], pair: 0.22cm, weight: 1.1pt)[
  `pair: 0.22cm` — the two inner strokes are far apart on purpose.
]

#titre[6. `plate` — the beige preset]

#plate[The default textbook plate, ready to drop in.]
