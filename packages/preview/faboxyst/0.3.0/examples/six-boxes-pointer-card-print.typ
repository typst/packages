// Grayscale preview with LTR and genuine Arabic RTL text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #six-boxes-pointer-card(
      title: [Target],
      body: [Know the audience and define the intended outcome.],
      icon-style: 2, width: 2.9cm, box-size: 1.78cm,
      colour: rgb("#1E6685"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-pointer-card(
      title: [الهدف الواضح],
      body: [يساعد الهدف الواضح على اختيار الخطوة التالية بثقة.],
      icon-style: 2, width: 2.9cm, box-size: 1.78cm,
      colour: rgb("#1E6685"),
    )
  ]
]
