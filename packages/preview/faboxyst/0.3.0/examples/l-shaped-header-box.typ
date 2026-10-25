// One reusable L-shaped header box — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #l-shaped-header-box(
    header: [KEY INSIGHT],
    title: [Make information easier to act on],
    body: [Bring the most important message forward. Use the supporting copy to add context, clarify the benefit, or suggest a next step.],
    icon: image("assets/l-shaped-award.svg", width: 0.72cm),
    width: 7.8cm,
    height: 3.8cm,
    direction: ltr,
    colour: rgb("#42B9E1"),
    title-size: 13pt,
    body-size: 9pt,
  )
]
