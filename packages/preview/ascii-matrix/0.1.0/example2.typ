#import "@preview/ascii-matrix:0.1.0": make-ascii-matrix

#let covering = (
  ("col", 0, 10, blue, "0x1"),
  ("row", 5, 5, blue, "0x1"),
  ("row", 7, 7, blue, "0x1"),
  ("col", 1, 15, yellow, "0x2"),
  ("row", 4, 4, yellow, "0x2"),
  ("row", 6, 6, yellow, "0x2"),
  ("col", 1, 9, green, "               0x4"),
  ("row", 3, 3, green, "0x4"),
)

#let intersection = (
  ((1, 4), (15, 4), yellow.transparentize(85%)),
  ((1, 6), (15, 6), yellow.transparentize(85%)),
  ((0, 5), (10, 5), blue.transparentize(85%)),
  ((0, 7), (10, 7), blue.transparentize(85%)),
  ((1, 3), (9, 3), green.transparentize(85%)),
)


#set text(
  font: (
    (name: "Arial Unicode MS", covers: regex("[\u2400-\u243f]")),
    "Menlo", // macOS
    "Consolas", // Windows
    "DejaVu Sans Mono", // Linux
    "Roboto Mono", // Android
  ),
  size: 10pt,
  fallback: true,
)
#set page(width: auto, height: auto, margin: 1em)

#make-ascii-matrix(covering, intersection)
