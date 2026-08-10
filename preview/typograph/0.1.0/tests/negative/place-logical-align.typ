#import "/src/lib.typ" as typ

// Logical start/end depend on text direction; diagram placement is physical.
#let invalid = typ.place(0, 0, [x], align: start + top)
