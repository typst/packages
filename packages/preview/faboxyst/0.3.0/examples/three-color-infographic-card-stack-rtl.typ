// Three individual cards composed on a shared ribbon with Arabic RTL text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 14cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #three-color-infographic-stack(
    width: 10.2cm,
    card-height: 3.7cm,
    overlap: 0.66cm,
    spine-overhang: 0.38cm,
    spine-width: 1.12cm,
    direction: rtl,
    spine-side: "start",
    spine-colour: rgb("#E3E1DE"),
    cards: (
      (title: [عنوان أول], body: [نص موجز يشرح الفكرة الأولى ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#4B84BE")),
      (title: [عنوان ثان], body: [نص موجز يشرح الفكرة الثانية ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#CA5209")),
      (title: [عنوان ثالث], body: [نص موجز يشرح الفكرة الثالثة ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#C78D00")),
    ),
  )
]
