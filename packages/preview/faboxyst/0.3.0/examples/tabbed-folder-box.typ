// One reusable folder-tab box — light LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.4cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #tabbed-folder-box(
    title: [KEY PRIORITY],
    body: [Keep related ideas together. Use this folder-style box for a concise summary, a priority, or a project update.],
    icon: image("assets/tabbed-folder-check-white.svg", width: 0.58cm),
    print-icon: image("assets/tabbed-folder-check-black.svg", width: 0.58cm),
    width: 8.2cm,
    body-height: 2.2cm,
    direction: ltr,
    colour: rgb("#E95548"),
  )
]
