// One Card List item — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 11.5cm, margin: 0.35cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #card-list-box(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/card-list-briefcase-yellow.png", width: 1.65cm),
    print-icon: image("assets/card-list-briefcase-black.png", width: 1.65cm),
    width: 4.8cm,
    height: 6.8cm,
    direction: ltr,
    backplate-colour: rgb("#FFC943"),
    tilt: 12deg,
  )
]
