// Grayscale print check of one numbered-chevron list row.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [02],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc.],
    width: 11cm,
    height: 1.55cm,
    badge-side: "start",
  )
]
