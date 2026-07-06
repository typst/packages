#import "@preview/magic-cubes:0.1.0": *
#set page(width: auto, height: auto, margin: .5cm)

#draw-cube(
  apply(
    f2l-cube,
    inverse: true,
    "U R U' R'",
  ),
)
