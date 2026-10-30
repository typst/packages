// One mirrored RTL card on a dark page, with an alternate aqua palette.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #corner-ribbon-process-box(
    title: [خطة العمل],
    number: [02],
    body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
    colour: rgb("#24B7D0"),
    direction: rtl,
  )
]
