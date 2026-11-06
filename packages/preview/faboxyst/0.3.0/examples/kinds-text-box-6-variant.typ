// Reference variant 6, expressed as a white/blue preset of text box 1.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #kinds-text-box-1(
    number: [6],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.],
    width: 6.7cm,
    height: 6.9cm,
    colour: white,
    shadow-colour: rgb("#D8EAF5"),
    number-colour: rgb("#68A1D5"),
  )
]
