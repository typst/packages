// One-page review of a single configurable feature callout.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#FAFAFA"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #feature-callout-box(
    title: [Accelerate review],
    body: [Catch delays early and keep decisions moving with a quick daily check.],
    icon-style: 0,
    width: 7.6cm,
    size: 3.8cm,
    colour: rgb("#55C4DD"),
    label-position: "above",
  )
]
