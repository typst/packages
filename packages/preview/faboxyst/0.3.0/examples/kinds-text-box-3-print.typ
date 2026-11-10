// Grayscale print variant with Arabic RTL content.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #kinds-text-box-3(
    number: [3],
    title: [عنوان واضح],
    body: [هذا نص توضيحي للفكرة الثالثة. يشرح التفاصيل المهمة ويقدم معلومات مفيدة تساعد القارئ على فهم الموضوع بسهولة.],
    width: 8.8cm,
    height: 6.2cm,
    direction: rtl,
  )
]
