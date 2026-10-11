// Print preview — one card in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12.5cm, height: 4.4cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
