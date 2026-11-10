#import "common.typ": *

#set page(width: 20cm, height: auto, margin: 0.5cm, fill: white)
#set text(size: 11pt)

#let example-auto-layout() = [
  #context display-auto-layout(
    (
      swatch(palette.at(0), "16/9", aspect: 16 / 9),
      swatch(palette.at(1), "1/1", aspect: 1 / 1),
      swatch(palette.at(2), "1/1", aspect: 1 / 1),
      swatch(palette.at(3), "4/3", aspect: 4 / 3),
    ),
    gap: 0.6em,
    selector: "1",
  )
]

#grid(
  columns: (1fr, 1fr, 1fr),
  rows: 7cm,
  gutter: 0.1fr,
  panel(example-auto-layout()),
  panel(width: 100%, height: 4cm, context example-auto-layout()),
  panel(width: 60%, context example-auto-layout()),
)
