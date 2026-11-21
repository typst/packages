// One segment with Arabic RTL text and the logical start cap mirrored right.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.5cm, margin: 0.4cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #horizontal-chevron-block(
    body: [نص موجز يشرح خطوة العمل ويعرض الفكرة بوضوح، ثم يلخص النتيجة المتوقعة بإيجاز مناسب.],
    width: 11.2cm,
    height: 1.8cm,
    direction: rtl,
    chevron-side: "start",
    accent-colour: rgb("#6FA574"),
    icon-style: 2,
  )
]
