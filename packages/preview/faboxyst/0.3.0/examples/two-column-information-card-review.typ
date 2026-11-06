// Review: a single Two-Column Information Card in LTR, RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12.5cm, height: 4.4cm, margin: 0.35cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #two-column-information-card(
    title: [Project Summary],
    body: [A concise overview of the key decision, its context, and the next action for the team.],
    width: 9.8cm,
    height: 2.3cm,
    direction: ltr,
    accent-colour: rgb("#1AA1B2"),
  )
]

#pagebreak()
#set page(fill: rgb("#001624"))
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

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #two-column-information-card(
      title: [Project Summary],
      body: [A concise overview of the key decision, its context, and the next action for the team.],
      width: 9.8cm,
      height: 2.3cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #two-column-information-card(
      title: [موجز المشروع],
      body: [ملخص واضح للفكرة، وسياقها، والخطوة التالية التي تساعد الفريق على التقدم.],
      width: 9.8cm,
      height: 2.3cm,
      direction: rtl,
    )
  ]
]
