// Four-page review: color LTR, dark RTL, and grayscale print in both directions.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #corner-ribbon-process-box(
    title: [LOREM IPSUM],
    number: [01],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    colour: rgb("#F15B4A"),
    direction: ltr,
  )
]
#pagebreak()
#set page(fill: rgb("#172833"))
#align(center + horizon)[
  #corner-ribbon-process-box(
    title: [خطة العمل],
    number: [02],
    body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
    colour: rgb("#24B7D0"),
    direction: rtl,
  )
]
#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #corner-ribbon-process-box(
      title: [LOREM IPSUM],
      number: [01],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      colour: rgb("#F15B4A"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #corner-ribbon-process-box(
      title: [خطة العمل],
      number: [02],
      body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
      colour: rgb("#24B7D0"),
      direction: rtl,
    )
  ]
]
