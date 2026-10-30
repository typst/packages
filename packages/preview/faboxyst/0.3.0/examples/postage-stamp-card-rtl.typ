// One postage-stamp card with genuine Arabic RTL copy.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #postage-stamp-card(
    title: [فكرة مفيدة],
    body: [سجّل الفكرة، وراجع أثرها، ثم احتفظ بخلاصة واضحة للخطوة التالية.],
    width: 4.7cm,
    height: 5.35cm,
    icon-style: 1,
    colour: rgb("#F3A51B"),
    direction: rtl,
  )
]
