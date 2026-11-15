// A single, colorful wave card with a circular badge.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#FAFAFA"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #wavy-infographic-box(
    title: [Idea flow],
    body: [Connect useful details in one lively card. A clear wave silhouette and icon badge help the key message stand out.],
    icon-style: 1,
    width: 6.2cm,
    height: 5.45cm,
    colour: rgb("#F49A24"),
  )
]
