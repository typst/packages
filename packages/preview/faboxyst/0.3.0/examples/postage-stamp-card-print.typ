// One postage-stamp card in monochrome print mode, using Arabic RTL copy.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#print-group[
  #align(center + horizon)[
    #postage-stamp-card(
      title: [خطة واضحة],
      body: [حدّد الأولوية، ثم قارن النتائج، ودوّن خلاصة قصيرة قابلة للتنفيذ.],
      width: 4.7cm,
      height: 5.35cm,
      icon-style: 3,
      colour: rgb("#32BCD0"),
      direction: rtl,
    )
  ]
]
