// One reusable pocket card — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 5.8cm, margin: 0.45cm, fill: rgb("#20242A"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #pocket-card-box(
    title: [ملحوظة للنمو],
    body: [يساعد شكل الجيب على إبقاء الفكرة الأساسية قريبة وسهلة الاسترجاع. أضف وصفاً موجزاً أو تذكيراً عملياً.],
    icon: image("assets/pocket-card-bars-white.svg", width: 0.46cm),
    print-icon: image("assets/pocket-card-bars-black.svg", width: 0.46cm),
    width: 4.7cm,
    card-height: 3.5cm,
    direction: rtl,
    dark: true,
    colour: rgb("#2DB8CA"),
  )
]
