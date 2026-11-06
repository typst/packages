// Arabic RTL row; logical start number badge mirrors to the right.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5cm, margin: 0.45cm, fill: rgb("#F0EEF0"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [03],
    title: [خطوة جديدة],
    body: [نص موجز يشرح الخطوة بوضوح ويعرض تفاصيلها العملية بإيجاز مناسب للقارئ.],
    width: 11cm,
    height: 1.55cm,
    direction: rtl,
    badge-side: "start",
    colour: rgb("#35B9DA"),
  )
]
