// Monochrome print examples — one component in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 7cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #modern-block-list-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit.],
      number: "01",
      icon: image("assets/modern-block-list-coins.png", width: 0.85cm),
      print-icon: image("assets/modern-block-list-coins.png", width: 0.85cm),
      width: 10cm,
      height: 2.9cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #modern-block-list-box(
      title: [خطة واضحة],
      body: [خطوات عملية لتنظيم الأفكار، وتقديم المعلومات بطريقة مختصرة وسهلة المتابعة.],
      number: "٠١",
      icon: image("assets/modern-block-list-coins.png", width: 0.85cm),
      print-icon: image("assets/modern-block-list-coins.png", width: 0.85cm),
      width: 10cm,
      height: 2.9cm,
      direction: rtl,
    )
  ]
]
