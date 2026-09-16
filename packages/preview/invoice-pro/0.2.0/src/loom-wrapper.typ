#import "@preview/loom:0.1.0" as loom

#let loom-key = <invoice-pro:0.2.0>
#let (weave, motif, prebuild-motif) = loom.construct-loom(loom-key)

// The Engine
#let weave = weave

// The Component Constructors
#let managed-motif = motif.managed
#let compute-motif = motif.compute
#let content-motif = motif.content
#let data-motif = motif.data
#let motif = motif.plain

// Prebuild Motifs
#let debug = prebuild-motif.debug
#let apply(..args, body) = compute-motif(
  scope: ctx => ctx + args.named(),
  measure: (_, children) => children,
  body,
)
