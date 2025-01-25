= Down

Pass down arguments of `sum`, `integral`, etc. to the next line, which can generate shorthand to present reusable segments. While writing long step-by-step equations, only certain parts of a line change. `down` leverages Typst's `context` (from version 0.11.0) to help relieve the pressure of writing long and repetitive formulae.

Import the package:

```typ
#import "@preview/down:0.1.0": *
```

== Usage

Create new contexts by using camel-case commands, such as `Limit(x, +0)`. Retrieve the contextual with `cLimit`.

- `Limit(x, c)` and `cLimit`:

```typ
$
Lim(x, +0) x ln(sin x)
  = cLim ln(sin x) / x^(-1)
  = cLim x / (sin x) cos x
  = 0
$
```

- `Sum(index, lower, upper)` and `cSum`:

```typ
$
Sum(n, 0, oo) 1 / sqrt(n + 1)
  = Sum(#none, 0, #none) 1 / sqrt(n)
  = cSum 1 / n^(1 / 2)
$
```

- `Integral(lower, upper, f, dif: [x])`, `cIntegral(f)` and `cIntegrated(f)`:

```typ
$
Integral(0, pi / 3, sqrt(1 + tan^2 x))
  = cIntegral(1 / (cos x))
  = cIntegrated(ln (cos x / 2 + sin x / 2) / (cos x / 2 - sin x / 2))
  = ln (2 + sqrt(3))
$
```

Refer to `./sample.pdf` for more complex application.
