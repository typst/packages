// One individual horizontal chevron text-and-icon block in LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.5cm, margin: 0.4cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #horizontal-chevron-block(
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    width: 11.2cm,
    height: 1.8cm,
    accent-colour: rgb("#F05C4B"),
    icon-style: 0,
  )
]
