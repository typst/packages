// One Simple Rounded Text Box — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 8cm, margin: 0.35cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #simple-rounded-text-box(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/simple-rounded-bike-white.png", width: 0.92cm),
    print-icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
    width: 7.8cm,
    height: 5.2cm,
    direction: ltr,
    header-colour: rgb("#3D5F87"),
  )
]
