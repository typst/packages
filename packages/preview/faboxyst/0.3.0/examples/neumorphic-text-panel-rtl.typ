// Arabic RTL text in the same single-panel silhouette.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: rgb("#F1EFF1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #neumorphic-text-panel(
    title: [فكرة مفيدة],
    body: [سجّل الفكرة، وراجع أثرها، ثم احتفظ بخلاصة واضحة للخطوة التالية.],
    width: 4.8cm,
    height: 6cm,
    direction: rtl,
    icon-style: 2,
  )
]
