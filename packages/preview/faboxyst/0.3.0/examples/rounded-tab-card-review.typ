// Review: one Rounded Tab Card in LTR and dark RTL variants.
// Print variants are compiled separately in rounded-tab-card-print.typ.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #rounded-tab-card-box(
    title: [Bright Idea],
    body: [A clear idea brings the important details into focus and gives a team a practical next step to follow.],
    icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
    print-icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
    width: 6cm,
    body-height: 4.8cm,
    direction: ltr,
    colour: rgb("#F15F47"),
  )
]

#pagebreak()
#set page(fill: rgb("#002033"))
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
