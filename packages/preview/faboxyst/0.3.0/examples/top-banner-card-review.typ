// Review: one Top Banner Card in LTR and dark RTL variants.
// Print previews are compiled separately in top-banner-card-print.typ.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 10.5cm, margin: 0.3cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #top-banner-card-box(
    title: [Clear Priorities],
    label: [TITLE 01],
    body: [Define the goal, share the key details, and agree on one clear next step. Review progress often and adjust the plan when needed.],
    icon: image("assets/top-banner-tools.svg", width: 0.94cm),
    print-icon: image("assets/top-banner-tools-black.svg", width: 0.94cm),
    width: 6.2cm,
    height: 8.8cm,
    direction: ltr,
    colour: rgb("#F15F47"),
  )
]

#pagebreak()
#set page(fill: rgb("#002033"))
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
