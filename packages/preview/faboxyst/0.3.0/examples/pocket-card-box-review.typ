// Visual review: one pocket-style box per page, not a multi-card process row.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 5.8cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #pocket-card-box(
    title: [Growth Note],
    body: [A pocket keeps the key idea easy to retrieve. Use the copy below for a short description or practical reminder.],
    icon: image("assets/pocket-card-bars-white.svg", width: 0.46cm),
    print-icon: image("assets/pocket-card-bars-black.svg", width: 0.46cm),
    width: 4.7cm,
    card-height: 3.5cm,
    direction: ltr,
    colour: rgb("#F05D4E"),
  )
]

#pagebreak()
#set page(fill: rgb("#20242A"))
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

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #pocket-card-box(
      title: [Growth Note],
      body: [A pocket keeps the key idea easy to retrieve. Use the copy below for a short description or practical reminder.],
      icon: image("assets/pocket-card-bars-white.svg", width: 0.46cm),
      print-icon: image("assets/pocket-card-bars-black.svg", width: 0.46cm),
      width: 4.7cm,
      card-height: 3.5cm,
      direction: ltr,
      colour: rgb("#F05D4E"),
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #pocket-card-box(
      title: [ملحوظة للنمو],
      body: [يساعد شكل الجيب على إبقاء الفكرة الأساسية قريبة وسهلة الاسترجاع. أضف وصفاً موجزاً أو تذكيراً عملياً.],
      icon: image("assets/pocket-card-bars-white.svg", width: 0.46cm),
      print-icon: image("assets/pocket-card-bars-black.svg", width: 0.46cm),
      width: 4.7cm,
      card-height: 3.5cm,
      direction: rtl,
      colour: rgb("#F05D4E"),
    )
  ]
]
