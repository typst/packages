#import "/src/lib.typ" as typ

// The origin lies on the lower edge, not strictly inside the outline.
#let invalid = typ.polygon-outline(
  ((-10pt, 0pt), (10pt, 0pt), (10pt, 10pt), (-10pt, 10pt)),
)
