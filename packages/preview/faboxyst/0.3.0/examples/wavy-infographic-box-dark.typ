// Genuine Arabic RTL on a dark canvas; the card's notch and badge mirror.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#142B3A"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #wavy-infographic-box(
    title: [أفكار تنساب بوضوح],
    body: [اجمع التفاصيل المهمة في بطاقة حيوية. يساعد الشكل المتموج والأيقونة الواضحة على إبراز الفكرة الأساسية.],
    icon-style: 3,
    width: 6.2cm,
    height: 5.45cm,
    colour: rgb("#118A9A"),
    title-colour: white,
    text-colour: white,
    direction: rtl,
  )
]
