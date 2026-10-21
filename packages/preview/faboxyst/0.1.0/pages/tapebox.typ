#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= tapebox — washi tape across the top

#titre[1. English]
#tapebox(title: [Note], sample("tape"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #tapebox(title: [ملاحظة], sample("tape", ar: true))
]

#titre[3. `pattern` / `colour`]
#tapebox(title: [Gingham], pattern: "gingham",
  colour: rgb("#E07A5F"), tape-b: rgb("#F2CC8F"))[A checked strip.]
#v(0.55em)
#tapebox(title: [Mint], colour: rgb("#81C784"), tilt: 1.4deg)[A mint strip.]
