// Four pages: color LTR, color Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #pencil-sketch-ellipse(
    title: [One clear idea],
    body: [Circle a useful thought and come back to it later.],
    width: 7.4cm, height: 2.90cm, colour: rgb("#D99042"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #pencil-sketch-ellipse(
    title: [فكرة واضحة],
    body: [أبرز الفكرة المهمة وعد إليها لاحقًا.],
    width: 7.4cm, height: 2.90cm, direction: rtl,
    colour: rgb("#D99042"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #pencil-sketch-ellipse(
      title: [One clear idea],
      body: [Circle a useful thought and come back to it later.],
      width: 7.4cm, height: 2.90cm, colour: rgb("#D99042"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #pencil-sketch-ellipse(
      title: [فكرة واضحة],
      body: [أبرز الفكرة المهمة وعد إليها لاحقًا.],
      width: 7.4cm, height: 2.90cm, direction: rtl,
      colour: rgb("#D99042"),
    )
  ]
]
