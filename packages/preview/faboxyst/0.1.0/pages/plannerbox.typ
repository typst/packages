#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= plannerbox — punch bar + binder rings

#titre[1. English]
#plannerbox(title: [Week], number: [3], sample("planner"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #plannerbox(title: [الأسبوع], number: [3], sample("planner", ar: true))
]

#titre[3. `rings` / `frame`]
#plannerbox(title: [Few], number: [1], rings: 3)[Three rings.]
#v(0.4em)
#plannerbox(title: [Open], number: [2], frame: false)[No paper frame.]
