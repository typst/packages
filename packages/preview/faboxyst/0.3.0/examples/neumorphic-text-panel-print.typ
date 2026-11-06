// Monochrome print-mode check of the individual text panel.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#align(center + horizon)[
  #neumorphic-text-panel(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.],
    width: 4.8cm,
    height: 6cm,
    accent: true,
    icon-style: 3,
  )
]
