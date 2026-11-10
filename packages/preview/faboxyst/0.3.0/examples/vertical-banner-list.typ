// One Vertical Banner List component — light LTR, isolated from the five-item slide.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: rgb("#F3F0EE"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #vertical-banner-box(
    number: [01],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris.],
    width: 3.8cm,
    height: 7.7cm,
    direction: ltr,
    colour: rgb("#F7931F"),
  )
]
