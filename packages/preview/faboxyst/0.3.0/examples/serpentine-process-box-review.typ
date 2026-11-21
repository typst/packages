// One source-faithful interlocking serpentine process node for visual review.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #serpentine-process-box(
    title: [LOREM IPSUM],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    colour: rgb("#C83B24"),
    direction: ltr,
  )
]
