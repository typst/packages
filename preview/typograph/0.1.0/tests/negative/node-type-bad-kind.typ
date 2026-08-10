// Should fail: kinds are stable string style keys.
#import "/src/lib.typ" as typ
#let invalid = typ.node-type(42)
