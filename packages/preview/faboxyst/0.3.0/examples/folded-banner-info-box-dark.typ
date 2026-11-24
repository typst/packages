// Genuine Arabic RTL version: Arabic copy, Arabic numerals, mirrored component and dark canvas.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #folded-banner-info-box(
    title: [مراجعة الأداء],
    number: [٠٢],
    icon-style: 1,
    body: [قارن النتائج بالأهداف، وسجّل ما نجح، ثم حدّد الخطوة التالية بوضوح للفريق.],
    colour: rgb("#35BBD5"),
    width: 11.6cm,
    direction: rtl,
  )
]
