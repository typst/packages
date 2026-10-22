// Grayscale print preview in LTR and Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #neumorphic-diamond-box(
      title: [Aim for clarity],
      body: [A focused goal makes the next step easier to see.],
      icon-style: 0, width: 4.8cm, side: 2.1cm,
      accent: true, colour: rgb("#32B7DF"), label-position: "below",
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #neumorphic-diamond-box(
      title: [الوضوح يبدأ بهدف],
      body: [يساعد الهدف المحدد على رؤية الخطوة التالية بوضوح أكبر.],
      icon-style: 1, width: 4.8cm, side: 2.1cm,
      dark: true, direction: rtl, label-position: "below",
    )
  ]
]
