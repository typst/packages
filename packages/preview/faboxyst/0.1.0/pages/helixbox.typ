// ===========================================================================
//  helixbox — dedicated preview page
//
//    typst compile pages/helixbox.typ pages/helixbox.pdf --root . --font-path fonts
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

= helixbox — helix header + stripe + adjustable shadow

#titre[1. the source plate, in English]

#helixbox(title: [Example])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith02}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #helixbox(title: [مثال])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith02}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `shadow-lift` — how high the card floats]

#helixbox(title: [Flat], shadow: false)[shadow: false]
#v(0.45em)
#helixbox(title: [Low], shadow-lift: 0.02cm, shadow-spread: 0.06cm,
  shadow-opacity: 30%)[`shadow-lift: 0.02cm` — almost sitting]
#v(0.55em)
#helixbox(title: [Default], shadow-lift: 0.08cm)[`shadow-lift: 0.08cm` — the default]
#v(0.65em)
#helixbox(title: [High], shadow-lift: 0.20cm, shadow-spread: 0.24cm,
  shadow-opacity: 48%, shadow-blur: 14)[
  `shadow-lift: 0.20cm` — hovering
]
#v(0.45em)
#helixbox(title: [Blue], shadow-colour: rgb("#1565C0"),
  shadow-opacity: 40%, shadow-lift: 0.12cm)[shadow-colour: blue]

#titre[4. `colour` / `helix-a` / `helix-b` / `stripe`]

#helixbox(title: [Night], colour: rgb("#1A237E"),
  helix-a: rgb("#80DEEA"), helix-b: rgb("#FFF59D"),
  stripe: (rgb("#FF8A65"), rgb("#6A1B9A")))[A different family.]
