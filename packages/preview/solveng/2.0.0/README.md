# solveng

Engineering calculations in Typst math. `:=` defines a worksheet variable or function, `=>` shows its value as ⇒, and `->` shows an exact symbolic result or solves an equation. Values carry their units.

```typ
#import "@preview/solveng:2.0.0": *
#import units: mA, mAh, h
#import modifiers: solve
#show: worksheet

$Q_0 := 3450 mAh$, $I := 30 mA$
$t := Q_0 / I => #h$
$Q_0/2 = I t -> solve(t)$
```

## Imported values

Units, constants, operations and modifiers use Typst's lexical bindings. Import the ones you use from `units`, `constants`, `operations`, or `modifiers`. Imports follow Typst's normal file and block scopes; worksheet scope does not change their meaning. Single-letter bindings need `#` in math, for example `$2 #s$` and `$#e^x$`.

```typ
#import "@preview/solveng:2.0.0": *
#import units: m, s
#import constants: pi, e, c
#import operations: tri
#show: worksheet

$P := 2 pi =>$
$"velocity" := #c =>$
$f(x) := #e^x$
$tri(1/4) =>$
```

A base unit identifies an independent dimension. Declarations with the same identity describe the same dimension, even in different files or worksheets. Derived units contain expressions of unit values:

```typ
#import "@preview/solveng:2.0.0": *
#let second = base-unit("time", display: () => math.upright("s"))
#let minute = unit($60 second$, display: () => math.upright("min"))
#show: worksheet
$t := 2 minute = second$
```

`constant(identity, expression)` names a value. The identity says what the constant is, independent of the binding's name; the expression is what it stands for and can carry units. The engine calculates exactly with the identities `"pi"`, `"euler"` and `"imaginary"` once the expression has their value; any other identity is kept by its identity in exact results (`$E := m #c^2 ->$` is m c²) and calculated with its expression. `-> substitute(#c)` puts the expression in, and for a constant alone shows it as written: `$#i -> substitute(#i)$` is √−1.

How a constant is shown belongs to the worksheet, not to the binding: the option `constant-displays` maps identities to content, over built-in displays for `pi` (π), `euler` (e), `imaginary` (i) and `speed-of-light` (c). Nested worksheets add to the displays around them. Results use the same displays, also for constants the engine produces itself, like the π of an integral or the i of a complex solution. An identity without a display is shown as its expression.

```typ
#import "@preview/solveng:2.0.0": *
#import units: m, s, kg
#let g0 = constant("standard-gravity", $9.80665 #m / #s^2$)
#let triangle = operation("tri", display: () => math.op("triangle"))
#show: worksheet.with(constant-displays: ("standard-gravity": $g_0$))
$F := 2 kg #g0 =>$
$triangle(1/2) =>$
```

`display` says how a unit or operation is shown: content (`display: $"in"$`), a string (`display: "in"`, set upright) or a function returning content. It changes presentation without changing meaning. Binding names retain their spelling; a unit named `tau` is not renamed to `τ`. Names with underscores or hyphens need `#` in math (`$1 #fluid_ounce$`), because Typst otherwise reads subscripts or subtraction. A unit without a display shows its expression, written as results are: `unit($2.54 #cm$)` is 2.54 cm, in the input and in results alike. Such a display is one unit: next to a number it is joined by a dot (1 · 2.54 cm), and under a power or after a slash it is parenthesized ((2.54 cm)², m/(2.54 cm)).

```typ
#import "@preview/solveng:2.0.0": *
#import units: cm
#let inch = unit($2.54 #cm$)
#let inches = unit($2.54 #cm$, display: $"in"$)
#show: worksheet
$a := 3 #inch = inch$
$b := 3 inches => cm$
```

## Complex numbers

Values are complex numbers: `$sqrt(-4) =>$` and `$sqrt(-4) ->$` are 2i, also when `i` isn't written; operations keep their real value where they have one, so `(-8)^(1/3)` is −2. `#import constants: i` brings the imaginary unit, `constant("imaginary", $sqrt(-1)$)`, and results show it as the worksheet says even where it isn't imported. Exact arithmetic stays exact (`(1 + 2i)(3 - i) -> 5 + 5i`, `#e^(#i pi) -> -1`), values carry units, and solving gives complex solutions (`$x^2 + 4 = 0 -> solve(x)$` is ±2i). Graphs, comparisons with `<`, inequalities and the numeric search need real values. `Re`, `Im` and `conj` come from `operations`; `abs` is the magnitude and `arg` the angle. Electrical engineers write `j`:

