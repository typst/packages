// One Diagonal Banner Card — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9.5cm, margin: 0.3cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #diagonal-banner-card-box(
    title: [فكرة واضحة],
    items: (
      [نقطة أساسية تساعد على فهم الفكرة.],
      [تفصيل موجز يدعم السياق ويوضح الهدف.],
      [خطوة تالية قابلة للتنفيذ والقياس.],
    ),
    number: "٠١",
    icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
    print-icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
    width: 4.8cm,
    height: 6.8cm,
    direction: rtl,
    colour: rgb("#E6B43A"),
    panel-colour: rgb("#0B2D40"),
    title-colour: rgb("#151515"),
    text-colour: rgb("#EEF3F5"),
    number-colour: white,
  )
]
