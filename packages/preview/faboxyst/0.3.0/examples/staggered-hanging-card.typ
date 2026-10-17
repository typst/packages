// One Staggered Hanging Card — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.3cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #staggered-hanging-card-box(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    clip: image("assets/staggered-binder-clip.svg", width: 0.56cm),
    print-clip: image("assets/staggered-binder-clip.svg", width: 0.56cm),
    width: 5.4cm,
    height: 6.3cm,
    direction: ltr,
    card-colour: rgb("#EF604C"),
    title-colour: white,
    text-colour: white,
  )
]
