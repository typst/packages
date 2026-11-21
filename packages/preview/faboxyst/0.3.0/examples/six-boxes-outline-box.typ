// One outlined box with an overlapping square icon badge (SlideEgg slide 3).
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-outline-box(
    title: [Business],
    body: [Activity of making money by producing goods and services.],
    icon-style: 0,
    width: 7.0cm,
    height: 2.30cm,
    badge-size: 1.14cm,
    badge-side: "left",
    colour: rgb("#F1840B"),
  )
]
