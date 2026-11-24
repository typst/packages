// Genuine Arabic RTL on a dark canvas, using the unaccented dark neumorphic surface.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#2B3038"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #neumorphic-diamond-box(
    title: [الوضوح يبدأ بهدف],
    body: [يساعد الهدف المحدد على رؤية الخطوة التالية بوضوح أكبر.],
    icon-style: 1,
    width: 4.8cm,
    side: 2.1cm,
    dark: true,
    direction: rtl,
    label-position: "below",
  )
]
