// One Horizontal Bubble List component — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 12cm, margin: 0.25cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #horizontal-bubble-box(
    bubble-title: [Lorem Ipsum],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/horizontal-bubble-puzzle-white.svg", width: 1.08cm),
    print-icon: image("assets/horizontal-bubble-puzzle-print.svg", width: 1.08cm),
    width: 4.4cm,
    height: 8.9cm,
    direction: ltr,
    colour: rgb("#4CC1EF"),
  )
]
