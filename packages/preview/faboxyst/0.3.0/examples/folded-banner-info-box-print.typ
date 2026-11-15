// Grayscale print preview: one LTR card and one genuine Arabic RTL card.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #folded-banner-info-box(
      title: [Focus], number: [01], icon-style: 0,
      body: [Choose one priority, make the next action clear, and share a concise update with the team.],
      colour: rgb("#F35D49"), title-colour: white, width: 11.6cm,
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #folded-banner-info-box(
      title: [مراجعة الأداء], number: [٠٢], icon-style: 1,
      body: [قارن النتائج بالأهداف، وسجّل ما نجح، ثم حدّد الخطوة التالية بوضوح للفريق.],
      colour: rgb("#35BBD5"), width: 11.6cm, direction: rtl,
    )
  ]
]
