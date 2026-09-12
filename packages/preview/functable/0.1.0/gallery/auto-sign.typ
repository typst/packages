// Gallery: sign-table with fn — fully automatic sign/variation table
#import "@preview/functable:0.1.0": sign-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

// f(x) = x³ − 3x, f'(x) = 3(x+1)(x−1), f''(x) = 6x
// All signs inferred automatically from fn:
#sign-table(
  factors: (
    (
      expr: $x + 1$,
      zeros: ((value: $-1$, approx: -1),),
      fn: x => x + 1,
    ),
    (
      expr: $x - 1$,
      zeros: ((value: $1$, approx: 1),),
      fn: x => x - 1,
    ),
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
    (
      expr: $6x$,
      zeros: ((value: $0$, approx: 0),),
      fn: x => 6 * x,
    ),
  ),
  second-summary-label: $f''(x)$,
  convexity: true,
  convexity-label: $f(x)$,
)
