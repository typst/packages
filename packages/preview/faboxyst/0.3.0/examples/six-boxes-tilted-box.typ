// One slanted outline box with its colored parallelogram icon panel.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-tilted-box(
    title: [Business],
    body: [Activity of making money by producing goods and services.],
    icon-style: 0,
    width: 7.4cm,
    height: 2.20cm,
    badge-width: 2.22cm,
    badge-height: 1.76cm,
    badge-side: "left",
    colour: rgb("#F1840B"),
  )
]
