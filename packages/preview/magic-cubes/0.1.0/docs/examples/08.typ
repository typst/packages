#import "@preview/magic-cubes:0.1.0": *
#set page(width: auto, height: auto, margin: .5cm)

#draw-face(
  apply(
    oll-cube,
    "F R U R' U' F'",
    inverse: true,
  ),
  "u",
)
