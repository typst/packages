// One Two-Column Information Card — light LTR.
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
