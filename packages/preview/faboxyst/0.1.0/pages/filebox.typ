#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= filebox — folder tabs

#titre[1. English]
#filebox(tabs: ([Notes], [Ex], [Def]), active: 1, sample("file"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #filebox(tabs: ([ملاحظات], [مثال], [تعريف]), active: 1,
    sample("file", ar: true))
]

#titre[3. `active` / colours]
#filebox(tabs: ([A], [B], [C], [D]), active: 0)[First tab.]
#v(0.4em)
#filebox(tabs: ([Sea], [Sand]), active: 1,
  colour: rgb("#1565C0"), active-fill: rgb("#BBDEFB"),
  idle-fill: rgb("#90CAF9"), fill: rgb("#E3F2FD"),
  title-colour: rgb("#0D47A1"))[Second tab, cool wash.]
