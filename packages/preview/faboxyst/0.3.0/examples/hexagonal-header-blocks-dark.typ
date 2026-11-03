// One Hexagonal Header Blocks component — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.5cm, height: 9.8cm, margin: 0.2cm, fill: rgb("#001F33"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

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
