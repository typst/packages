#import "@preview/vanilla-aruco:0.1.0": aruco

#set page(margin: 2cm)

= vanilla-aruco

The default dictionary is compatible with OpenCV's `DICT_4X4_50`.

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1.2cm,
  ..range(6).map(id => aruco(id, size: 3.2cm)),
)

The path backend can also rotate a marker or use another predefined dictionary:

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1.2cm,
  aruco(7, size: 3cm, rotation: 90),
  aruco(7, size: 3cm, foreground: rgb("16324f")),
  aruco(42, dictionary: "DICT_6X6_250", size: 3cm),
)
