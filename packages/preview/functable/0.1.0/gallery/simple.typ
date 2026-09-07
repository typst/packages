// Gallery: direct signs — typical f'(x)/variation table without factor rows
#import "@preview/functable:0.1.0": sign-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

// Signs given directly (no factors); zeros as plain numbers
#sign-table(
  signs: ("+", "-", "+"),
  zeros: (-2, 1),
  summary-label: $f'(x)$,
  variation: true,
  variation-label: $f(x)$,
  start-value: $-oo$,
  end-value: $+oo$,
  variation-values: (
    (at: -2, label: $3$),
    (at:  1, label: $-6$),
  ),
)
