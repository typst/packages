// One Simple Rounded Text Box — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 8cm, margin: 0.35cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #simple-rounded-text-box(
    title: [فكرة واضحة],
    body: [نص موجز يشرح الفكرة ويدعمها بتفاصيل عملية، في مساحة مرتبة يسهل قراءتها وتخصيصها.],
    icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
    print-icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
    width: 7.8cm,
    height: 5.2cm,
    direction: rtl,
    header-colour: rgb("#F2BB45"),
    panel-colour: rgb("#082C40"),
    title-colour: rgb("#141414"),
    text-colour: rgb("#E7EEF2"),
  )
]
