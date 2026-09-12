#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= chalkbox — green slate, eraser + chalks

#titre[1. English]
#chalkbox(title: [Lemma])[
  #text(fill: rgb("#A9CEEC"), weight: "bold")[Example] #h(0.2em)
  #text(fill: rgb("#F1F1F1"), raw("begin{chalk}"))
  #v(0.25em)
  #text(fill: rgb("#FAD43A"))[First case]
  #v(0.12em)
  #text(fill: rgb("#A9CEEC"))[Second case]
]

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #chalkbox(title: [مبرهنة])[
    #text(fill: rgb("#A9CEEC"), weight: "bold")[مثال] #h(0.2em)
    #text(fill: rgb("#F1F1F1"), dir: ltr, raw("begin{chalk}"))
    #v(0.25em)
    #text(fill: rgb("#FAD43A"))[الحالة الأولى]
    #v(0.12em)
    #text(fill: rgb("#A9CEEC"))[الحالة الثانية]
  ]
]

#titre[3. `border` / `grid-step` / `tray`]
#chalkbox(title: [Thin], border: 0.10cm, grid-step: 0.50cm)[
  `border: 0.10cm`, `grid-step: 0.50cm`
]
#v(0.4em)
#chalkbox(title: [Thick], border: 0.26cm, grid-step: 0.20cm)[
  `border: 0.26cm`, `grid-step: 0.20cm`
]
#v(0.4em)
#chalkbox(title: [Bare], grid: false, tray: false)[No grid, no tray.]
