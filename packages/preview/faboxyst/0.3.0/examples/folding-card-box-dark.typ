// Genuine Arabic RTL: mirrored folding flap and Arabic content on a dark page.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#142A38"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #folding-card-box(
    number: [٠٢],
    title: [الخطوة التالية],
    front-text: [سجّل الإجراء الأساسي وتابع تقدّم الفريق نحو النتيجة المطلوبة.],
    body: [اجمع الفريق حول نتيجة واضحة، واتفقوا على إجراء عملي يقود إلى المرحلة التالية.],
    width: 7.8cm,
    colour: rgb("#F05A32"),
    direction: rtl,
  )
]
