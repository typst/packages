// One Four-Step Parchment Process component — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8.4cm, margin: 0.3cm, fill: rgb("#002335"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #four-step-parchment-process(
    title: [لوريم إيبسوم],
    body: [نص موجز يشرح الفكرة بوضوح، ويعرض أهم التفاصيل والخطوات العملية. يمكن استخدام هذه المساحة لتوضيح السياق، وتحديد الأولويات، وإبراز النتيجة المتوقعة للقارئ.],
    icon: image("assets/four-step-bulb-green.svg", width: 0.90cm),
    print-icon: image("assets/four-step-bulb-print.svg", width: 0.90cm),
    width: 6cm,
    height: 6.6cm,
    direction: rtl,
    dark: true,
    colour: rgb("#5B9E67"),
    text-colour: white,
  )
]
