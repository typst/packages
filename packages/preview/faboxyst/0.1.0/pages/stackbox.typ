#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= stackbox — offset sheets behind the card

#titre[1. English]
#stackbox(title: [Stack], sample("stack"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #stackbox(title: [كومة], sample("stack", ar: true))
]

#titre[3. `layers` / `offset`]
#stackbox(title: [Two], layers: 2)[Two sheets.]
#v(0.55em)
#stackbox(title: [Four], layers: 4, offset: 0.12cm,
  colour: rgb("#6A1B9A"),
  back: (rgb("#E1BEE7"), rgb("#CE93D8"), rgb("#BA68C8")))[A taller pile.]
