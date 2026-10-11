// The same single notched tag, monochrome print — LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

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
