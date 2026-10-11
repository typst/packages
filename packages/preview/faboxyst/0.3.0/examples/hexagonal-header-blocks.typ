// One Hexagonal Header Blocks component — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.5cm, height: 9.8cm, margin: 0.2cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hexagonal-header-box(
    number: [01],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    icon: image("assets/hexagonal-eye-white.svg", width: 1.35cm),
    print-icon: image("assets/hexagonal-eye-print.svg", width: 1.35cm),
    width: 5.2cm,
    height: 7.6cm,
    direction: ltr,
    colour: rgb("#F15F47"),
    text-colour: white,
    title-colour: white,
  )
]
