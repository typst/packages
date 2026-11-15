// One reusable L-shaped header box — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: rgb("#202329"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #l-shaped-header-box(
    header: [رؤية مهمّة],
    title: [اجعل المعلومات أسهل في التطبيق],
    body: [أبرز الرسالة الأهم، ثم أضف سياقاً يوضّح الفائدة أو يقترح خطوة تالية.],
    icon: image("assets/l-shaped-award.svg", width: 0.72cm),
    width: 7.8cm,
    height: 3.8cm,
    direction: rtl,
    dark: true,
    colour: rgb("#48C6B5"),
    title-size: 13pt,
    body-size: 10pt,
  )
]
