// One Two-Column Information Card — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12.5cm, height: 4.4cm, margin: 0.35cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #two-column-information-card(
    title: [موجز المشروع],
    body: [ملخص واضح للفكرة، وسياقها، والخطوة التالية التي تساعد الفريق على التقدم.],
    width: 9.8cm,
    height: 2.3cm,
    direction: rtl,
    accent-colour: rgb("#38C3D4"),
    panel-colour: rgb("#092B3D"),
    title-colour: rgb("#F5F7F8"),
    text-colour: rgb("#D4DEE3"),
  )
]
