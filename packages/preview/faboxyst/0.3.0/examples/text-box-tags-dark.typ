// One reusable notched text tag — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: rgb("#202329"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
