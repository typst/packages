#import "common.typ": *

#set page(width: auto, height: auto, margin: 0.5cm, fill: white)
#set text(size: 11pt)

#let caption(label, color) = (
  body: box(width: 100%, height: 100%, fill: color, radius: 3pt, inset: 6pt)[
    #align(center + horizon, text(fill: white, weight: "bold", size: 10pt, label))
  ],
  aspect: 0,
  constant-size: 3cm,
)

#panel(
  width: 14cm,
  height: 8cm,
  context display-auto-layout(
    (
      (body: image("../assets/placeholder-portrait.jpg"), weight: 5),
      image("../assets/placeholder-landscape.jpg"),
      swatch(palette.at(2), "aspect 4/5", aspect: 4 / 5),
      swatch(palette.at(3), "aspect 3/2", aspect: 3 / 2),
      swatch(palette.at(4), "aspect 1/1", aspect: 1 / 1),
      caption("This arrangement was computed automatically — every photo keeps its original aspect ratio.", frame-colors.at(0)),
    ),
    gap: 0.6em,
    selector: "1",
  ),
)
