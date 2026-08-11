// Gallery: rational function — pole (valeur interdite), broken arrows, HD hatching
#import "@preview/functable:0.1.0": sign-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

#sign-table(
  factors: (
    (expr: $x + 1$, zeros: ((value: $-1$, approx: -1),), signs: ("-", "+")),
    (
      expr: $x - 2$,
      zeros: ((value: $2$, approx: 2, pole: true),),
      signs: ("-", "+"),
    ),
  ),
  summary-label: $f(x)$,
  variation: true,
  variation-label: $f(x)$,
)
