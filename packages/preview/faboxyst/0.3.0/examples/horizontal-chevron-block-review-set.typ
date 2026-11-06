// Four single-block checks: coral LTR, amber reversed, Arabic RTL, print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.5cm, margin: 0.4cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #horizontal-chevron-block(
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    width: 11.2cm, height: 1.8cm,
    accent-colour: rgb("#F05C4B"), icon-style: 0,
  )
]
#pagebreak()
#align(center + horizon)[
  #horizontal-chevron-block(
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    width: 11.2cm, height: 1.8cm,
    chevron-side: "end", accent-colour: rgb("#F5A51A"), icon-style: 1,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #horizontal-chevron-block(
    body: [نص موجز يشرح خطوة العمل ويعرض الفكرة بوضوح، ثم يلخص النتيجة المتوقعة بإيجاز مناسب.],
    width: 11.2cm, height: 1.8cm,
    direction: rtl, chevron-side: "start",
    accent-colour: rgb("#6FA574"), icon-style: 2,
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #horizontal-chevron-block(
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
      width: 11.2cm, height: 1.8cm,
      chevron-side: "end", accent-colour: rgb("#37BFD2"), icon-style: 3,
    )
  ]
]
