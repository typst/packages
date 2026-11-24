// One Side Banner Card, isolated from the source's three-card row.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 10.5cm, margin: 0.3cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #side-banner-card-box(
    title: [Project Overview],
    label: [STEP 01],
    body: [Clear priorities help a team turn a shared goal into concrete actions. Review progress regularly and adjust the next step when needed.],
    icon: image("assets/side-banner-rocket.svg", width: 0.88cm),
    print-icon: image("assets/side-banner-rocket-black.svg", width: 0.88cm),
    width: 6.2cm,
    height: 8.8cm,
    direction: ltr,
    colour: rgb("#F15F47"),
  )
]
