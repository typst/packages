// Four pages: color LTR, color Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #six-boxes-tilted-box(
    title: [Business],
    body: [Activity of making money by producing goods and services.],
    icon-style: 0, width: 7.4cm, height: 2.20cm,
    badge-width: 2.22cm, badge-height: 1.76cm, badge-side: "left",
    colour: rgb("#F1840B"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #six-boxes-tilted-box(
    title: [الهدف الواضح],
    body: [يساعد الهدف الواضح على اختيار الخطوة التالية، ويمنح الفريق اتجاهًا مشتركًا للعمل.],
    icon-style: 2, width: 7.4cm, height: 2.20cm,
    badge-width: 2.22cm, badge-height: 1.76cm,
    badge-side: "start", direction: rtl, colour: rgb("#1E6685"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-tilted-box(
      title: [Business],
      body: [Activity of making money by producing goods and services.],
      icon-style: 0, width: 7.4cm, height: 2.20cm,
      badge-width: 2.22cm, badge-height: 1.76cm, badge-side: "left",
      colour: rgb("#F1840B"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-tilted-box(
      title: [الهدف الواضح],
      body: [يساعد الهدف الواضح على اختيار الخطوة التالية، ويمنح الفريق اتجاهًا مشتركًا للعمل.],
      icon-style: 2, width: 7.4cm, height: 2.20cm,
      badge-width: 2.22cm, badge-height: 1.76cm,
      badge-side: "start", direction: rtl, colour: rgb("#1E6685"),
    )
  ]
]
