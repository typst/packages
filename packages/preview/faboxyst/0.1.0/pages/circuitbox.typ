// ===========================================================================
//  circuitbox — dedicated preview page
//
//    typst compile pages/circuitbox.typ pages/circuitbox.pdf --root . --font-path fonts
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

= circuitbox — double frame + stepped rails

#titre[1. the source plate, in English]

#circuitbox(title: [Example])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith07}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #circuitbox(title: [مثال])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith07}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `title` / `flourish`]

#circuitbox(title: [Note])[Default rails, double stroke, centred title.]
#v(0.45em)
#circuitbox(title: [Plain], flourish: false)[No curls beside the title.]
#v(0.45em)
#circuitbox()[No title — a closed double frame.]

#titre[4. `colour` / `fill`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  circuitbox(title: [Sea], colour: rgb("#0D47A1"),
    fill: rgb("#E3F2FD"))[A cool wash.],
  circuitbox(title: [Rose], colour: rgb("#AD1457"),
    fill: rgb("#FCE4EC"))[A pink wash.],
)

#titre[5. `gap` — space between the two strokes]

#circuitbox(title: [Tight], gap: 0.7pt)[`gap: 0.7pt`]
#v(0.45em)
#circuitbox(title: [Default], gap: 1.55pt)[`gap: 1.55pt` — the default]
#v(0.45em)
#circuitbox(title: [Wide], gap: 3.4pt)[`gap: 3.4pt`]

#titre[6. `step` / `rail` / `weight`]

#circuitbox(title: [Low], step: 0.14cm, rail: 0.9cm)[`step: 0.14cm`]
#v(0.45em)
#circuitbox(title: [Bold], weight: 1.6pt, gap: 2.2pt, step: 0.34cm)[Thicker strokes, wider gap.]
