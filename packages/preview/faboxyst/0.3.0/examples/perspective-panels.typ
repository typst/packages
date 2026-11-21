// Three configurable perspective panels; different widths and gaps are intentional.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 9.0cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #perspective-panels(
    (
      (title: [Focus], number: [01], body: [Choose one priority and keep the message clear.], colour: rgb("#F4A51C")),
      (title: [Momentum], number: [02], body: [Track the key measures and share progress with the team.], colour: rgb("#E85A48"), text-colour: white),
      (title: [Outcome], number: [03], body: [Connect the final result to the next decision.], colour: rgb("#43B9D3")),
    ),
    panel-widths: (2.8cm, 3.5cm, 2.8cm),
    gaps: (-0.16cm, -0.22cm),
    height: 6.25cm,
    direction: ltr,
  )
]
