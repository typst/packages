// Monochrome print variants — one parchment box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8.4cm, margin: 0.3cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #four-step-parchment-process(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/four-step-hourglass-red.svg", width: 0.90cm),
      print-icon: image("assets/four-step-hourglass-print.svg", width: 0.90cm),
      width: 6cm,
      height: 6.6cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #four-step-parchment-process(
      title: [لوريم إيبسوم],
      body: [نص موجز يشرح الفكرة بوضوح، ويعرض أهم التفاصيل والخطوات العملية. يمكن استخدام هذه المساحة لتوضيح السياق، وتحديد الأولويات، وإبراز النتيجة المتوقعة للقارئ.],
      icon: image("assets/four-step-bulb-green.svg", width: 0.90cm),
      print-icon: image("assets/four-step-bulb-print.svg", width: 0.90cm),
      width: 6cm,
      height: 6.6cm,
      direction: rtl,
    )
  ]
]
