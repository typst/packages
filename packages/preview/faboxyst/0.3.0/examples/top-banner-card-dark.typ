// One dark-page RTL Top Banner Card.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 10.5cm, margin: 0.3cm, fill: rgb("#002033"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #top-banner-card-box(
    title: [خطة واضحة],
    label: [عنوان ٠٢],
    body: [حددوا الهدف، وشاركوا التفاصيل المهمة، واتفقوا على خطوة تالية واضحة. راجعوا التقدم باستمرار وعدّلوا الخطة عند الحاجة.],
    icon: image("assets/top-banner-gears.svg", width: 0.94cm),
    print-icon: image("assets/top-banner-gears-black.svg", width: 0.94cm),
    width: 6.2cm,
    height: 8.8cm,
    direction: rtl,
    colour: rgb("#3AC6E1"),
    shadow-colour: rgb("#385462"),
  )
]
