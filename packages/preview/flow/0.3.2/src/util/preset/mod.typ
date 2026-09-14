// Utilities commonly used in one specific field,
// which would be polluting the scope if imported for all.

#import "arrow.typ"
#import "chem.typ"
#import "math.typ"
#import "ops.typ"
#import "quantum.typ"
#import "sew.typ"

// Backwards compatibility module, should be removed with 0.4.0
#let (ana, calculus, linalg) = (math,) * 3
