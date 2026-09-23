// Before/after: tall inline math wrapping naturally in justified prose.
#import "@preview/breather:0.1.0": breathe

#set page(width: 13cm, height: auto, margin: 6mm)
#set text(size: 11pt)
#set par(leading: 0.6em, justify: true)
#show math.frac: it => math.display(it)

#let prose = [
  The partial sums $sum_(k=1)^n frac(1, k^2)$ converge to $frac(pi^2, 6)$:
  bounding each term by $frac(1, k^2) <= frac(1, k(k-1))$ and telescoping
  gives the bound $1 - frac(1, n)$, so the increasing sequence is bounded
  above and therefore converges. The exact value, $frac(pi^2, 6)$, is
  Euler's celebrated solution to the Basel problem.
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8mm,
  [
    == Without breather
    #prose
  ],
  [
    == With breather
    #show: breathe
    #prose
  ],
)
