// ===========================================================================
//  ribbonbox — dedicated preview page
//
//    typst compile pages/ribbonbox.typ pages/ribbonbox.pdf --root . --font-path fonts
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

= ribbonbox — yellow plate + blue band + pink tab

#titre[1. the source plate, in English]

#ribbonbox(title: [Example])[
  #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
    badge[1],
    text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
      Example #h(0.25em) #raw("begin{Sarith03}")
    ])
  #v(0.35em)
  #chip(rgb("#E91E63"), [First case])
  #v(0.18em)
  #chip(rgb("#7CB342"), [Second case])
]

#titre[2. the same plate, in Arabic]

#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #ribbonbox(title: [مثال])[
    #grid(columns: (auto, 1fr), column-gutter: 0.28cm, align: (horizon, horizon),
      badge[1],
      text(fill: rgb("#1A3580"), weight: "bold", size: 1.05em)[
        مثال #h(0.25em) #text(dir: ltr, raw("begin{Sarith03}"))
      ])
    #v(0.35em)
    #chip(rgb("#E91E63"), [الحالة الأولى])
    #v(0.18em)
    #chip(rgb("#7CB342"), [الحالة الثانية])
  ]
]

#titre[3. `title` / `flourish` / `chevron` / `shadow`]

#ribbonbox(title: [Note])[Default tab, chevrons and shadow.]
#v(0.4em)
#ribbonbox(title: [Plain], flourish: false, chevron: false)[No curls, no corner marks.]
#v(0.4em)
#ribbonbox(shadow: false)[No title tab, no shadow.]

#titre[4. `colour` / `fill` / `tab-fill`]

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm,
  ribbonbox(title: [Sea], colour: rgb("#0D47A1"), fill: rgb("#BBDEFB"),
    tab-fill: rgb("#90CAF9"))[A cool wash.],
  ribbonbox(title: [Rose], colour: rgb("#880E4F"), fill: rgb("#FCE4EC"),
    tab-fill: rgb("#F8BBD0"), title-colour: rgb("#4A148C"))[A pink wash.],
)

#titre[5. `band` — thickness of the outer blue frame]

#ribbonbox(title: [Thin], band: 0.08cm)[`band: 0.08cm`]
#v(0.35em)
#ribbonbox(title: [Default], band: 0.20cm)[`band: 0.20cm` — the default]
#v(0.35em)
#ribbonbox(title: [Thick], band: 0.38cm)[`band: 0.38cm`]
