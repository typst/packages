// ===========================================================================
//  swooshbox — dedicated preview page
//
//    typst compile pages/swooshbox.typ pages/swooshbox.pdf --root . --font-path fonts
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

= swooshbox — one sheared blue block + white plate

#titre[1. the source plate, in English]

#swooshbox(title: [Example])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith08}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #swooshbox(title: [مثال])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith08}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `title` / `flourish` / `shadow`]

#swooshbox(title: [Note])[Default tab and sheared block.]
#v(0.45em)
#swooshbox(title: [Plain], flourish: false)[No curls on the tab.]
#v(0.45em)
#swooshbox(shadow: false)[No title tab, no shadow.]

#titre[4. `colour` / `tab-fill` / `fill`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  swooshbox(title: [Sea], colour: rgb("#0D47A1"),
    tab-fill: rgb("#00838F"))[A deep wash.],
  swooshbox(title: [Rose], colour: rgb("#C2185B"),
    tab-fill: rgb("#AD1457"), fill: rgb("#FFF5F8"))[A pink wash.],
)

#titre[5. `tr` / `br` — each corner offset, y-up `(dx, dy)`]

#swooshbox(title: [Default])[`tr: (10pt, 10pt)`, `br: (-10pt, -10pt)` — the default]
#v(0.5em)
#swooshbox(title: [1 mm], skew: 1mm)[`skew: 1mm`]
#v(0.5em)
#swooshbox(title: [High wing], tr: (6mm, 3mm), br: (-2mm, -4mm))[
  `tr: (6mm, 3mm)` — further right, a little up
]
#v(0.5em)
#swooshbox(title: [Deep lip], tr: (3mm, 2mm), br: (-1mm, -7mm))[
  `br: (-1mm, -7mm)` — almost flush right, deep drop
]
