// Before/after: multi-step fraction derivations separated by `\`.
#import "@preview/breather:0.1.0": breathe

#set page(width: 13cm, height: auto, margin: 6mm)
#set text(size: 11pt)
#set par(leading: 0.6em)
#show math.frac: it => math.display(it)

#let derivation = [
  $A = frac(6, 5) - frac(4, 5) dot frac(5, 9)$\
  $A = frac(54, 45) - frac(20, 45)$\
  $A = frac(34, 45)$\
  Et voilà.
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8mm,
  [
    == Without breather
    #derivation
  ],
  [
    == With breather
    #show: breathe
    #derivation
  ],
)
