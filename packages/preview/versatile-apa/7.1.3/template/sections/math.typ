#import "@preview/versatile-apa:7.1.3": *
= Math Equations
#lorem(50).

Let $a$, $b$, and $c$ be the side lengths of right-angled triangle. Then, we know that:
#apa-figure(
  $ a^2 + b^2 = c^2 $,
  placement: none,
  kind: math.equation,
  caption: "Right-angled triangle",
)

Prove by induction:
#apa-figure(
  $ sum_(k=1)^n k = (n(n+1)) / 2 $,
  placement: none,
  kind: math.equation,
  caption: "Sum of first n integers",
)

We define:
#apa-figure(
  $ phi.alt := (1 + sqrt(5)) / 2 $,
  label: "ratio",
  placement: none,
  kind: math.equation,
  caption: "Golden ratio",
)

With @ratio, we get:
#figure(
  $ F_n = floor(1 / sqrt(5) phi.alt^n) $,
  placement: none,
  kind: math.equation,
  caption: [Fibonacci number],
)
