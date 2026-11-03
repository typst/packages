// Four-page review: color LTR, dark RTL, grayscale print LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #paper-note-box(
    title: [LOREM IPSUM],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    colour: rgb("#FFA91F"),
    direction: ltr,
  )
]
#pagebreak()
#set page(fill: rgb("#172833"))
#align(center + horizon)[
  #paper-note-box(
    title: [ملخص المشروع],
    body: [يعرض هذا الملخص أهم النقاط بوضوح، ويجمع الفكرة الرئيسية مع معلومات موجزة تساعد الفريق على المتابعة. تابعوا المستجدات، وسجلوا القرارات والخطوات التالية لضمان وضوح العمل.],
    colour: rgb("#25B9C9"),
    direction: rtl,
  )
]
#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #paper-note-box(
      title: [LOREM IPSUM],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      colour: rgb("#FFA91F"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #paper-note-box(
      title: [ملخص المشروع],
      body: [يعرض هذا الملخص أهم النقاط بوضوح، ويجمع الفكرة الرئيسية مع معلومات موجزة تساعد الفريق على المتابعة. تابعوا المستجدات، وسجلوا القرارات والخطوات التالية لضمان وضوح العمل.],
      colour: rgb("#25B9C9"),
      direction: rtl,
    )
  ]
]
