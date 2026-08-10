#import "/src/lib.typ" as typ

#let malformed(label, pad, style) = (
  kind: "circle", radius: 5pt, label-offset: (1, 2),
)
#typ.diagram({ typ.node(0, 0, style: (shape: malformed)) })
