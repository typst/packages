// Grayscale print preview: one card in LTR and RTL with the arrow and value window retained.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 14cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #continuous-block-process-box(
      title: [LOREM IPSUM],
      value: [66%],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      colour: rgb("#F7941D"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #continuous-block-process-box(
      title: [خطة العمل],
      value: [١٠٠٪],
      body: [حددوا الهدف بوضوح، وشاركوا الخطوات الرئيسية مع الفريق. راجعوا التقدم بعد كل مرحلة، ثم اتفقوا على الإجراء التالي.],
      colour: rgb("#C53218"),
      direction: rtl,
    )
  ]
]
