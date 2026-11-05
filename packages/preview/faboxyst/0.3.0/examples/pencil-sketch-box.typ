// One imperfect rounded-rectangle outline, drawn as a pencil sketch.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #pencil-sketch-box(
    title: [A useful idea],
    body: [Gather observations, sketch a direction, and refine the details together.],
    width: 7.2cm,
    height: 2.70cm,
    colour: rgb("#C99D20"),
  )
]
