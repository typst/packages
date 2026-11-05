// One Nested File Text Box — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 14cm, height: 5.4cm, margin: 0.4cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #nested-file-text-box(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc.],
    number: "01",
    icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
    print-icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
    width: 7.5cm,
    height: 2.7cm,
    direction: ltr,
    colour: rgb("#4CC1EF"),
    panel-colour: rgb("#F1F1F1"),
  )
]
