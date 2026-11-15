// Review: one Information Blocks card only, shown in LTR, RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.4cm, margin: 0.35cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #information-block-box(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras.],
    number: "01",
    icon: image("assets/information-blocks-gears.png", width: 0.88cm),
    print-icon: image("assets/information-blocks-gears.png", width: 0.88cm),
    width: 8.2cm,
    height: 5.25cm,
    direction: ltr,
    colour: rgb("#F15F4B"),
    body-colour: rgb("#00243A"),
  )
]

#pagebreak()
#set page(fill: rgb("#001624"))
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

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #information-block-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras.],
      number: "01",
      icon: image("assets/information-blocks-gears.png", width: 0.88cm),
      print-icon: image("assets/information-blocks-gears.png", width: 0.88cm),
      width: 8.2cm,
      height: 5.25cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
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
    )
  ]
]
