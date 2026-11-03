// ===========================================================================
//  punchbox — dedicated preview page
//
//    typst compile pages/punchbox.typ pages/punchbox.pdf --root . --font-path fonts
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

= punchbox — punched bar + title tab + side rules

#titre[1. the source plate, in English]

#punchbox(title: [Example], number: [1])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith22}")
    ])
  #v(0.32em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.16em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #punchbox(title: [مثال], number: [1])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith22}"))
      ])
    #v(0.32em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.16em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `title` / `number` / `shadow`]

#punchbox(title: [Note], number: [2])[Tab, badge, holes and shadow.]
#v(0.45em)
#punchbox(title: [Plain])[No number badge.]
#v(0.45em)
#punchbox(shadow: false)[No title, no badge, no shadow — just the punched bar.]

#titre[4. `colour` / `badge-fill` / `side` / `bar`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  punchbox(title: [Sea], number: [3], colour: rgb("#00695C"),
    badge-fill: rgb("#00838F"), side: rgb("#26A69A"))[A teal family.],
  punchbox(title: [Night], number: [4], colour: rgb("#1A237E"),
    badge-fill: rgb("#F9A825"), bar: rgb("#212121"),
    side: rgb("#5C6BC0"))[A night family.],
)

#titre[5. `holes`]

#punchbox(title: [Few], number: [5], holes: 4)[`holes: 4`]
#v(0.4em)
#punchbox(title: [Auto], number: [6])[`holes: auto`]
