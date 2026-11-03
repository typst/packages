// One reusable frame-accent block — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 7.2cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #frame-accent-block(
    title: [Focused Insight],
    body: [Give one useful observation room to stand out, then add concise details that support it.],
    icon: image("assets/frame-accent-bulb.svg", width: 1.05cm),
    width: 4.1cm,
    square-size: 2.5cm,
    offset: 0.34cm,
    body-height: 1.55cm,
    direction: ltr,
    colour: rgb("#FFA91F"),
  )
]
