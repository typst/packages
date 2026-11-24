#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= markerbox — whiteboard, eraser + markers

#titre[1. English]
#markerbox(title: [Note], sample("marker"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #markerbox(title: [ملاحظة], sample("marker", ar: true))
]

#titre[3. `border` / `grid-step`]
#markerbox(title: [Thin], border: 0.10cm, grid-step: 0.48cm)[
  `border: 0.10cm`, `grid-step: 0.48cm`
]
#v(0.4em)
#markerbox(title: [Slate], fill: rgb("#263238"), text-fill: rgb("#ECEFF1"),
  title-colour: rgb("#80CBC4"), border: 0.22cm)[A dark board with markers.]
