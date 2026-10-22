// One reusable hand-drawn bullet panel in color (LTR).
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-bullet-panel(
    width: 8.2cm,
    grayscale: false,
    items: (
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    ),
  )
]
