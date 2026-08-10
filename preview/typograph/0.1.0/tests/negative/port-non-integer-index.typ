// Should fail: a port index must be an integer.
#import "/src/lib.typ" as typ
#let g = typ.gate(0, 0, [U])
#typ.diagram({ typ.edge(typ.port(g, "left", 0.5), (-1, 0)) })
