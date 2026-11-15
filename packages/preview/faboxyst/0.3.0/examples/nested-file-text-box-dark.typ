// One Nested File Text Box — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 14cm, height: 5.4cm, margin: 0.4cm, fill: rgb("#001F33"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #nested-file-text-box(
    title: [معلومة مفيدة],
    body: [تساعد هذه المساحة على ترتيب الفكرة وشرحها بوضوح، مع عنوان مختصر يسهّل تذكّرها.],
    number: "٠١",
    icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
    print-icon: image("assets/nested-file-lightbulb.png", width: 0.62cm),
    width: 7.5cm,
    height: 2.7cm,
    direction: rtl,
    colour: rgb("#E1B53A"),
    panel-colour: rgb("#001F33"),
    text-colour: white,
    label-colour: white,
  )
]
