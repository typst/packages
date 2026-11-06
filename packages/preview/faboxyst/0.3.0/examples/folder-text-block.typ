// One Folder Text Blocks component — light LTR, following the downloadable PPTX proportions.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.2cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #folder-text-block(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/folder-text-block-burger-brown.svg", width: 1.60cm),
    print-icon: image("assets/folder-text-block-burger-black.svg", width: 1.60cm),
    number: [1],
    width: 7cm,
    height: 4.55cm,
    direction: ltr,
    colour: rgb("#F6A51A"),
  )
]
