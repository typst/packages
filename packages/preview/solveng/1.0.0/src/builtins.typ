#let _operation-displays = state("solveng-binding-displays", (:))
#let _operation-display(name, shown) = _operation-displays.update(d => { d.insert("operation:" + name, shown); d })
/// Shorthands for solveng's operations in math: `tri`, `rect`, `sgn`, `floor`, `ceil`, `convolve`, `range`, `at`, `Re`, `Im`, `conj`, `laplace`, ….
///
/// Import only the ones you use, where you use them: `#import operations: tri, sgn`. Typst imports are lexical, so
/// they apply to that file or block and the ones nested in it; nothing comes along with
/// `#import "@preview/solveng:1.0.0": *`. Without the import, math reads the name as Typst's own (`at` is the
/// symbol @) or as an unknown variable.
///
/// A worksheet's own function of that name wins. `op("tri")` and `operation("convolve")` are the explicit
/// references. Typst's own math operators (`sin`, `exp`, `sqrt`, `abs`, `arg`, …) need no import.
///
/// ```typ
/// #import operations: tri, sgn
/// #show: worksheet
/// $f(t) := tri(t) sgn(t)$, $f(1/2) =$
/// ```

/// ## Built-in operations
///
/// Built-in operations work in worksheet math and graphs. Typst needs a binding for every name it doesn't
/// know in math, and `#import "@preview/solveng:1.0.0": *` brings none: import the ones you use from solveng's
/// `operations` module, `#import operations: tri, sgn` (or `#import operations: *`), then `$tri(t)$`. Like any
/// import, it holds only where it's written, so no name appears in a document unasked. `at` needs it most:
/// without the import, `$at(v, 0)$` is Typst's symbol @. Typst's own math names (`sin`, `sqrt`, `abs`, `arg`,
/// `vec`, …) need no import. A worksheet's own functions take precedence over imported names.
///
/// Explicit references select the underlying operation under a name of your choice: `#let triangle = math.op("tri")`,
/// then `$triangle(x)$`, or directly `$op("tri")(x)$`. Typst's native operation content, such as `math.sin`, is
/// also an explicit reference. The editor completes the operation's name inside `math.op` and highlights the
/// string and its binding's uses in evaluated worksheets. Quoted names such as `$"tri"(x)$` call worksheet
/// functions only; they never select built-in operations.
///
/// For named arguments, use `operation("convolve")`: Typst only parses named math arguments for functions.
/// `operation(name, display: …)` also says how the operation is shown, `display` being a function returning its
/// content.
///
/// ```typ
/// #import "@preview/solveng:1.0.0": *
/// #show: worksheet
/// #let triangle = math.op("tri")
/// #let conv = operation("convolve", display: () => math.op("conv"))
/// $a := triangle(1/2) =$
/// $y := conv(vec(1, 2), vec(1, 1), step: 2) =$
/// ```
///
/// The following operations use Typst's existing math names or syntax:
///
/// | operation | behavior |
/// |---|---|
/// | `sqrt(x)` | Square root; units are square-rooted too: `sqrt(9 #m^2)` is 3 m. Of a negative number it's imaginary: `sqrt(-4)` is 2i. |
/// | `abs(x)` | Absolute value, the magnitude of a complex number; preserves x's unit. |
/// | `arg(z)` | Angle of a complex number in radians, −π…π. |
/// | `exp(x)`, `ln(x)`, `log(x)` | Exponential, natural logarithm and base-10 logarithm. Arguments are unitless; logarithms of negative numbers are complex, `ln(-1)` is iπ, and of 0 undefined. |
/// | `sin(x)`, `cos(x)`, `tan(x)` | Trigonometric functions of a unitless angle in radians. |
/// | `arcsin(x)`, `arccos(x)`, `arctan(x)` | Inverse trigonometric functions; also spelled `asin`, `acos`, `atan`, documented below. |
/// | `sinh(x)`, `cosh(x)`, `tanh(x)` | Hyperbolic functions of a unitless argument. |
/// | `vec(a, b, …)` | Column vector. Use `at(vector, index)` to select a component, starting at 0. |
/// | `mat(a, b; c, d)` | Matrix, rows separated by semicolons, blocks allowed: `mat(A, b)`, `mat(A; B)`. `A B` multiplies, `A^(-1)` inverts, `A^T` transposes, `a times b` is the cross product. Use `at(matrix, row, column)` for an element. |
/// | `det(A)`, `tr(A)`, `norm(v)` | Determinant and trace of a square matrix; length of a vector (‖v‖). |
/// | `cases(value, condition, …, default)` | First matching branch; conditions are unitless, and only the selected value is evaluated. The final default is optional. In math use `cases(0 & t < 0, 1 & "otherwise")`. |
/// | `laplace(expression, variable, result-variable)`, `invlaplace(expression, variable, result-variable)` | Symbolic unilateral transforms. Defaults: t → s and s → t. See their entries below for supported forms. |
/// | `sum(expression, index, lower, upper)` | Sum over inclusive integer bounds; the index is local and unitless. In math use `sum_(k=0)^10 k^2`. Small finite sums simplify exactly; infinite sums stay symbolic with `->` and are evaluated for `=` and graphs. |
///
/// For sums, the upper bound may be `infinity`. Piecewise linear signal sums are counted
/// directly between their corners; other numerical sums use a shrinking-tail convergence
/// estimate with a limit of 100000 terms. Nonconvergent or slower-converging series report an error.
///
/// ```typ
/// #import "@preview/solveng:1.0.0": *
/// #import units: m
/// #show: worksheet
/// $a := sqrt(9 #m^2) =$
/// $b := sum_(k=0)^3 k^2 =$
/// $c := cases(0 & b < 0, b & "otherwise") =$
/// ```

