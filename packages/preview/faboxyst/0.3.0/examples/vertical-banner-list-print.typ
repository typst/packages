// Monochrome print variants — one vertical banner in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #vertical-banner-box(
      number: [01],
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris.],
      width: 3.8cm,
      height: 7.7cm,
      direction: ltr,
      colour: rgb("#F7931F"),
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #vertical-banner-box(
      number: [02],
      title: [لوريم إيبسوم],
      body: [نص موجز يشرح الفكرة بوضوح، ويعرض أهم التفاصيل والخطوات العملية. يمكن استخدام هذه المساحة لتوضيح السياق، وتحديد الأولويات، وإبراز النتيجة المتوقعة للقارئ.],
      width: 3.8cm,
      height: 7.7cm,
      direction: rtl,
      colour: rgb("#4CC1EF"),
    )
  ]
]
