// One reusable postage-stamp card in color (LTR).
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #postage-stamp-card(
    title: [Key figures],
    body: [Track the signal, compare the trend, and keep the takeaway concise.],
    width: 4.7cm,
    height: 5.35cm,
    icon-style: 3,
    colour: rgb("#F05C4B"),
  )
]
