// One reusable frame-accent block — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 7.2cm, margin: 0.45cm, fill: rgb("#002334"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
