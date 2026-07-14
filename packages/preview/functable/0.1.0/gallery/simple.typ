// Gallery: simple sign-table without facteurs strip — typical f'(x) table
#import "@preview/functable:0.1.0": sign-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

// Single row: just the f'(x) sign, no factor rows, no strip
#sign-table(
  factors: (
    (zeros: (
      (value: $-2$, approx: -2),
      (value: $1$,  approx:  1),
    ), signs: ("+", "-", "+")),
  ),
  summary-label: $f'(x)$,
  variation: true,
  variation-label: $f(x)$,
  start-value: $-oo$,
  end-value: $+oo$,
  variation-values: (
    (at: -2, label: $3$),
    (at:  1, label: $-6$),
  ),
  show-facteurs: false,
)
