// Review: one diagonal banner card in LTR and dark RTL variants.
// Print-only variants are compiled separately in diagonal-banner-card-print.typ.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9.5cm, margin: 0.3cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #diagonal-banner-card-box(
    title: [Lorem Ipsum],
    items: (
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit.],
      [Nibh est vel auctor, convallis ornare. A magna maecenas.],
      [Suspendisse viverra sodales mauris in.],
    ),
    number: "01",
    icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
    print-icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
    width: 4.8cm,
    height: 6.8cm,
    direction: ltr,
    colour: rgb("#EF604C"),
  )
]

#pagebreak()
#set page(fill: rgb("#001624"))
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
