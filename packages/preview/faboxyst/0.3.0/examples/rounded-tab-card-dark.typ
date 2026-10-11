// One dark-page RTL Rounded Tab Card.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: rgb("#002033"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #rounded-tab-card-box(
    title: [فكرة واضحة],
    body: [تجمع الفكرة الواضحة التفاصيل المهمة حول هدف واحد، وتساعد الفريق على فهم الأولويات واختيار الخطوة التالية.],
    icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
    print-icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
    width: 6cm,
    body-height: 4.8cm,
    direction: rtl,
    colour: rgb("#3AC6E1"),
    title-colour: rgb("#122F3C"),
  )
]
