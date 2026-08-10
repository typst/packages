#import "/src/lib.typ" as typ

#let malformed(label, pad, style) = (
  kind: "bare", label-offset: (2pt, 0pt),
)
#typ.diagram({ typ.node(0, 0, label: [x], style: (shape: malformed)) })
