// Should fail: a zero coordinate unit cannot be rendered or clipped.
#import "/src/lib.typ" as typ
#typ.diagram(scale: 0, { typ.node(0, 0) })
