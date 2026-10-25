// Grayscale print version with Arabic RTL content.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
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
