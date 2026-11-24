// Grayscale print variant with Arabic RTL text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 7cm, height: 9cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #kinds-text-box-2(
    number: [2],
    title: [عنوان واضح],
    body: [نص موجز يشرح الفكرة الثانية ويعرض أهم تفاصيلها للقارئ بوضوح.],
    width: 3.9cm,
    height: 7.4cm,
    direction: rtl,
  )
]