```typ
#import "@preview/solveng:2.0.0": *
#import units: Ω, Hz, mH
#import constants: pi, i
#import operations: Re, Im
#import modifiers: substitute
#show: worksheet.with(constant-displays: (imaginary: $j$))

$Z := 100 #Ω + #i 2 pi 50 Hz dot 300 mH =>$
$abs(Z) =>$, $arg(Z) =>$, $Im(Z) =>$
$#i -> substitute(#i)$
```

There is no worksheet unit table or automatic constant/function lookup. The former `units`, `builtin-units`, and `builtin-functions` worksheet options and string unit constructors are removed. Solveng code blocks are ordinary raw text and are not calculated or offered as an editor conversion.

Symbolic equalities also try a bounded exact proof in a common exponential form: `$sin(x)^2 + cos(x)^2 = 1 ->$` is true, as are Euler's formula and supported combinations of exponentials, trigonometric functions and `sinc`. Affine piecewise guards and the continuation of `sinc` at zero are checked separately. Pulse Fourier integrals produce compact `sinc` forms directly; opposite exponential phases combine into cosine or sine and common envelopes factor out. Guarded quotients become cardinal functions only when their exceptional values agree. Unsupported identities stay symbolic; numeric samples are never used as a proof.

## Worksheets and results

`#show: worksheet` calculates the remaining math. `#worksheet[…]` starts an isolated worksheet; `scope: "inherit"` reads outer definitions and `scope: "shared"` also keeps its changes. Every `worksheet` defaults to isolated scope, even with a single equation. Use `#calculate($x := 1$)` to update the current worksheet. `hidden: true` hides calculations, and `evaluate: false` leaves ordinary math alone.

Use `#value($expression$)` for a result in text, `#defined()` to list definitions, and `#clear("x")` or `#clear(all: true)` to forget worksheet definitions. The modifiers after a result marker – `solve`, `substitute`, `simplify`, `expand`, `factor`, `steps`, `digits`, `sci`, `eng` and `fraction` – are bindings of the `modifiers` module and only come from it: `#import modifiers: solve, digits` (renamed imports such as `solve as löse` work too). `any`, the type of a parameter that takes every unit, comes with the package import.

The engine supports symbolic algebra, complex numbers, real calculus, matrices, finite and convergent infinite sums, signal operations, Laplace transforms, and graphs. Symbolic calculus also provides `taylor(expression, variable, center, degree)` (degree 0–32), `jacobian(vector, variables)` and `hessian(expression, variables)`. Import these from `operations`; variable vectors contain distinct names and determine column order. Taylor coefficients require derivatives defined at the center; the polynomial makes no convergence claim.

Numerical engineering operations include least squares, matrix spectra and condition numbers, sample statistics, interpolation, regression, sampled Fourier transforms, bounded scalar minimization, and scalar non-stiff ODEs. Absolute temperature readings use `celsius` and `fahrenheit`; `degC` remains a temperature difference. Unit targets are expressions too: `preferred-units: ($#m / #s$,)` or `compile($U^2/R$, parameters: (U: $#V$), result-unit: $#W$)`.

Editor completions and import quick fixes follow bindings re-exported by local templates, including renamed imports. Highlighting also recognizes template functions that forward their content into nested worksheets or apply a worksheet show rule. Conditional or dynamically computed layouts use the compiler report when their behavior cannot be determined from the source.

Solving returns solutions without changing definitions: `$x^2 = 4 -> solve(x)$` leaves `x` undefined. To retain all branches explicitly, write `$roots := x^2 = 4 -> solve(x)$`, then select a branch with `at(roots, 0)`. Numeric search results are available in the calculation report; solved definitions currently require symbolic isolation.

Canonical numerical operations include `pnorm`, `qnorm`, `linear-solve`, `linear-interpolate`, and `linear-fit`.

## Development

Run `cargo test --workspace` for the engine and editor. Build the Typst plugin with `plugin/build.sh`. Generate unit exports with `python3 scripts/unit-words.py`; `--check` verifies the generated module. `python3 tests/examples.py` checks documented examples.
