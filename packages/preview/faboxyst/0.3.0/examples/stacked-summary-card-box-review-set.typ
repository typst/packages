// Four-page review: color LTR, dark RTL, grayscale print LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 6.2cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #stacked-summary-card-box(
    title: [Pretium Lectus Quam Id],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor congue massa, fusce posuere.],
    colour: rgb("#F26455"),
    direction: ltr,
  )
]
#pagebreak()
#set page(fill: rgb("#172833"))
#align(center + horizon)[
  #stacked-summary-card-box(
    title: [ملخص المشروع],
    body: [يعرض هذا الملخص أهم النقاط بوضوح، ويجمع الفكرة الرئيسية مع معلومات موجزة تساعد الفريق على المتابعة.],
    colour: rgb("#22B5C7"),
    panel-colour: rgb("#263A45"),
    title-colour: white,
    text-colour: rgb("#D2DEE4"),
    direction: rtl,
  )
]
#pagebreak()
#set page(fill: white)
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
