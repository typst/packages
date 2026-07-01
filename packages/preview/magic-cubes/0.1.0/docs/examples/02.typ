#import "@local/magic-cubes:0.1.0": *
#set page(width: auto, height: auto, margin: .5cm)

#draw_cube(
  apply(
    cube(),
    "R U R' U'",
  ),
)

