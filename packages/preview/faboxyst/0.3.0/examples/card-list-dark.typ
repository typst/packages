// One Card List item — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 11.5cm, margin: 0.35cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #card-list-box(
    title: [فكرة مميزة],
    body: [تعرض هذه البطاقة الفكرة بوضوح، وتترك مساحة لشرحها بإيجاز مع رمز بصري يرسخ معناها.],
    icon: image("assets/card-list-briefcase-cyan.png", width: 1.65cm),
    print-icon: image("assets/card-list-briefcase-black.png", width: 1.65cm),
    width: 4.8cm,
    height: 6.8cm,
    direction: rtl,
    backplate-colour: rgb("#38BEDC"),
    panel-colour: white,
    title-colour: rgb("#161616"),
    text-colour: rgb("#565A5E"),
    tilt: 12deg,
  )
]
