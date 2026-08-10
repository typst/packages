#import "/src/lib.typ" as typ

#let invalid = typ.shapes.polygon(
  ((0, 0), (2, 0), (2, 2), (0, 2)),
  anchor: (3, 3),
)
