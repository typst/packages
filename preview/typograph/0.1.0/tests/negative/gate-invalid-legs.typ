// Should fail before layout with a targeted gate validation error.
#import "/src/lib.typ" as typ
#typ.gate(0, 0, [U], legs: (left: -1))
