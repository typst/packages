#import "/lib.typ": *
#import "/pages/_preview.typ": titre, sample

#set page(width: 17.5cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)

= calloutbox — speech bubble + tail

#titre[1. English]
#calloutbox(title: [Tip], tail: "sw", sample("callout"))

#titre[2. Arabic]
#[
  #set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
  #calloutbox(title: [تنبيه], tail: "start", sample("callout", ar: true))
]

#titre[3. `tail`]
#grid(columns: (1fr, 1fr), column-gutter: 0.5cm, row-gutter: 0.55cm,
  calloutbox(tail: "sw")[tail: sw],
  calloutbox(tail: "se")[tail: se],
  calloutbox(tail: "nw")[tail: nw],
  calloutbox(tail: "ne")[tail: ne],
)
