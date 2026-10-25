// One Vertical Banner List component — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: rgb("#2B303A"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

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
