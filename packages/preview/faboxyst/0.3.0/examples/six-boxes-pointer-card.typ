// One square icon tile with a top tab, bottom pointer, and caption.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-pointer-card(
    title: [Target],
    body: [Know the audience and define the intended outcome.],
    icon-style: 2,
    width: 2.9cm,
    box-size: 1.78cm,
    colour: rgb("#1E6685"),
  )
]
