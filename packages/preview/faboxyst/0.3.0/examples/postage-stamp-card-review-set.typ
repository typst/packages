// Three single-card checks: color LTR, real Arabic RTL, and grayscale RTL print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #postage-stamp-card(
    title: [Key figures],
    body: [Track the signal, compare the trend, and keep the takeaway concise.],
    width: 4.7cm,
    height: 5.35cm,
    icon-style: 3,
    colour: rgb("#F05C4B"),
    perforation-colour: white,
  )
]
#pagebreak()
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
    perforation-colour: white,
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #postage-stamp-card(
      title: [خطة واضحة],
      body: [حدّد الأولوية، ثم قارن النتائج، ودوّن خلاصة قصيرة قابلة للتنفيذ.],
      width: 4.7cm,
      height: 5.35cm,
      icon-style: 3,
      colour: rgb("#32BCD0"),
      direction: rtl,
      perforation-colour: white,
    )
  ]
]
