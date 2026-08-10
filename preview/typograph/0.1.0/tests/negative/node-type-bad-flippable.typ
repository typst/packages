// Should fail: flippable is a plain boolean switch.
#import "/src/lib.typ" as typ
#let invalid = typ.node-type("x", flippable: "yes")
