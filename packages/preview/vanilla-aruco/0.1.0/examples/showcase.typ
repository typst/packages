#import "../lib.typ": aruco

#set page(
  width: 27cm,
  height: 18cm,
  margin: 18pt,
  fill: white,
)

#let card(id, dictionary, title) = box(
  width: 5.7cm,
  height: 6.6cm,
  fill: white,
  stroke: 0.7pt + black,
  inset: 12pt,
  stack(
    dir: ttb,
    spacing: 7pt,
    align(center, aruco(
      id,
      dictionary: dictionary,
      size: 3.9cm,
      quiet: 1,
      foreground: black,
      background: white,
    )),
    text(fill: black, weight: "bold", size: 10pt)[#title],
    text(fill: black, size: 7.5pt)[#dictionary],
  ),
)

#align(center + horizon,
  stack(
    dir: ttb,
    spacing: 13pt,
    text(fill: black, size: 24pt, weight: "bold")[vanilla-aruco],
    text(fill: black, size: 10pt)[Rust-powered paths for Typst],
    grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      gutter: 12pt,
      card(7, "DICT_4X4_50", [4x4]),
      card(42, "DICT_5X5_100", [5x5]),
      card(123, "DICT_6X6_250", [6x6]),
      card(999, "DICT_7X7_1000", [7x7]),
    ),
    text(fill: black, size: 8pt)[Native vector output · OpenCV-compatible dictionaries · Euler-tour path compression],
  ),
)
