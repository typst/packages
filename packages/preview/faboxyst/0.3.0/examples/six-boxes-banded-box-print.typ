// Grayscale preview with LTR and genuine Arabic RTL text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #six-boxes-banded-box(
      title: [Process],
      body: [A clear sequence of steps helps the team accomplish its goal.],
      icon-style: 1, width: 7.2cm, height: 1.42cm,
      badge-size: 1.10cm, badge-side: "right", colour: rgb("#9E2737"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-banded-box(
      title: [النموّ],
      body: [تساعد الخطة الواضحة الفريق على تنسيق الجهود وتحقيق النتائج المطلوبة.],
      icon-style: 3, width: 7.2cm, height: 1.42cm,
      badge-size: 1.10cm, badge-side: "start", direction: rtl,
      colour: rgb("#43834A"),
    )
  ]
]
