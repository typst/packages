// The same single box, monochrome print — LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)

#align(center + horizon)[
  #l-shaped-header-box(
    header: [KEY INSIGHT],
    title: [Make information easier to act on],
    body: [Bring the most important message forward. Add context, explain the benefit, or suggest a practical next step.],
    icon: image("assets/l-shaped-award.svg", width: 0.72cm),
    width: 7.8cm,
    height: 3.8cm,
    direction: ltr,
    colour: rgb("#42B9E1"),
    title-size: 13pt,
    body-size: 9pt,
  )
]

#pagebreak()

#align(center + horizon)[
  #l-shaped-header-box(
    header: [رؤية مهمّة],
    title: [اجعل المعلومات أسهل في التطبيق],
    body: [أبرز الرسالة الأهم، ثم أضف سياقاً يوضّح الفائدة أو يقترح خطوة تالية.],
    icon: image("assets/l-shaped-award.svg", width: 0.72cm),
    width: 7.8cm,
    height: 3.8cm,
    direction: rtl,
    colour: rgb("#42B9E1"),
    title-size: 13pt,
    body-size: 10pt,
  )
]
