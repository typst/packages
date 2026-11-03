// One portrait component per page: orange, green, Arabic RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 5.6cm, height: 7.7cm, margin: 0.3cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #quad-step-card(
    number: [01], title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
    width: 4.6cm, height: 4.6cm, colour: rgb("#F4A51C"), icon-style: 0,
  )
]
#pagebreak()
#align(center + horizon)[
  #quad-step-card(
    number: [02], title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
    width: 4.6cm, height: 4.6cm, colour: rgb("#6BA36C"), icon-style: 1,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #quad-step-card(
    number: [03], title: [خطوة جديدة],
    body: [نص موجز يشرح هذه الخطوة بوضوح ويعرض تفاصيلها العملية بإيجاز مناسب للقارئ.],
    width: 4.6cm, height: 4.6cm, direction: rtl,
    colour: rgb("#38BDD1"), icon-style: 2,
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #quad-step-card(
      number: [04], title: [PRINT SAMPLE],
      body: [Monochrome output retains the halo rings, charcoal icon medallions, and number badge.],
      width: 4.6cm, height: 4.6cm, icon-style: 3,
    )
  ]
]
