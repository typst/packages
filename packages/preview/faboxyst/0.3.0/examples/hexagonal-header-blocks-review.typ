// Visual review: one Hexagonal Header Blocks component in light LTR, dark RTL, and print modes.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.5cm, height: 9.8cm, margin: 0.2cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hexagonal-header-box(
    number: [01],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    icon: image("assets/hexagonal-eye-white.svg", width: 1.35cm),
    print-icon: image("assets/hexagonal-eye-print.svg", width: 1.35cm),
    width: 5.2cm,
    height: 7.6cm,
    direction: ltr,
    colour: rgb("#F15F47"),
    text-colour: white,
    title-colour: white,
  )
]

#pagebreak()
#set page(fill: rgb("#001F33"))
#align(center + horizon)[
  #hexagonal-header-box(
    number: [02],
    title: [المراجعة],
    body: [تساعد هذه المرحلة على مراجعة التفاصيل والتأكد من مطابقة النتائج للمعايير المطلوبة. افحص المخرجات بعناية، وسجّل الملاحظات المهمة قبل اعتماد الخطوة التالية.],
    icon: image("assets/hexagonal-shield-white.svg", width: 1.30cm),
    print-icon: image("assets/hexagonal-shield-print.svg", width: 1.30cm),
    width: 5.2cm,
    height: 7.6cm,
    direction: rtl,
    colour: rgb("#6EA56C"),
    text-colour: white,
    title-colour: white,
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #hexagonal-header-box(
      number: [01],
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
      icon: image("assets/hexagonal-eye-white.svg", width: 1.35cm),
      print-icon: image("assets/hexagonal-eye-print.svg", width: 1.35cm),
      width: 5.2cm,
      height: 7.6cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #hexagonal-header-box(
      number: [02],
      title: [المراجعة],
      body: [تساعد هذه المرحلة على مراجعة التفاصيل والتأكد من مطابقة النتائج للمعايير المطلوبة. افحص المخرجات بعناية، وسجّل الملاحظات المهمة قبل اعتماد الخطوة التالية.],
      icon: image("assets/hexagonal-shield-white.svg", width: 1.30cm),
      print-icon: image("assets/hexagonal-shield-print.svg", width: 1.30cm),
      width: 5.2cm,
      height: 7.6cm,
      direction: rtl,
    )
  ]
]
