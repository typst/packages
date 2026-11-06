// Shared before/after transition presentation.
//
// Tree, heap, linear, and hash operations all use this stable view abstraction.
// Structure-specific operation semantics and multi-panel traces remain in their
// owning domains.

#import "style.typ": resolve, validate-style

#let op-arrow(label, symbol: $arrow.r$, style: (:)) = align(horizon)[
  #validate-style("op-arrow()", style)
  #let resolved-style = resolve(style)
  #set align(center)
  #if label != none [
    #text(..resolved-style.operation-text, label) \
  ]
  #text(size: 1.3em, symbol)
]

#let trans-view(before, label, after, style: (:)) = stack(
  dir: ltr,
  spacing: 1.2em,
  align(horizon, before),
  op-arrow(label, style: style),
  align(horizon, after),
)
