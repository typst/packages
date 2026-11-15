// One Information Blocks card — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.4cm, margin: 0.35cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #information-block-box(
    title: [فكرة واضحة],
    body: [يساعد هذا الإطار على تنظيم المعلومات وتقديمها بوضوح، مع شرح موجز يدعم الفكرة الأساسية.],
    number: "٠١",
    icon: image("assets/information-blocks-gears.png", width: 0.88cm),
    print-icon: image("assets/information-blocks-gears.png", width: 0.88cm),
    width: 8.2cm,
    height: 5.25cm,
    direction: rtl,
    colour: rgb("#38C1D4"),
    body-colour: rgb("#00334A"),
  )
]
