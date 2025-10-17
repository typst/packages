#import "@preview/tidy:0.1.0"
#import "@preview/cetz:0.4.1": canvas
#import "lib.typ": riesketcher, trapezoidal
// #import "@preview/riesketcher:0.4.0": riesketcher, trapezoidal

#set text(size: 10.5pt)

= Riesketcher
A package to draw Riemann sums (left, right, midpoint, and trapezoidal) and their plots for functions using CeTZ; supports tagged and untagged partitions.
```typst
#import "@preview/riesketcher:0.4.0": riesketcher, trapezoidal
```

#show raw.where(lang: "example"): it => block({
  table(columns: (50%, 50%), stroke: none, align: (center + horizon, left),
    align(left, raw(lang: "typc", it.text)),
    eval("canvas({" + it.text + "})", scope: (canvas: canvas, riesketcher: riesketcher, trapezoidal: trapezoidal))
  )
})

== Examples
=== Left-Hand Riemann sum

```example
riesketcher(
    x => calc.pow(x, 3) + 4,
    method: "left",
    start: -3.1,
    end: 3.5,
    n: 10,
    plot-x-tick-step: 1,
)
```

=== Midpoint Riemann sum

```example
riesketcher(
    x => -calc.pow(x, 2) + 9,
    method: "mid",
    domain: (-4, 4),
    start: -3,
    end: 3,
    n: 6,
    plot-x-tick-step: 1,
)
```

=== Right-method Riemann sum

```example
riesketcher(
    x => 16 - x * x,
    method: "right",
    end: 6,
    n: 6,
    domain: (-1, auto),
    plot-x-tick-step: 1,
)
```

=== Custom untagged partition (midpoint method)

```example
riesketcher(
  x => 0.17 * calc.pow(x, 3)
    + 1.5 * calc.sin(calc.cos(x)),
  method: "mid",
  partition: (-3, -1.5, -0.75, -0.2, 0.8, 1.5,
    2.3, 3.4),
  plot-x-tick-step: 2,
)
```

=== Tagged partition

```example
riesketcher(
  x => 0.5 * calc.pow(x, 3)
    - 0.9 * calc.cos(x),
  partition: (-3.2, -2.1, -1.1, 0.4, 0.9, 1.7,
    2.4, 3.5),
  tags: (-2.5, -1.9, -0.35, 0.63, 1.38, 2.06, 3.14),
  plot-x-tick-step: 2,
)
```

#pagebreak()

=== Trapezoidal Rule (uniform grid)

```example
trapezoidal(
  x => calc.pow(x, 3) + 4,
  start: -3,
  end: 3.5,
  n: 7,
  plot-x-tick-step: 1,
  positive-color: rgb("#210aa4")
)
```

=== Trapezoidal Rule (non-uniform grid)

```example
trapezoidal(
  x => -calc.pow(x, 3) - 4,
  partition: (-3, -0.4, 2, 3.1, 3.5),
  plot-x-tick-step: 1,
  positive-color: rgb("#210aa4")
)
```

#pagebreak()
#set align(left)

== Method parameters

#let riesketcher-tidy = tidy.parse-module(read("riesketcher.typ"), name: "riesketcher")
#tidy.show-module(riesketcher-tidy)

#pagebreak()

#let trapezoidal-tidy = tidy.parse-module(read("trapezoidal.typ"), name: "trapezoidal")
#tidy.show-module(trapezoidal-tidy)
