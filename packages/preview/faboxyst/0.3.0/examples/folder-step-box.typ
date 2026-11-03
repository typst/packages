// One reusable folder-step box — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 5.8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #folder-step-box(
    title: [Plan the Work],
    body: [Capture the key actions, owners, and timing in one easy-to-scan folder.],
    icon: image("assets/folder-step-clipboard-navy.svg", width: 0.62cm),
    print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
    number: [01],
    width: 5.9cm,
    front-height: 3.3cm,
    folder-height: 2.55cm,
    direction: ltr,
    colour: rgb("#78AA78"),
  )
]
