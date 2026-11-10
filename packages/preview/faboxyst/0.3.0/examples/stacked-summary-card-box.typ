// One summary card, isolated from the source's five-card vertical stack.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 6.2cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #stacked-summary-card-box(
    title: [Pretium Lectus Quam Id],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor congue massa, fusce posuere.],
    colour: rgb("#F26455"),
    direction: ltr,
  )
]
