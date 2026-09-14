// ===========================================================================
//  ringbox — dedicated preview page
//
//    typst compile pages/ringbox.typ pages/ringbox.pdf --root . --font-path fonts
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

= ringbox — binder rings on the leading edge

#titre[1. the default pad, in English]

#ringbox[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{notebook}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same pad, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #ringbox[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{notebook}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `rings` — auto, few, many]

#ringbox(rings: 3)[`rings: 3`]
#v(0.45em)
#ringbox()[`rings: auto` — packed to the height]
#v(0.45em)
#ringbox(rings: 10)[`rings: 10`]

#titre[4. `colour` / `fill`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  ringbox(colour: rgb("#1565C0"), fill: rgb("#E3F2FD"))[Blue rings.],
  ringbox(colour: rgb("#C62828"), fill: rgb("#FFEBEE"))[Red rings.],
)

#titre[5. `frame` — outer rule around the pad]

#ringbox(frame: true)[`frame: true` — same colour as the rings]
#v(0.45em)
#ringbox(frame: true, colour: rgb("#1565C0"), fill: rgb("#E3F2FD"),
  frame-weight: 1.2pt)[Blue rings and a matching frame.]
#v(0.45em)
#ringbox(frame: 1.1pt + rgb("#4A148C"), colour: rgb("#6A1B9A"),
  fill: rgb("#F3E5F5"))[`frame: 1.1pt + purple` — a custom stroke.]
