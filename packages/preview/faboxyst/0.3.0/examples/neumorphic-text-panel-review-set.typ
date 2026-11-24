// Four single-panel checks: neutral LTR, blue accent, Arabic RTL, grayscale.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: rgb("#F1EFF1"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #neumorphic-text-panel(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.],
    width: 4.8cm, height: 6cm, icon-style: 0,
  )
]
#pagebreak()
#align(center + horizon)[
  #neumorphic-text-panel(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.],
    width: 4.8cm, height: 6cm, icon-style: 1,
    accent: true, accent-colour: rgb("#35B5E5"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #neumorphic-text-panel(
    title: [فكرة مفيدة],
    body: [سجّل الفكرة، وراجع أثرها، ثم احتفظ بخلاصة واضحة للخطوة التالية.],
    width: 4.8cm, height: 6cm, direction: rtl, icon-style: 2,
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #neumorphic-text-panel(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.],
      width: 4.8cm, height: 6cm, accent: true, icon-style: 3,
    )
  ]
]
