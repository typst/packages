// Gallery: fun-table — value table with auto-computed values
#import "@preview/functable:0.1.0": fun-table

#set page(width: 14cm, height: auto, margin: 0.8cm)
#set text(size: 10pt)

// Explicit values
#fun-table(
  x-values: ($0$, $pi/6$, $pi/4$, $pi/3$, $pi/2$),
  rows: (
    (label: $sin(x)$, values: ($0$, $1/2$, $frac(sqrt(2),2)$, $frac(sqrt(3),2)$, $1$)),
    (label: $cos(x)$, values: ($1$, $frac(sqrt(3),2)$, $frac(sqrt(2),2)$, $1/2$, $0$)),
  ),
)

#v(0.5em)

// Auto-computed from fn
#fun-table(
  x-values: (-3, -2, -1, 0, 1, 2, 3),
  rows: (
    (label: $f(x) = x^2 - 1$, fn: x => x * x - 1),
    (label: $g(x) = 2x + 1$, fn: x => 2 * x + 1),
  ),
)
