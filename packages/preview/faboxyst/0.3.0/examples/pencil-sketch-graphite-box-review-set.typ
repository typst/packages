// Four pages: colour LTR, colour Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #pencil-sketch-graphite-box(
    title: [One useful note],
    body: [A soft graphite hatch keeps longer notes easy to read.],
    width: 7.4cm, height: 2.95cm,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #pencil-sketch-graphite-box(
    title: [ملاحظة مفيدة],
    body: [يمنح تظليل الرصاص مساحة هادئة لنص واضح ومقروء.],
    width: 7.4cm, height: 2.95cm, direction: rtl,
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #pencil-sketch-graphite-box(
      title: [One useful note],
      body: [A soft graphite hatch keeps longer notes easy to read.],
      width: 7.4cm, height: 2.95cm,
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #pencil-sketch-graphite-box(
      title: [ملاحظة مفيدة],
      body: [يمنح تظليل الرصاص مساحة هادئة لنص واضح ومقروء.],
      width: 7.4cm, height: 2.95cm, direction: rtl,
    )
  ]
]
