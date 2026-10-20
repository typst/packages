// ===========================================================================
//  keybox — dedicated preview page
//
//    typst compile pages/keybox.typ pages/keybox.pdf --root . --font-path fonts
// ===========================================================================

#import "/lib.typ": *

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.65em)

#let titre(t) = block(above: 0.95em, below: 0.4em,
  text(size: 8pt, style: "italic", fill: rgb("#666"), t))

#let badge(n, fill: rgb("#1A3580")) = box(
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

= keybox — Greek-key corners + inset band

#titre[1. the default plate, in English]

#keybox[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{frame}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #keybox[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{frame}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `sz` — size of the key]

#keybox(sz: 8pt)[`sz: 8pt`]
#v(0.45em)
#keybox(sz: 10pt)[`sz: 10pt` — the default]
#v(0.45em)
#keybox(sz: 14pt)[`sz: 14pt`]

#titre[4. `colour` / `frame` / `fill`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  keybox(colour: rgb("#B71C1C"), frame: rgb("#4A148C"),
    fill: rgb("#FFF8E1"))[A warm wash.],
  keybox(colour: rgb("#004D40"), frame: rgb("#1B5E20"),
    fill: rgb("#E8F5E9"))[A green wash.],
)
