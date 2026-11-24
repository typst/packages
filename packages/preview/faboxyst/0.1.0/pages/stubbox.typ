#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= stubbox — ticket stub + perforation

#titre[1. English]
#stubbox(stub: [N° 12], sample("stub"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #stubbox(stub: [رقم 12], stub-width: 1.55cm, sample("stub", ar: true))
]

#titre[3. `stub-width` / `dot` / `dots`]

#stubbox(stub: [N° 7], stub-width: 1.05cm, dot: 0.7pt)[
  `stub-width: 1.05cm`, `dot: 0.7pt`
]
#v(0.4em)
#stubbox(stub: [N° 7], dots: 5)[`dots: 5`]
#v(0.4em)
#stubbox(stub: [N° 7], dots: 11, dot: 1.1pt)[
  `dots: 11`, `dot: 1.1pt` — the default
]
#v(0.4em)
#stubbox(stub: [N° 7], stub-width: 1.85cm, dots: 18, dot: 2.2pt)[
  `dots: 18`, `dot: 2.2pt`
]

#titre[4. `colour`]
#grid(columns: (1fr, 1fr), column-gutter: 0.45cm,
  stubbox(stub: [VIP], colour: rgb("#6A1B9A"),
    fill: rgb("#F3E5F5"))[A purple stub.],
  stubbox(stub: [A], colour: rgb("#2E7D32"), stub-width: 1.0cm)[A slim stub.],
)