// math.op(name) followed by its arguments, as Typst writes a call: what the worksheet reads as an explicit
// reference ⦇name⦈(…), selecting an underlying operation
#let _op-call(name, args, implicit: false, display: auto) = {
  // the colon of a named argument as a class of its own: no parameter type to show as a chip
  let parts = args.pos() + args.named().pairs().map(((k, v)) => [#k] + math.class("normal", [:]) + h(0.25em) + v)
  let shown = if display == auto { math.op(name) } else if type(display) == function { display() } else if type(display) == str { math.op(display) } else { display }
  let body = [#(if display != auto { _operation-display(name, shown) })#metadata(name)#shown]
  let o = [#body<solveng-operation>]
  // a comma and a space between arguments: 1, 10 (without the space, 1,10 reads as a decimal comma)
  let body = parts.join(math.class("punctuation", [,]) + h(0.17em))
  $#o (#body)$.body
}

/// Rectangular pulse: `rect(x)` is 1 for |x| < ½, ½ at x = ±½, and 0 otherwise.
///
/// The argument and result are unitless. Shift and scale the argument to place a pulse:
/// `$p(t) := rect((t-2)/4)$` has width 4 and is centered at 2.
/// `$rect(1/2) =$` gives ½. Integrals split at the pulse boundaries; derivatives stay symbolic.
///
/// - x (expression): Unitless position relative to the pulse center.
/// -> unitless value
#let rect = [#math.op("rect")<solveng-builtin-operation>]

/// Triangular pulse: `tri(x)` is max(1 − |x|, 0), with height 1 at 0 and support from −1 to 1.
///
/// The argument and result are unitless. `$p(t) := tri((t-2)/4)$` is centered at 2 and
/// reaches zero at −2 and 6. `$tri(1/4) =$` gives ¾. Integrals split at its corners;
/// the first derivative is piecewise constant and undefined at the three corners.
///
/// - x (expression): Unitless position relative to the pulse center.
/// -> unitless value
#let tri = [#math.op("tri")<solveng-builtin-operation>]

/// Greatest integer less than or equal to x: `floor(x)`.
///
/// The argument and result are unitless. Used for finite time-delay sums.
/// Its derivative stays symbolic.
///
/// - x (number): Unitless real value.
/// -> integer
#let floor = [#math.op("floor")<solveng-builtin-operation>]

/// Least integer greater than or equal to x: `ceil(x)`.
///
/// The argument and result are unitless. Typst's math writes it ⌈x⌉, which solveng reads as well.
/// Its derivative stays symbolic.
///
/// - x (number): Unitless real value.
/// -> integer
#let ceil = [#math.op("ceil")<solveng-builtin-operation>]

/// Factorial of a nonnegative integer: `factorial(k)`.
///
/// Zero factorial is 1. Values through 33! are exact; larger values can be
/// evaluated numerically through 170!. Its derivative stays symbolic.
///
/// - k (integer): Nonnegative unitless integer.
/// -> number
#let factorial = [#math.op("factorial")<solveng-builtin-operation>]

/// Sign function: `sgn(x)` is −1 for x < 0, 0 for x = 0, and 1 for x > 0.
///
/// The argument and result are unitless. `$sgn(-3) =$` gives −1.
/// Its distributional derivative stays symbolic.
///
/// - x (expression): Unitless value whose sign to take.
/// -> unitless value
#let sgn = [#math.op("sgn")<solveng-builtin-operation>]

/// Real part of a complex number: `Re(3 + 4 #i)` is 3. Keeps the unit: `Re(Z)` of an impedance is its
/// resistance. Real numbers are their own real part.
///
/// - z (expression): A complex or real value.
/// -> value
#let Re = [#math.op("Re")<solveng-builtin-operation>]

/// Imaginary part of a complex number: `Im(3 + 4 #i)` is 4, a real number. Keeps the unit: `Im(Z)` of an
/// impedance is its reactance. Real numbers have the imaginary part 0.
///
/// - z (expression): A complex or real value.
/// -> value
#let Im = [#math.op("Im")<solveng-builtin-operation>]

/// Complex conjugate: `conj(3 + 4 #i)` is 3 − 4i, shown with a bar. Keeps the unit.
///
/// The magnitude is `abs(z)` and the angle is Typst's own `arg(z)`, in radians from −π to π; both need no
/// import.
///
/// - z (expression): A complex or real value.
/// -> value
#let conj = [#math.op("conj")<solveng-builtin-operation>]

/// A value as a plain number in a unit: `number(U, mV)` is U in millivolts, without a unit.
///
/// The value must have the unit's dimension – `number(U, #A)` of a voltage is an error – so the number always
/// means what it says. Dividing by the unit, `U / mV`, gives the same number but lets any unit through; use
/// `number` where a formula needs a value in a given unit, like an empirical one:
/// `$F(d) := 3.2 number(d, mm)^0.6 #N$`.
///
/// - value (expression): The value, with a unit.
/// - unit (expression): The unit to express it in: a unit binding or an expression of them (`#m / #s`).
/// -> number
#let number = [#math.op("number")<solveng-builtin-operation>]

/// Symbolically differentiates an expression with respect to a name: `diff(expression, variable)`.
///
/// `$diff(x^3, x) ->$` gives 3x². The variable is local to the operation, so an existing
/// worksheet value for it does not replace it while differentiating. Unsupported piecewise
/// or distributional derivatives stay symbolic and cannot be evaluated numerically.
///
/// In math, Leibniz's notation does the same: `$(dif x^3)/(dif x) ->$`, `$dif/(dif x) x^3 ->$`,
/// higher orders `$(dif^2 f(x))/(dif x^2)$` and partial derivatives `$(partial^2 f(x, y))/(partial x partial y)$`.
/// `dif/(dif x)` applies to the term after it: `$dif/(dif x) x^2 + x ->$` is 2x + x. A worksheet shows
/// `diff(f, x)` in Leibniz's notation, d/dx f.
///
/// - expression (expression): Expression to differentiate.
/// - variable (name): Differentiation variable, written as a name rather than a value.
/// -> expression
#let diff = [#math.op("diff")<solveng-builtin-operation>]

/// Integral: `integrate(expression, variable)` is the antiderivative, `integrate(expression, variable, lower, upper)`
/// the definite integral.
///
/// `$integrate(x^2, x, 0, 3) =$` gives 9, `$integrate(x^2, x) ->$` gives x³/3. The variable is local to the
/// operation.
///
/// Without bounds the result is an antiderivative, without a constant of integration: `$integral #e^x dif x ->$`
/// gives eˣ, `$integral x^2 sin(x) dif x ->$` gives −x² cos(x) + 2x sin(x) + 2 cos(x). It is found for sums of
/// constants times powers, exponentials, sin, cos, sinh, cosh, ln and tan of a linear argument; for products that
/// multiply out into such terms; and by parts for a polynomial times one exponential, sin, cos, sinh or cosh of a
/// linear argument. Other integrands (`sin(x^2)`, `#e^x cos(x)`, rational functions other than 1/(a x + b))
/// report an error.
///
/// With bounds, the bounds must have matching units (0 and ±∞ match any); the result has the integrand's unit
/// times the variable's unit. Either bound may be infinite. Recognized antiderivatives simplify exactly where they
/// are continuous between the bounds; remaining integrals stay symbolic with `->` and use adaptive quadrature for
/// `=` or graphs. Affine signal arguments are split at their corners so narrow pulses are not skipped. Undefined
/// integrands or failure to converge report an error.
///
/// In math, `$integral_0^3 x^2 dif x =$` and `$integral x^2 dif x ->$` do the same. The differential (`dif`, not
/// `diff`, which is ∂) ends the integrand wherever it stands: `$integral_0^1 x^2 + 1 dif x$` integrates x² + 1,
/// `$integral_0^1 (x dif x) + 1$` adds 1 to the integral, `$integral_0^1 (dif x)/(1 + x^2)$` and
/// `$integral_0^1 dif x$` are integrals too. A bound of 0 or ±∞ takes the other bound's unit
/// (`$integral_0^(2 #s) 3 #A dif t$`); when both are, write the unit on one:
/// `$integral_(0 #s)^infinity #e^(-t/tau) dif t$`. A worksheet shows `integrate(…)` as the integral sign.
///
/// - expression (expression): Integrand.
/// - variable (name): Integration variable, written as a name rather than a value.
/// - lower (expression): Lower bound, including `-infinity`; none for an antiderivative.
/// - upper (expression): Upper bound, including `infinity`; none for an antiderivative.
/// -> expression or value
#let integrate = [#math.op("integrate")<solveng-builtin-operation>]

/// Convolution: `convolve(x, h)` of two sequences, `convolve(f(τ), g(τ), τ, t)` of two functions.
///
/// Of sequences (vectors) it is the discrete convolution, (x ∗ h)ₖ = Σᵢ xᵢ hₖ₋ᵢ, with n + m − 1
/// elements; `step: Δt` multiplies it by the sampling step, the Riemann sum of the continuous convolution of
/// the sampled signals. Of functions it is (f ∗ g)(t) = ∫ f(τ) g(t − τ) dτ over the whole line, τ local to
/// the operation. Without `at`, the result is in the variable itself: `convolve(rect(t), rect(t), t)` is
/// `tri(t)`. Piecewise polynomial signals – `rect`, `tri`, `sgn`, `abs`, `cases` steps, polynomials, with
/// numeric affine arguments such as `tri((τ - 2 s)/(4 s))` – convolve exactly into a piecewise polynomial;
/// `$y(t) := convolve(tri(tau), tri(tau), tau, t) ->$` shows the five pieces, `$y(1/2) =$` gives 23/48.
/// Other signals (exp, sin, symbolic shifts) stay the integral, evaluated numerically for `=` and graphs.
/// Units multiply: the result has f's unit times g's unit (times τ's unit, or the step's).
///
/// - f (expression): A sequence (vector), or a function of the variable.
/// - g (expression): A sequence (vector), or a function of the variable.
/// - variable (name): The integration variable of a convolution of functions.
/// - at (expression): Where the convolution of functions is taken, usually the result's variable; default: the variable.
/// - step (expression): Named: the sampling step of sequences, the result is multiplied by it.
/// -> vector or expression
#let convolve = (..args) => _op-call("convolve", args, implicit: true)

/// Values from start to end, as Typst's range: `range(end)`, `range(start, end, step: 1)`, the end left out.
///
/// `$range(0, 1, step: 1/4)$` is `vec(0, 1/4, 1/2, 3/4)`. Values may have a unit, then the step needs it too:
/// `$range(0 #s, 1 #s, step: 250 ms)$`. The bounds and the step need values when the range is defined. A
/// range variable, as Mathcad writes it, includes the end: `$i := 0 .. N$` (or `0...N`) counts from 0 to N in
/// steps of 1. Used as an index, `$x[i] := tri(t[i])$` defines an element for each value. In Typst code
/// (`#for i in range(5)`), `range` stays Typst's own.
///
/// - start (expression): The first value; default 0 with one argument.
/// - end (expression): The bound, not included.
/// - step (expression): Named: the distance between values, default 1; negative counts down.
/// -> vector
#let range = (..args) => if args.pos().all(a => type(a) in (int, float)) and args.named().values().all(a => type(a) in (int, float)) { std.range(..args) } else { _op-call("range", args, implicit: true) }

/// Selects a vector component with a zero-based index: `at(vector, index)`, or a matrix
/// element: `at(matrix, row, column)`.
///
/// `$at(vec(3, 5), 0) =$` gives 3. The index must be a nonnegative integer smaller
/// than the number of components. This also selects a solution from a function that
/// returns several solutions as a vector. The selected component keeps its unit.
///
/// - vector (expression): A vector or matrix, including the result of a function returning a vector.
/// - index (int): Component number, or the row of a matrix, starting at 0.
/// - column (int): Column of a matrix element, starting at 0.
/// -> expression or value
#let at = [#math.op("at")<solveng-builtin-operation>]

/// Inverse sine, also spelled `arcsin`: `asin(x)` returns an angle in radians from −π/2 to π/2.
///
/// The argument is unitless; outside [−1, 1] the result is the principal complex value (`asin(2)` is
/// 1.571 − 1.317i). `$asin(1) =$` gives π/2.
///
/// - x (expression): Unitless sine value.
/// -> unitless angle in radians
#let asin = [#math.op("asin")<solveng-builtin-operation>]

/// Inverse cosine, also spelled `arccos`: `acos(x)` returns an angle in radians from 0 to π.
///
/// The argument is unitless; outside [−1, 1] the result is the principal complex value.
/// `$acos(1) =$` gives 0.
///
/// - x (expression): Unitless cosine value.
/// -> unitless angle in radians
#let acos = [#math.op("acos")<solveng-builtin-operation>]

/// Inverse tangent, also spelled `arctan`: `atan(x)` returns an angle in radians between −π/2 and π/2.
///
/// The argument and result are unitless. `$atan(1) =$` gives π/4.
///
/// - x (expression): Unitless tangent value.
/// -> unitless angle in radians
#let atan = [#math.op("atan")<solveng-builtin-operation>]

// Native operation documentation is also read by the IDE. Each @builtin marker
// names the operation documented by the preceding /// comment.

/// Square root: `sqrt(x)` returns the principal square root of x.
///
/// Units are square-rooted too: `sqrt(9 #m^2)` is 3 m. The root of a negative number is imaginary: `sqrt(-4)`
/// is 2i.
/// - x (expression): Value, optionally with units.
// @builtin sqrt

/// Absolute value: `abs(x)` removes the sign and preserves x's unit; of a complex number, its magnitude.
///
/// `abs(-3 #V)` is 3 V, `abs(3 + 4 #i)` is 5.
/// - x (expression): Value whose magnitude to take.
// @builtin abs

/// Angle of a complex number: `arg(z)` in radians, from −π to π.
///
/// `arg(#i)` is π/2, `arg(-2)` is π. The argument may carry a unit (the angle of an impedance); the result is
/// unitless. `arg(0)` has no value.
/// - z (expression): Complex or real value whose angle to take.
// @builtin arg

/// Exponential: `exp(x)` is e raised to the power x.
///
/// The argument and result are unitless. `exp(0)` is 1.
/// - x (expression): Unitless exponent.
// @builtin exp

/// Natural logarithm: `ln(x)` is the inverse of `exp(x)`.
///
/// The argument must be unitless and not 0. `ln(e)` is 1; of a negative number it's complex, `ln(-1)` is iπ.
/// - x (expression): Unitless value.
// @builtin ln

/// Base-10 logarithm: `log(x)` is the exponent giving x as a power of 10.
///
/// The argument must be unitless and not 0; of a negative number it's complex. `log(100)` is 2.
/// - x (expression): Unitless value.
// @builtin log

/// Sine of a unitless angle in radians: `sin(x)`.
///
/// `sin(pi/2)` is 1. The result is unitless and lies in [−1, 1].
/// - x (expression): Unitless angle in radians.
// @builtin sin

/// Cosine of a unitless angle in radians: `cos(x)`.
///
/// `cos(0)` is 1. The result is unitless and lies in [−1, 1].
/// - x (expression): Unitless angle in radians.
// @builtin cos

/// Tangent of a unitless angle in radians: `tan(x) = sin(x)/cos(x)`.
///
/// `tan(0)` is 0. The function has poles at π/2 + kπ; the result is unitless.
/// - x (expression): Unitless angle in radians, away from a pole.
// @builtin tan

/// Hyperbolic sine: `sinh(x) = (exp(x) - exp(-x))/2`.
///
/// The argument and result are unitless. `sinh(0)` is 0.
/// - x (expression): Unitless value.
// @builtin sinh

/// Hyperbolic cosine: `cosh(x) = (exp(x) + exp(-x))/2`.
///
/// The argument and result are unitless. `cosh(0)` is 1.
/// - x (expression): Unitless value.
// @builtin cosh

/// Hyperbolic tangent: `tanh(x) = sinh(x)/cosh(x)`.
///
/// The argument and result are unitless. `tanh(0)` is 0.
/// - x (expression): Unitless value.
// @builtin tanh

/// Column vector: `vec(a, b, …)` keeps the components in the written order.
///
/// Components can carry units. Use `at(vector, index)` to select a component,
/// starting at 0: `at(vec(3, 5), 1)` is 5.
/// - ..components (expression): Vector components, in order.
// @builtin vec

/// Piecewise expression: `cases(value, condition, …, default)` selects the first matching branch.
///
/// Conditions must be unitless; nonzero means true. Only the selected value is evaluated.
/// The final default is optional; without a matching branch the value is undefined.
/// In math use `cases(0 & t < 0, 1 & "otherwise")`.
/// - ..branches (expression): Alternating values and conditions, optionally followed by a default value.
// @builtin cases

/// Inclusive integer sum: `sum(expression, index, lower, upper)`.
///
/// The index is local and unitless. Bounds are unitless integers; the upper bound may be
/// `infinity`. In math use `sum_(k=0)^10 k^2`. Small finite sums simplify exactly;
/// infinite sums stay symbolic with `->` and are evaluated for `=` and graphs.
/// Piecewise linear signals are counted directly between their corners. Other numerical
/// sums use a shrinking-tail convergence estimate and report an error after 100000 terms.
/// - expression (expression): Summand; it may carry units.
/// - index (name): Local summation index, written as a name.
/// - lower (expression): Inclusive lower integer bound.
/// - upper (expression): Inclusive upper integer bound, or `infinity`.
// @builtin sum

/// Unilateral Laplace transform: `laplace(expression, variable, result-variable)`.
///
/// The variables default to t and s: `$laplace(t^2) ->$`, `$F(p) := laplace(exp(-x), x, p)$`.
/// (The keyword form `-> laplace` was removed; it's an error pointing here.)
/// A worksheet shows the call as ℒ{f}, with the result variable as ℒ{f}(p) when it's given; `invlaplace` as ℒ⁻¹{F}.
/// The input variable is local, so a worksheet value for it is ignored.
/// Supports constants, polynomials through degree 33, affine exponentials,
/// sine, cosine, hyperbolic sine and cosine, linear combinations, exponential
/// shifts and multiplication by powers of the input variable (up to 20).
/// Also supports `rect(a*t)`, `tri(a*t)` and `sgn(a*t)` for nonzero a,
/// and shifted affine signal arguments with known real numeric coefficients.
/// These are unilateral transforms: only the signal at t >= 0 contributes.
/// For example, `laplace(rect(t))` is (1 − exp(−s/2))/s and
/// `laplace(tri(2*t))` is 1/s − 2(1 − exp(−s/2))/s².
/// Define `$Lambda(t) := tri(t)$` before using Λ as the triangular signal.
/// Parameters are formal constants; results apply in the half-plane of convergence.
/// The result variable must differ from the input and must not occur in the input
/// expression. Unsupported transforms report an error; no numerical transform is used.
///
/// - expression (expression): Function to transform.
/// - variable (name): Input variable, t by default.
/// - result-variable (name): Output variable, s by default.
/// -> expression
#let laplace = [#math.op("laplace")<solveng-builtin-operation>]

/// Inverse unilateral Laplace transform: `invlaplace(expression, variable, result-variable)`.
///
/// The variables default to s and t: `$invlaplace(1/s^2) ->$`, `$f(x) := invlaplace(1/(p+1), p, x)$`.
/// (The keyword form `-> invlaplace` was removed; it's an error pointing here.)
/// Proper rational functions are inverted symbolically using repeated poles,
/// quadratic factors and exact partial fractions where available. The general
/// numerical evaluator uses a state-space matrix exponential, including complex
/// poles and repeated irreducible factors; it does not require numerical roots.
///
/// Rational delay expressions `N(s,q)/D(s,q)`, with `q = exp(-d*s)`, are handled
/// by formal power-series division and causal shifts. Delays must be commensurate
/// rational numbers. Products, powers, `e^x` and hyperbolic functions are normalized
/// before inversion. The constant delay coefficient D_0(s) must be nonzero;
/// each numerator coefficient must have lower degree in s than D_0, and no
/// denominator coefficient may have higher degree. Polynomial parts requiring
/// Dirac distributions remain unsupported.
///
/// Separable delay denominators use generating-function partial fractions to
/// produce exact finite sums when their delay poles can be determined exactly.
/// Other supported inverses remain written as `invlaplace(...)` and can be
/// evaluated or graphed. Numerical evaluation uses at most 256 delay intervals
/// and a state dimension of 128; exceeding these limits reports an error.
///
/// For a system taking `rect(t)` to `tri(2*t)`, shift both signals to preserve
/// their negative-time parts under the unilateral transform:
/// `$x(t) := rect(t-1/2)$`, `$y(t) := tri(2*(t-1/2))$`,
/// `$H(s) := laplace(y(t), t, s)/laplace(x(t), t, s) ->$`, then
/// `$g_2(t) := invlaplace(H(s)/s, s, t) ->$` gives the step response.
/// It is a periodic triangular wave: 0 at integer times and 1 at half-integers.
/// Results describe the causal function for t >= 0.
/// The input variable is local. The output name must be distinct and absent from
/// the input expression. Unsupported forms report an error.
/// Arrow transforms cannot be combined with `solve` or a second transform keyword.
///
/// - expression (expression): Expression in the transform domain.
/// - variable (name): Input variable, s by default.
/// - result-variable (name): Output variable, t by default.
/// -> expression
#let invlaplace = [#math.op("invlaplace")<solveng-builtin-operation>]

/// Matrix: `mat(a, b; c, d)`, commas between the elements of a row and semicolons between rows.
///
/// Elements can carry units and names. A matrix of one column is a vector, the same as `vec(…)`.
/// Elements that are matrices are blocks: `mat(A, b)` puts A and b side by side, `mat(A; B)`
/// puts B below A, `mat(A, 0; 0, B)` builds a block diagonal from scalars and blocks.
///
/// Everything else is Typst's math notation. `+` and `−` work element by element (a scalar is
/// added to every element); products follow the written order: `A B` is the matrix product,
/// `A v` a matrix times a vector, `v dot w` or `v w` the dot product of two vectors, `v^T A` a row
/// times a matrix, and `a times b` the cross product of two vectors of 3 components. `A^n` is a
/// whole power of a square matrix, `A^(-1)` its inverse, `A^T` or `A^top` its transpose, `|A|` its
/// determinant; `|v|` and `norm(v)` are the length of a vector. `A^(-1) b` solves the system
/// A x = b without forming the inverse, and `A vec(x, y) = b -> solve(x, y)` solves a matrix
/// equation element by element.
///
/// Determinants, inverses and systems are exact for exact numbers and formulas for names. With
/// units, every row and column needs a unit of its own (element = row unit · column unit), as in
/// physical matrices: a resistance matrix inverts to conductances. Names without a value are
/// scalars until they get one.
/// - ..rows (expression): Elements or blocks, row by row.
// @builtin mat

/// Determinant of a square matrix: `det(A)`, also written `|A|`.
///
/// Exact for exact numbers, a formula for names: `$det(mat(a, b; c, d)) ->$` gives a d − b c.
/// With units, the determinant has the product of the row and column units.
/// - matrix (expression): A square matrix.
// @builtin det

/// Trace of a square matrix: `tr(A)`, the sum of its diagonal.
/// - matrix (expression): A square matrix.
// @builtin tr

/// Norm: `norm(v)`, written ‖v‖, is the length of a vector and the Frobenius norm of a matrix
/// (the root of the sum of its squared elements); of a number, its absolute value.
/// - x (expression): A vector, matrix or number.
// @builtin norm

/// Rank of a matrix: `rank(A)`, the number of independent rows.
///
/// Exact for exact numbers; floats count as zero within rounding of the largest element.
/// - matrix (expression): A vector or matrix.
/// -> integer
#let rank = [#math.op("rank")<solveng-builtin-operation>]

/// Identity matrix: `identity(n)` has n rows and columns, ones on the diagonal.
/// - n (int): Number of rows and columns, 1 or more.
/// -> matrix
#let identity = [#math.op("identity")<solveng-builtin-operation>]

/// Number of rows of a vector or matrix: `rows(A)`.
/// - matrix (expression): A vector or matrix.
/// -> integer
#let rows = [#math.op("rows")<solveng-builtin-operation>]

/// Number of columns of a vector or matrix: `cols(A)`; a vector has 1.
/// - matrix (expression): A vector or matrix.
/// -> integer
#let cols = [#math.op("cols")<solveng-builtin-operation>]
