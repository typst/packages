// One mirrored RTL note on a dark page, with a cyan paper and offset backing sheet.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #paper-note-box(
    title: [ملخص المشروع],
    body: [يعرض هذا الملخص أهم النقاط بوضوح، ويجمع الفكرة الرئيسية مع معلومات موجزة تساعد الفريق على المتابعة. تابعوا المستجدات، وسجلوا القرارات والخطوات التالية لضمان وضوح العمل.],
    colour: rgb("#25B9C9"),
    direction: rtl,
  )
]
