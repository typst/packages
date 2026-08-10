#import "/src/lib.typ" as typ

#let broken(label, pad, style) = (kind: "bogus")
#typ.diagram({ typ.node(0, 0, style: (shape: broken)) })
