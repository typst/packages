// One Modern Block List component — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 7cm, margin: 0.4cm, fill: rgb("#001F33"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

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
    colour: rgb("#B55227"),
    support-colour: rgb("#CDD1D5"),
    text-colour: white,
  )
]
