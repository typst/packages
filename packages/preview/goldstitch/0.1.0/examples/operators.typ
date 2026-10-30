#import "@preview/goldstitch:0.1.0": goldstone, diagram-signature, kallay-label

#set page(width: 190mm, height: auto, margin: 10mm)
#set text(size: 10pt)
#let panel(code, caption, ..options) = align(center)[
  #goldstone(code, labels: true, ..options)
  #linebreak()
  #caption
  #linebreak()
  #text(size: 8pt)[Signature: #repr(diagram-signature(code))]
]

= Similarity-transformed Hamiltonian diagrams

Signatures are (created particles, created holes, annihilated particles,
annihilated holes), all relative to the reference. Open operator legs are
short stubs: creation upward, annihilation downward. All arrows are shown
in the operator layout. $T$ uses solid bars and filled circles; $H$ uses
dashed lines and open circles. Crossings without a marker are not contractions.

== Bare Hamiltonian: all thirteen vertices

#grid(columns: (1fr,) * 5, gutter: 5mm,
  ..range(13).map(eta => panel((eta,), [Vertex #eta], mode: "operator")),
)

== Partial contractions and scalar terms

#grid(columns: (1fr,) * 3, gutter: 6mm,
  panel("211 10", [Annihilation sector]),
  panel("211 0", [Unused creation legs], mode: "operator"),
  panel("242 10", [Correlation energy], mode: "operator"),
)
