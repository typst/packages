// Should fail: edge() needs at least 2 waypoints.
#import "/src/lib.typ" as typ
#typ.diagram({ typ.edge((0, 0)) })
