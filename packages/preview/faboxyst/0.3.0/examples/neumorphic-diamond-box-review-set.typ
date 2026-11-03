// Four pages: highlighted color LTR, dark Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#F0EFF1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #neumorphic-diamond-box(
    title: [Aim for clarity],
    body: [A focused goal makes the next step easier to see.],
    icon-style: 0, width: 4.8cm, side: 2.1cm,
    accent: true, colour: rgb("#32B7DF"), label-position: "below",
  )
]
#pagebreak()
#set page(fill: rgb("#2B3038"))
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #neumorphic-diamond-box(
    title: [الوضوح يبدأ بهدف],
    body: [يساعد الهدف المحدد على رؤية الخطوة التالية بوضوح أكبر.],
    icon-style: 1, width: 4.8cm, side: 2.1cm,
    dark: true, direction: rtl, label-position: "below",
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#set page(fill: white)
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
