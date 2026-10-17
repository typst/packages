// One grayscale print infographic card with Arabic RTL text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.3cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #three-color-infographic-card(
    title: [عنوان واضح],
    body: [هذا نص توضيحي يشرح الفكرة ويعرض أهم تفاصيلها للقارئ بأسلوب واضح وموجز.],
    width: 10.2cm,
    height: 4cm,
    direction: rtl,
    colour: rgb("#CA5209"),
  )
]
