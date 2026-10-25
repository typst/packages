// Four focused pages: color LTR, color Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-template-box(
    title: [Business],
    body: [Helping teams deliver useful products and services.],
    icon-style: 0, width: 7.4cm, height: 1.48cm, badge-size: 1.74cm,
    icon-side: "right", text-align: "center", colour: rgb("#F1840B"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #six-boxes-template-box(
    title: [نموّ الأعمال],
    body: [نساعد الفرق على تقديم منتجات وخدمات نافعة تلبي احتياجات الناس والمجتمع.],
    icon-style: 3, width: 7.4cm, height: 1.48cm, badge-size: 1.74cm,
    icon-side: "start", direction: rtl, text-align: "center",
    colour: rgb("#43834A"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-template-box(
      title: [Business],
      body: [Helping teams deliver useful products and services.],
      icon-style: 0, width: 7.4cm, height: 1.48cm, badge-size: 1.74cm,
      icon-side: "right", text-align: "center", colour: rgb("#F1840B"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-template-box(
      title: [نموّ الأعمال],
      body: [نساعد الفرق على تقديم منتجات وخدمات نافعة تلبي احتياجات الناس والمجتمع.],
      icon-style: 3, width: 7.4cm, height: 1.48cm, badge-size: 1.74cm,
      icon-side: "start", direction: rtl, text-align: "center",
      colour: rgb("#43834A"),
    )
  ]
]
