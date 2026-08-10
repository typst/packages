#import "/src/lib.typ" as typ

// A fragment is not one endpoint; silently taking its first node would hide a
// diagram-construction mistake.
#typ.edge(typ.node(0, 0) + typ.box(1, 0), (2, 0))
