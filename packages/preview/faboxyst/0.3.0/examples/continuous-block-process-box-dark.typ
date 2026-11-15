// One mirrored RTL card on a dark page, using the source's red progress palette.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 14cm, margin: 0.4cm, fill: rgb("#182632"))
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #continuous-block-process-box(
    title: [خطة العمل],
    value: [١٠٠٪],
    body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
    colour: rgb("#C53218"),
    panel-colour: rgb("#F1F1EF"),
    direction: rtl,
  )
]
