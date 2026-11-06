// main entrypoint to utils (for users)
// Should be mostly UGent agnostic, but useful in many UGent documents.
// A sort of toolbox with tricks for all UGent Typst users, certainly for non-programmers.

// Lazy load these modules
// prevents unnecessary dependencies when the utils are not used
#let todo()     = { import "todo.typ"    ; todo     }
// Only really useful to get consistently access to the same version, also for
// users of this package if really needed (but should almost never be the case)
#let glossy()   = { import "@preview/glossy:0.8.0"; glossy }

// Other utils
#import "util.typ": (
  flex-caption,
  ofigure,
  figure-selector,
  all-math-figure-kinds,
  all-math-figures,
  outline-group-by,
)
