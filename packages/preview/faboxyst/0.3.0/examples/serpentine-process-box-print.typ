// Grayscale print preview in both text directions.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #serpentine-process-box(
      title: [LOREM IPSUM],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      colour: rgb("#C83B24"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #serpentine-process-box(
      title: [خطة التنفيذ],
      body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
      colour: rgb("#20AAC2"),
      direction: rtl,
    )
  ]
]
