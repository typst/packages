#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= screwbox — plaque held by corner screws

#titre[1. English — four screws]
#screwbox(sample("screw"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #screwbox(sample("screw", ar: true))
]

#titre[3. `tl` / `tr` / `bl` / `br`]

#screwbox(tl: true, tr: true, bl: false, br: false)[Top pair — `tl` + `tr`.]
#v(0.4em)
#screwbox(tl: false, tr: false, bl: true, br: true)[Bottom pair — `bl` + `br`.]
#v(0.4em)
#screwbox(tl: true, tr: false, bl: false, br: true)[Diagonal — `tl` + `br`.]
#v(0.4em)
#screwbox(tl: true, tr: false, bl: false, br: false)[One screw — `tl` only.]

#titre[4. `angle` — slot tilt]

#screwbox(angle: 0deg)[`angle: 0deg` — the default]
#v(0.35em)
#screwbox(angle: 35deg)[`angle: 35deg` — all four]
#v(0.35em)
#screwbox(tl: 20deg, tr: -20deg, bl: 55deg, br: -55deg)[
  Per corner: `tl: 20deg`, `tr: -20deg`, `bl: 55deg`, `br: -55deg`
]

#titre[5. `colour` / `screw` / `screw-size`]

#grid(columns: (1fr, 1fr), column-gutter: 0.45cm,
  screwbox(colour: rgb("#6D4C41"), fill: rgb("#EFEBE9"),
    screw: rgb("#BCAAA4"))[Brass plate.],
  screwbox(colour: rgb("#1565C0"), fill: rgb("#E3F2FD"),
    screw: rgb("#90CAF9"), screw-size: 0.42cm)[Larger screws.],
)
