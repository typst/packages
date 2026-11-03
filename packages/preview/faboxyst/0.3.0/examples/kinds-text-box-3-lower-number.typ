// Lower-number/pale-yellow treatment from reference variant 4, using the same component.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #kinds-text-box-3(
    number: [4],
    number-position: "lower",
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 8.8cm,
    height: 6.2cm,
    colour: rgb("#FFF0A6"),
    shadow-colour: rgb("#F0E38B"),
    number-colour: rgb("#68A1D5"),
  )
]
