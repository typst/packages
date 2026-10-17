// Three independent checks: color LTR, Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #kinds-text-box-1(
    number: [1],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.],
    width: 6.7cm,
    height: 6.9cm,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #kinds-text-box-1(
    number: [1],
    title: [عنوان واضح],
    body: [هذا نص توضيحي عن الفكرة الأولى. يشرح التفاصيل المهمة بطريقة موجزة وواضحة، ويعرض معلومات إضافية تساعد القارئ على فهم الموضوع بشكل أفضل.],
    width: 6.7cm,
    height: 6.9cm,
    direction: rtl,
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #kinds-text-box-1(
      number: [1],
      title: [عنوان واضح],
      body: [هذا نص توضيحي عن الفكرة الأولى. يشرح التفاصيل المهمة بطريقة موجزة وواضحة، ويعرض معلومات إضافية تساعد القارئ على فهم الموضوع بشكل أفضل.],
      width: 6.7cm,
      height: 6.9cm,
      direction: rtl,
    )
  ]
]
