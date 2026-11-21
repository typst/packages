// Print-mode grayscale proof for the graphite-pencil box.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #pencil-sketch-graphite-box(
      title: [One useful note],
      body: [A soft graphite hatch keeps longer notes easy to read.],
      width: 7.4cm,
      height: 2.95cm,
    )
  ]
]
