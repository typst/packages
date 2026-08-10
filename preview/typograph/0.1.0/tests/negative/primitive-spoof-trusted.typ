#import "/src/lib.typ" as typ
#let spoof(label, pad, style) = (
  kind: "polygon",
  points: ((10pt, 10pt), (12pt, 10pt), (11pt, 12pt)),
  label-offset: (0pt, 0pt),
  _trusted: true,
)
#typ.shapes.build-outline(
  spoof,
  (width: 0pt, height: 0pt),
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  typ.node-defaults,
)
