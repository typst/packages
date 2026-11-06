// One standalone horizontal row from a vertical numbered-chevron list.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5cm, margin: 0.45cm, fill: rgb("#F0EEF0"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [01],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
    width: 11cm,
    height: 1.55cm,
    colour: rgb("#103C51"),
  )
]
