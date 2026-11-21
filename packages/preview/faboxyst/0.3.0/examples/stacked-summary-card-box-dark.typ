// One RTL summary card on a dark page with mirrored accent bar.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 6.2cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
