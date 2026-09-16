#import "common.typ": *

#set page(width: auto, height: auto, margin: 0.5cm, fill: white)
#set text(size: 11pt)

#panel(
  width: 9cm,
  height: 6cm,
  context {
    let sub-sub = framed-group(
      (
        leaf(swatch(palette.at(0), "leaf", aspect: 1.1)),
        leaf(swatch(palette.at(1), "leaf", aspect: 0.9)),
      ),
      axis: "horizontal",
      gap: 0.6em,
      color: frame-colors.at(2),
      label: "sub-sub -- horizontal",
      outset: 1pt,
    )
    let sub-group = framed-group(
      (leaf(swatch(palette.at(4), "leaf", aspect: 1.4)), sub-sub),
      axis: "vertical",
      gap: 0.6em,
      color: frame-colors.at(1),
      label: "sub-group -- vertical",
      outset: 3pt,
    )
    let top = combine(
      (leaf(swatch(palette.at(3), "leaf", aspect: 0.75)), sub-group),
      "horizontal",
      0.6em,
    )
    let top = resolve-stretchable(top, "horizontal")
    box(width: 100%, height: 100%)[
      #layout(size => fit-content-dict(top, size))
    ]
  },
  frame-label: "top-level -- horizontal",
  frame-color: frame-colors.at(0),
)