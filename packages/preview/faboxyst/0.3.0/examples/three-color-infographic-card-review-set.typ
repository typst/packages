// Review set: preserve the standalone card and demonstrate the shared-ribbon
// composition in LTR, RTL, and print variants.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 14cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #three-color-infographic-card(
    title: [YOUR TEXT HERE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
    width: 10.2cm,
    height: 4cm,
    colour: rgb("#4B84BE"),
  )
]
#pagebreak()
#align(center + horizon)[
  #three-color-infographic-stack(
    width: 10.2cm,
    card-height: 3.7cm,
    overlap: 0.66cm,
    spine-overhang: 0.38cm,
    spine-width: 1.12cm,
    spine-colour: rgb("#E3E1DE"),
    cards: (
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#4B84BE")),
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#CA5209")),
      (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#C78D00")),
    ),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #three-color-infographic-stack(
    width: 10.2cm,
    card-height: 3.7cm,
    overlap: 0.66cm,
    spine-overhang: 0.38cm,
    spine-width: 1.12cm,
    direction: rtl,
    spine-side: "start",
    spine-colour: rgb("#E3E1DE"),
    cards: (
      (title: [عنوان أول], body: [نص موجز يشرح الفكرة الأولى ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#4B84BE")),
      (title: [عنوان ثان], body: [نص موجز يشرح الفكرة الثانية ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#CA5209")),
      (title: [عنوان ثالث], body: [نص موجز يشرح الفكرة الثالثة ويعرض أهم تفاصيلها للقارئ.], colour: rgb("#C78D00")),
    ),
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #three-color-infographic-stack(
      width: 10.2cm,
      card-height: 3.7cm,
      overlap: 0.66cm,
      spine-overhang: 0.38cm,
      spine-width: 1.12cm,
      spine-colour: rgb("#E3E1DE"),
      cards: (
        (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#4B84BE")),
        (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#CA5209")),
        (title: [YOUR TEXT HERE], body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.], colour: rgb("#C78D00")),
      ),
    )
  ]
]
