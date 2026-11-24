// A single highlighted soft-relief diamond tile with its caption below.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#F0EFF1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #neumorphic-diamond-box(
    title: [Aim for clarity],
    body: [A focused goal makes the next step easier to see.],
    icon-style: 0,
    width: 4.8cm,
    side: 2.1cm,
    accent: true,
    colour: rgb("#32B7DF"),
    label-position: "below",
  )
]
