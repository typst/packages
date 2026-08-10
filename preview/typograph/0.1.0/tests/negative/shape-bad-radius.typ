#import "/src/lib.typ" as typ

#let invalid(label, pad, style) = (kind: "circle", radius: -1pt)
#typ.diagram({ typ.node(0, 0, style: (shape: invalid)) })
