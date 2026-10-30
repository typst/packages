// Review render: one Continuous Block Process component, not the three-card slide.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 14cm, margin: 0.4cm, fill: rgb("#F0EFEE"))
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #continuous-block-process-box(
    title: [LOREM IPSUM],
    value: [66%],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    colour: rgb("#F7941D"),
    direction: ltr,
  )
]
