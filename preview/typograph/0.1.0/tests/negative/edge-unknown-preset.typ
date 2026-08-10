// Should fail with the available injected ZX preset names.
#import "/src/lib.typ" as typ
#typ.diagram({ typ.edge((0, 0), (1, 0), preset: "missing") })
