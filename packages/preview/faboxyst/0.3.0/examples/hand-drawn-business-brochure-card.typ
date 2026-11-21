// One complete portrait brochure card (LTR, color).
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 16cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-business-brochure-card(
    width: 8.5cm,
    min-height: 12.4cm,
    title: [Lorem ipsum],
    photo-placeholder: [Your photo here],
    bullet-items: (
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    ),
  )
]
