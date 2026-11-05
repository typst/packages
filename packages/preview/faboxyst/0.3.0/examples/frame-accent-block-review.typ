// Visual review: one framed feature block per page, no slide-grid layout.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 7.2cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #frame-accent-block(
    title: [Focused Insight],
    body: [Give one useful observation room to stand out, then add concise details that support it.],
    icon: image("assets/frame-accent-bulb.svg", width: 1.05cm),
    width: 4.1cm,
    square-size: 2.5cm,
    offset: 0.34cm,
    body-height: 1.55cm,
    direction: ltr,
    colour: rgb("#FFA91F"),
  )
]

#pagebreak()
#set page(fill: rgb("#002334"))
#align(center + horizon)[
  #frame-accent-block(
    title: [فكرة مركّزة],
    body: [اترك للفكرة المهمة مساحة واضحة، ثم أضف إليها تفاصيل موجزة تدعمها.],
    icon: image("assets/frame-accent-bulb.svg", width: 1.05cm),
    width: 4.1cm,
    square-size: 2.5cm,
    offset: 0.34cm,
    body-height: 1.55cm,
    direction: rtl,
    dark: true,
    colour: rgb("#35BFD0"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #frame-accent-block(
      title: [Focused Insight],
      body: [Give one useful observation room to stand out, then add concise details that support it.],
      icon: image("assets/frame-accent-bulb.svg", width: 1.05cm),
      width: 4.1cm,
      square-size: 2.5cm,
      offset: 0.34cm,
      body-height: 1.55cm,
      direction: ltr,
      colour: rgb("#FFA91F"),
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #frame-accent-block(
      title: [فكرة مركّزة],
      body: [اترك للفكرة المهمة مساحة واضحة، ثم أضف إليها تفاصيل موجزة تدعمها.],
      icon: image("assets/frame-accent-bulb.svg", width: 1.05cm),
      width: 4.1cm,
      square-size: 2.5cm,
      offset: 0.34cm,
      body-height: 1.55cm,
      direction: rtl,
      colour: rgb("#FFA91F"),
    )
  ]
]
