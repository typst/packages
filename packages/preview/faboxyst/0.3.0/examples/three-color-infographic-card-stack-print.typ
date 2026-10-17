// Grayscale print check for the shared-ribbon stack helper.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 14cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#align(center + horizon)[
  #three-color-infographic-stack(
    width: 10.2cm,
    card-height: 3.7cm,
    overlap: 0.66cm,
    spine-overhang: 0.38cm,
    spine-width: 1.12cm,
    spine-colour: rgb("#E3E1DE"),
    cards: (
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#4B84BE")),
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#CA5209")),
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#C78D00")),
    ),
  )
]
