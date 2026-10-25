// One double-outline card with a centered rounded icon tab.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-folder-card(
    title: [Process],
    body: [A clear sequence of steps helps the team accomplish its goal.],
    icon-style: 1,
    width: 4.8cm,
    height: 2.35cm,
    colour: rgb("#9E2737"),
  )
]
