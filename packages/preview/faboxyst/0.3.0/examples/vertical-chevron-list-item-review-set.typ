// Four individual row checks: navy LTR, reversed, Arabic RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 5cm, margin: 0.45cm, fill: rgb("#F0EEF0"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [01], title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.],
    width: 11cm, height: 1.55cm, colour: rgb("#103C51"),
  )
]
#pagebreak()
#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [02], title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc.],
    width: 11cm, height: 1.55cm, badge-side: "end",
    colour: rgb("#F58F17"), number-colour: rgb("#8B4B08"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #vertical-chevron-list-item(
    number: [03], title: [خطوة جديدة],
    body: [نص موجز يشرح الخطوة بوضوح ويعرض تفاصيلها العملية بإيجاز مناسب للقارئ.],
    width: 11cm, height: 1.55cm, direction: rtl,
    badge-side: "start", colour: rgb("#35B9DA"),
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #vertical-chevron-list-item(
      number: [04], title: [Lorem Ipsum],
      body: [Monochrome print preserves the chevron badge and rounded text panel.],
      width: 11cm, height: 1.55cm, badge-side: "end",
    )
  ]
]
