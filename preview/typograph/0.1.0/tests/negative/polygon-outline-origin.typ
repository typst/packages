#import "/src/lib.typ" as typ

// Clipping assumes every ray starts inside the outline.
#let invalid = typ.polygon-outline(
  ((10pt, 10pt), (20pt, 10pt), (20pt, 20pt), (10pt, 20pt)),
)
