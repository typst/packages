// Visual review: one reusable tag per page, without the source slide layout.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #text-box-tag(
    title: [KEY IDEA],
    body: [Keep the message focused, add just enough context, and make the next action easy to find.],
    icon: image("assets/text-box-tag-star.svg", width: 0.92cm),
    width: 8.4cm,
    height: 3.35cm,
    direction: ltr,
    colour: rgb("#0B4058"),
    icon-colour: rgb("#F0A02B"),
  )
]

#pagebreak()
#set page(fill: rgb("#202329"))
#align(center + horizon)[
  #text-box-tag(
    title: [فكرة أساسية],
    body: [اجعل الرسالة واضحة، وأضف سياقاً موجزاً، ثم أبرز الخطوة التالية.],
    icon: image("assets/text-box-tag-star.svg", width: 0.92cm),
    width: 8.4cm,
    height: 3.35cm,
    direction: rtl,
    dark: true,
    colour: rgb("#174D62"),
    icon-colour: rgb("#83CBBE"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #text-box-tag(
      title: [KEY IDEA],
      body: [Keep the message focused, add context, and make the next action easy to find.],
      icon: image("assets/text-box-tag-star.svg", width: 0.92cm),
      width: 8.4cm,
      height: 3.35cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #text-box-tag(
      title: [فكرة أساسية],
      body: [اجعل الرسالة واضحة، وأضف سياقاً موجزاً، ثم أبرز الخطوة التالية.],
      icon: image("assets/text-box-tag-star.svg", width: 0.92cm),
      width: 8.4cm,
      height: 3.35cm,
      direction: rtl,
    )
  ]
]
