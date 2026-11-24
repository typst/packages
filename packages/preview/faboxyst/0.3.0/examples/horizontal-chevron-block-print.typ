// A monochrome print variant of the single chevron block.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.5cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#align(center + horizon)[
  #horizontal-chevron-block(
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    width: 11.2cm,
    height: 1.8cm,
    chevron-side: "end",
    icon-style: 1,
  )
]
