// One individual blue infographic text card (LTR).
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.3cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #three-color-infographic-card(
    title: [YOUR TEXT HERE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
    width: 10.2cm,
    height: 4cm,
    colour: rgb("#4B84BE"),
  )
]
