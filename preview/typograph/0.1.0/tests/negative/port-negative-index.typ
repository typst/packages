// Should fail: negative indexes are not aliases for ports from the end.
#import "/src/lib.typ" as typ
#let g = typ.gate(0, 0, [U])
#typ.diagram({ typ.edge(typ.port(g, "left", -1), (-1, 0)) })
