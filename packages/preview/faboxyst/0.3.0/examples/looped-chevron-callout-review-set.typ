// One horizontal looped callout per page: original palette, alternate, RTL, print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5.5cm, margin: 0.3cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #looped-chevron-callout(
    body: [Place your text here, sample text. Place your text here. Sample text here. Place your text here. Sample text. Put your text here; sample your text here.],
    width: 11.2cm, height: 4.7cm,
  )
]
#pagebreak()
#looped-chevron-callout(
  body: [A wide reusable callout with an open-loop frame, three colored chevrons, and a flexible emblem area.],
  width: 11.2cm, height: 4.7cm,
  colour: rgb("#148CA0"), icon-colour: rgb("#173B52"),
  chevron-colours: (rgb("#FFB52F"), rgb("#F05A68"), rgb("#8798A2")),
)
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #looped-chevron-callout(
    body: [اكتب هنا نصاً موجزاً يشرح الفكرة بوضوح، مع المحافظة على اتجاه القراءة العربي وانعكاس الإطار والزخرفة إلى الجهة المقابلة.],
    width: 11.2cm, height: 4.7cm, direction: rtl, icon-size: 1.5cm,
    colour: rgb("#6F4A9B"), icon-colour: rgb("#6F4A9B"),
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #looped-chevron-callout(
      body: [Monochrome print keeps the outlined loop, left emblem area, and triple-chevron pointer distinct.],
      width: 11.2cm, height: 4.7cm,
    )
  ]
]
