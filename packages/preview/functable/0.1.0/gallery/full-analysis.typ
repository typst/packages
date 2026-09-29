// Gallery: full analysis table — f', variation, f'', convexity
#import "@preview/functable:0.1.0": sign-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

#sign-table(
  factors: (
    (expr: $3x^2 - 3$, zeros: (
      (value: $-1$, approx: -1),
      (value: $1$,  approx:  1),
    ), signs: ("+", "-", "+")),
  ),
  summary-label: $f'(x)$,
  variation: true,
  variation-label: $f(x)$,
  start-value: $+oo$,
  end-value: $+oo$,
  variation-values: (
    (at: -1, label: $2$),
    (at:  1, label: $-2$),
  ),
  second-factors: (
    (expr: $6x$, zeros: ((value: $0$, approx: 0),), signs: ("-", "+")),
  ),
  second-summary-label: $f''(x)$,
  convexity: true,
  convexity-label: $f(x)$,
)
