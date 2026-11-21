// Print-safe grayscale example in both text directions.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 6.2cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #stacked-summary-card-box(
      title: [Pretium Lectus Quam Id],
      body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor congue massa, fusce posuere.],
      colour: rgb("#F26455"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #stacked-summary-card-box(
      title: [ملخص المشروع],
      body: [يعرض هذا الملخص أهم النقاط بوضوح، ويجمع الفكرة الرئيسية مع معلومات موجزة تساعد الفريق على المتابعة.],
      colour: rgb("#22B5C7"),
      direction: rtl,
    )
  ]
]
