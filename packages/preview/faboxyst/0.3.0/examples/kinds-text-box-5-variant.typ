// Reference variant 5, expressed as a palette/number-size preset of text box 2.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 7cm, height: 9cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #kinds-text-box-2(
    number: [5],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 3.9cm,
    height: 7.2cm,
    colour: rgb("#A9D8F4"),
    shadow-colour: rgb("#8FC3E6"),
    number-colour: rgb("#FFE86D"),
    number-size: 29pt,
  )
]
