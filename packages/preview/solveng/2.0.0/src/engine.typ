// The engine: solveng calculates in a WebAssembly plugin (Rust, in core/ and plugin/ of the repository). Here math
// is read as written for it, the worksheet's definitions are kept in a state as the bytes it gives back, and what
// it returns – Typst math markup – is shown.
/// ## Calculating like Mathcad
///
/// Three operators, and `=` keeps its meaning from maths:
///
/// - **`:=` defines**, symbolically. Names defined by then are put in right away, names that aren't stay names until they are: `$h := 5 z$` works before `z` is defined, and after `$z := 20 cm$`, `$h =>$` shows 1 m. What's put in is the value at that point – defining a name again later changes what comes after, not what came before.
/// - **`=` inside an expression compares**, as Mathcad's bold =: `$M := 1 = 2 =>$` gives 0, `$M := 2 #A = 2000 mA$` gives 1. Values of different units are never equal (`1 A = 2 V` is 0, `1 A != 2 V` is 1); `<`, `<=`, `>`, `>=` and `!=` compare too, chains like `$0 < x <= 1$` hold when every step does. `and` and `or` (Typst shows ∧ and ∨) join them, `and` binding tighter: `$x < 0 or x > 2$`, also as a condition in `cases`.
/// - **A trailing `=` shows the value**, numerically, with a bold =. After it come a unit and modifiers (from `modifiers`): `$t => #h, digits(3)$`. Every name in it must have a value by then.
/// - **A trailing `->` shows the symbolic result**: defined values put in, exactly (fraction-style, roots and π stay), undefined names kept: `$x + 3/3 y -> simplify$` is x + y. An equation shows where it holds: `$a^2 p = a p ->$` is a = 0 ∨ a = 1 ∨ p = 0 (one side zero, in factors, each factor zero); `steps` shows the way there, a line each. `expand` multiplies out, `factor` splits into factors: `$x^3 - x -> factor$` is x (x − 1)(x + 1). With `solve(x)` it solves – symbolically when it can (`$0 = 1 + 3/x + y^2 -> solve(x)$` is x = −3/(y² + 1)), numerically when every other name has a value – and defines x when the solution is a value. `substitute(U, …)` shows the result with these variables' formulas put in and every other name kept: after `$U := R I$`, `$P := U^2/R -> substitute(U)$` is I² R.
/// - **Any other `=`** states something: it's checked when everything in it has a value (`$U = R I$`), and left alone as prose when not (`$E = m c^2$`).
///
/// **Exact identities:** equations also try a bounded proof in a common exponential form: `$sin(x)^2 + cos(x)^2 = 1 ->$`, Euler's formula, angle addition and supported combinations of exponentials, hyperbolic functions and sinc. Affine piecewise guards and the continuation at zero are checked separately. A quotient such as sin(x)/x becomes sinc(x) only with a matching continuation at zero; an unguarded quotient retains its excluded point. Unsupported identities stay symbolic. Numerical samples never establish a symbolic identity.
///
/// **Functions** are defined the same way: `$f(x) := x^2 + 1$`. Their body is symbolic too, so a function needn't define everything it uses: names that aren't parameters and aren't defined stay names, looked up when the function is evaluated, and cancel where the algebra lets them (`$U(x: #m) := h x a$`, then `$g(x: #m) := U(x)/a ->$` is `1 m · x` without any `a`). Undefined function calls stay symbolic too: `$f(t) := integral_(-infinity)^t sigma(tau) dif tau$` is valid before `sigma` is defined; numerical evaluation requires its definition and convergence. A parameter can have a unit, `f(I: mA)`: arguments must carry its dimension (`f(2 mA)` is valid, `f(2)` reports a missing unit); `any` takes every unit. `..` makes the body's other undefined names parameters, in the order they appear: `$P(..) := U^2/R$` is `P(U, R)`. A parameter passed on to one with a unit takes that unit: with `$q(x: #A) := 2 x$`, `$f(y) := q(y)$` makes y an A. **Named parameters** have a default value and are passed by name, as in Typst: after `$f(x, n: 2) := x^n$`, `$f(3) =>$` is 9 and `$f(3, n: 3) =>$` is 27; a named argument that isn't a parameter, a positional one passed by name and one passed twice are errors. After the colon, an expression made only of unit bindings is a type (`I: mA`, `v: #m / #s`), anything else a default (`n: 2`, `R: 2 #Ω`, `s: k`). Defaults are taken where the function is defined, as Typst evaluates them, and come after the other parameters.
///
/// ```typ
/// #import units: cm, m, A, V
/// #show: worksheet
/// $h := 5 z$, $z := 20 cm$, $h =>$             // h ≔ 5z, z ≔ 20 cm, h = 1 m
/// $U(x: #m) := h x a ->$                     // U(x) ≔ h x a → 1 m · a x
/// $g(x: #m) := U(x)/a ->$                    // g(x) ≔ U(x)/a → 1 m · x
/// $M := 1 #A = 2 #V ->$                      // M ≔ 1 A = 2 V → 0
/// $k := 2 #m = 200 cm =>$                     // k = 1: the comparison holds
/// ```
///
/// ## Writing values
///
/// ```typ
/// #import units: kΩ, A, V, m, mA, mAh, s
/// #import modifiers: substitute
/// #show: worksheet
/// $R := 4.7 kΩ$                                 // a number and a unit
/// $I := frac(2, 4) #A$, $Q_0 := 3450/2 mAh$     // arithmetic in the number
/// $U := (1+2) dot 1.5 #V$, $A := 2^3 #m^2$      // A the variable, #A the ampere
/// $U_2 := R dot 1 mA$
/// $Q := U_2 dot 2 #s -> substitute(U_2)$        // U_2's formula put in: Q ≔ U_2 · 2 s → 1/500 A·s·R
/// ```
///
/// - **Units** are Typst bindings, imported from solveng's `units` module where you use them: `#import units: mA, kΩ, s`. It has the SI base units (m kg s A K mol cd), V Ω W J C F H S Hz N Pa T Wb, min h Ah Wh As Ws eV l L, rad, deg (°) and degC (°C, a temperature *difference*), with the SI prefixes (`mA`, `kΩ`, `µs`). In math a binding of one letter needs a `#` (`$2 #s$`, `$100 #Ω$`), longer ones don't (`$30 mA$`). Powers as `#m^2`, quotients as `#m / #s^2`, products with spaces, `kg #m`. Your own with `base-unit` and `unit`, see [Units](#units).
/// - **Numbers from values:** dividing by a unit gives a value's number in it, checked and prefix-aware: `U / #V` is U's number in volts, `(U / #V) #A` gives it another unit. Empirical formulas are written this way: `$F(d: mm) := 3.2 (d / mm)^0.6 #N$`. `number(U, #mV)` from `operations` is U's value in mV as a plain number, an error when U doesn't have mV's dimension.
/// - **Typeable spellings:** `Omega` is Ω, the prefix `u` is µ (`uA`, also `µA` and `μA`), `deg` and `degC` are ° and °C. Results show the proper symbols.
/// - **Decimal point:** numbers are written with a point, `$7.2 #V$`, also in German documents; results use the document language's decimal-separator (option `decimal-separator`), so they show 7,2 there. A comma always separates: `at(A, 0,1)` and `mat(2,4,6)` are lists of numbers.
/// - **No e-notation:** numbers are written out (`$11200$`, or `$1.12 dot 10^4$`). `1.12e4` is the coefficient 1.12 times the variable `e4` (undefined unless defined; quote it, `$"e4"$`, for a name of several letters). Scientific notation is only how results are written (option `notation-thresholds`, keyword `sci`).
/// - **Names:** the acute accent `´` and the backtick (`` ` ``) are literal name characters (`$x´ := 3$`), with no escaping needed. Digits continue a name: `t2` differs from `t_2` and keeps its digits on the baseline. Complete Latin letter runs normalize to Greek: `Delta2tau` → Δ2τ, while `Deltatau` stays unchanged. `""` joins name fragments: `Delta""tau` → Δτ and `t""2` → t2. Quotes only carry a name through Typst: `$"Delta2tau"$` names Δ2τ, and `$"Delta\"\"tau"$` names Δτ. Quoted text is always a name, also when it spells a unit or an operation: `$"mA" := 3$` is a variable. Explicit subscripts may be grouped: `$R_(a b)$` names R_ab. Operators and whitespace end a name; a leading number remains a coefficient (`2t2` is 2 times t2).
/// - **Sums:** `sum_(k=0)^10 k^2` or `sum(k^2, k, 0, 10)` sums over inclusive integer bounds. The index is local and case-sensitive. Parenthesize a summand containing addition. Small finite sums simplify exactly; infinite sums stay symbolic after `->` and are evaluated numerically for `=` and graphs. For example, `$s_2(t) := sum_(k=0)^infinity sigma(t-k+3/4)$` defines a function usable as `#graph($s_2(t)$)` once `sigma` is defined. Piecewise linear signal sums are counted directly between their corners. Other numerical sums use at most 100000 terms, a shrinking-tail check and guarded epsilon extrapolation; unresolved or nonconvergent series report an error. Bounds and the index are unitless, while summands may carry units.
/// - **Signals:** `rect(x)` is 1 for |x| < ½, ½ at ±½, otherwise 0; `tri(x)` is max(1 − |x|, 0); `sgn(x)` is −1, 0 or 1. Arguments are unitless. Import the names from `operations` (`#import operations: rect, tri, sgn`); a worksheet function such as `$Lambda(t) := tri(t)$` or `#let triangle = math.op("tri")` gives another name. Linear combinations simplify and can be solved; definite integrals of them (also times exponentials, sin or cos) are exact piecewise, over ±∞ too where they vanish outside a bounded interval. Distributional derivatives stay symbolic.
/// - **Ranges and elements:** `$i := 0..N$` (also `0 .. N`, `0...N`) is a range variable: the values from 0 to N in steps of 1, both included, counting down when N < 0; with units, use `range(start, end, step: …)`. `x[i]` and `A[i, j]` are elements, counted from 0, written right after the name without a space; a vector of indices selects several (`x[i]` with i a range is a vector). `:` selects a whole row or column: `A[i, :]` is row i (a matrix of one row), `A[:, j]` column j (a vector), both plottable as data: `#graph($A[1, :]$)`. `$x[i] := …$` defines an element for each value of the range variable i, the body calculated with i standing for that value: `$t[i] := i Delta""t$`, `$x[i] := tri(t[i])$`. Elements not defined yet are 0; defining one past the end extends the vector, as in Mathcad. `A[i, j] := …` defines a matrix.
/// - **Convolution:** `convolve(x, h)` of sequences and `convolve(f(τ), g(τ), τ, t)` of functions, see `convolve`. Sequences of values are convolved numerically (whole numbers exactly), so long sampled signals stay fast; functions exactly where they're piecewise polynomial.
/// - **Operators:** `+ - * / ^ · ×`, implicit multiplication (`2 pi f C`), Typst's math operators `sqrt exp ln log sin cos tan arcsin arccos arctan sinh cosh tanh abs arg` (no import needed), the other operations from `operations` (see [Built-in operations](#built-in-operations)), your own functions.
/// - **Constants** come from solveng's `constants` module: `#import constants: pi, e, i, c` (π, Euler's e, the imaginary unit, the speed of light), then `$2 pi$`, `$#e^x$`, `$3 + 4 #i$`. Without the import `pi` is only the symbol π, a name without a value. `constant(identity, expression)` makes your own; the option `constants` says how they are shown.
///
/// ## Complex numbers
///
/// Values are complex numbers: `$sqrt(-4) =>$` is 2i, `$ln(-1) ->$` is iπ, also without `i` written. Operations keep their real value where they have one, so `(-8)^(1/3)` is −2; elsewhere they take their principal value. `#import constants: i` brings the imaginary unit to write them, and results show it whether imported or not.
///
/// - **Exact** numbers stay exact: `(1 + 2i)(3 − i)` → 5 + 5i, `e^(iπ)` → −1; sin and cos are exact at multiples of 30° and 45°.
/// - **Units:** complex values carry units like any other, `(100 + 94.25i) Ω`.
/// - **Parts:** `abs(z)` is the magnitude, `arg(z)` the angle in radians (−π…π); `Re`, `Im` and `conj` come from `operations` (`#import operations: Re, Im, conj`).
/// - **Solving** is complex: `$x^2 + 4 = 0 -> solve(x)$` gives ±2i, polynomials with numbers get all their roots (`$x^3 = 8 -> solve(x)$`: 2 and −1 ± 1.732i). The numeric search for other equations finds real solutions only.
/// - **Showing:** electrical engineers write `j`: `#show: worksheet.with(constant-displays: (imaginary: $j$))`.
/// - **Real only:** graphs, `compile`, comparisons with `<` and `>`, inequalities and the numeric search need real values; a complex one there is an error.
///
/// ```typ
/// #import units: Ω, Hz, mH
/// #import constants: pi, e, i
/// #import operations: conj
/// #import modifiers: solve
/// #show: worksheet.with(constant-displays: (imaginary: $j$))
/// $(1 + 2 #i)(3 - #i) ->$                       // 5 + 5j
/// $#e^(#i pi) ->$, $sin(pi/4) ->$               // −1, √2/2
/// $Z := 100 #Ω + #i 2 pi 50 Hz dot 300 mH =>$    // (100 + 94.25j) Ω
/// $abs(Z) =>$, $arg(Z) =>$, $conj(Z) =>$           // 137.4 Ω, 0.7558, (100 − 94.25j) Ω
/// $x^2 - 2 #i x - 2 = 0 -> solve(x)$            // x₁ = −1 + j, x₂ = 1 + j
/// ```
///
/// ## Units
///
/// Units, constants, operations and modifiers are Typst bindings, so solveng never guesses what a name means: in math `A` is a variable and, after `#import units: A`, `#A` is the ampere; quoted text (`$"mA"$`) is always a variable. Imports are lexical: they hold in the file or block where they're written and the blocks nested in it, whatever worksheet is around, and nothing comes along with `#import "@preview/solveng:2.0.0": *`. A unit binding hides a Typst function of the same name in code: after `#import units: h`, spacing is `std.h(1em)`.
///
/// After a trailing `=` or `->`, the unit to show is an expression of unit values too: `$t => #h$`, `$v -> km/#h$`, `$P => mW, digits(2)$`. Without one, results are shown in the unit of the option `preferred-units` (`preferred-units: ($#m / #s$,)`), else in a unit of the inputs, else in SI units with a prefix.
///
/// ```typ
/// #import units: Hz, ms, A, s
/// #show: worksheet
/// $A := 12$, $x := A dot 2 #A =>$        // x ≔ A · 2 A = 24 A
/// $T := 2 #s$, $f := 1/T => Hz$          // f ≔ 1/T = 0.5 Hz
/// $T -> ms$                             // 2000 ms
/// ```
///
/// **Units of your own.** `base-unit(identity, display: …)` creates a unit of a new, independent dimension; base units with the same identity are the same dimension, also in other files and worksheets. `unit(expression, display: …)` defines a unit as an expression of unit values with a positive scale: `unit($60 #s$)` is a minute. `display` is a function returning the unit's content; it changes how the unit is shown, not what it means. Like every binding, they hold wherever the binding is visible, in every worksheet.
///
/// ```typ
/// #import units: kPa, min
/// #let bit = base-unit("information", display: () => math.upright("bit"))
/// #let byte = unit($8 bit$, display: () => math.upright("B"))
/// #let bar = unit($100 kPa$, display: () => math.upright("bar"))
/// #let rpm = unit($1/min$, display: () => math.upright("rpm"))
/// #show: worksheet
/// $d := 3 byte = bit$, $p := 3 bar$, $n := 3000 rpm$
/// #worksheet(preferred-units: ($bar$,), scope: "inherit")[$p/2 =>$]   // results of this dimension in bar
/// ```
///
/// ## How it solves
///
/// solveng calculates in a WebAssembly plugin written in Rust (`core/` in the repository). Equations are solved symbolically first, other names as parameters: an unknown that occurs once is isolated; an equation that is a polynomial in it, once both sides are over one denominator, is solved by formula up to degree 2 and by numerical polynomial roots above; parameterized higher-degree solutions remain deferred until their coefficients are known; a system is solved one equation at a time where an equation has a single unknown, and by elimination where it's linear. Polynomial equations are solved in the complex numbers; general numerical searches find real roots. Results are simplified: like terms combined, fraction-style cancelled (`(x^2 - 1)/(x - 1)` is x + 1), exact numbers kept exact. What can't be done symbolically is solved numerically, once every other name has a value: sign changes over ±10⁻¹⁵…10¹⁵ (times the target unit) are bisected and Newton starts from every local minimum of the absolute value; systems by damped Newton from 41 starts. Units of unknowns are inferred from the equations; mismatched units stop with an error.
///
/// A solved definition keeps its solutions: `circle(x, r) := x^2 + b^2 = r^2 -> solve(b)` returns a vector of both branches. A relation function can supply the equation: `p(a, b, c) := a^2 + b^2 = c^2`, then `circle(x, r) := p(x, b, r) -> solve(b)`. The solve variable is local, not a parameter. One solution returns a scalar; several return a vector, with `at(vector, 0)` selecting its first component. Graphing a vector plots every branch. Solved definitions require a symbolic solution; equations in `vec(...)` with several solve variables return components in the requested order, nested by branch when needed.
/// ## Numerical engineering operations
///
/// Import these operations from `operations`. They use the same explicit references,
/// worksheet function scopes and deferred definitions as existing operations; plain
/// unbound names do not select a built-in. Canonical names are `singularvals`,
/// `pnorm` and `qnorm`; `singularvals` provides the complete singular-value spectrum.
/// The operation source comments also supply editor hover and parameter help.
///
/// Numerical decompositions allow dimensions up to 256 and at most 10000 iterations.
/// The direct O(n²) DFT allows 2048 samples. ODE integration uses RK4 step doubling
/// with a 100000-step budget, relative tolerance 1e-10, and absolute tolerance 1e-12
/// times max(|initial|, 1e-12) in SI values. These are numerical estimates, not interval
/// proofs or guarantees that a problem is well conditioned. Nonconvergence, invalid
/// domains, inconsistent units and finite-range overflow report errors.
///
/// Infinite series combine the existing compensated sum and shrinking-tail check
/// with Wynn epsilon extrapolation on geometrically spaced partial sums. Several
/// adjacent extrapolation windows must agree before an accelerated result is accepted.
/// The 100000-term budget remains; this numerical convergence estimate does not
/// certify arbitrary series.
///
/// For symbolic results, `assume(x > 0)` (also `<`, `<=`, `>=`, and `= 0`) supplies
/// local real sign information. For example `sqrt(x^2) -> assume(x > 0)` is x and
/// `sqrt(x^2) -> assume(x < 0)` is −x. Contradictory constraints and incompatible known
/// values are errors. Assumptions do not persist and are shadowed by bound variables.
/// Unrestricted complex simplification retains branch restrictions.
///
/// Real rational polynomial inequalities use a sign chart at every real root and
/// pole, retaining open/closed endpoints and disconnected components. For example,
/// `x^2 < 1 -> solve(x)` gives −1 < x < 1 and `x^2 > 1 -> solve(x)` gives x < −1 or
/// x > 1. These set-valued results do not assign a representative value to x. Affine
/// single-boundary inequalities keep the existing scalar boundary behavior.
///
/// ## Limits
///
/// - **Numbers** are exact fraction-style as long as they fit (128-bit numerator and denominator), else 64-bit floats: about 15 significant digits, magnitudes up to 10³⁰⁰.
/// - **Isolating** `sqrt(x) = 2` gives only the positive root, periodic functions only the principal value (`tan(x) = 1` → `arctan(1)`); polynomials like `x^2 = 4` give all their roots.
/// - **Symbolically**, polynomials have radical formulas through degree 2; higher-degree parameterized solutions retain numerical root operations until their coefficients have values. Simplifying cancels common factors of exact polynomials and proves supported entire trigonometric/hyperbolic identities; unsupported identities stay symbolic. Logarithm and square-root branch restrictions are preserved.
/// - **Numeric search** can miss roots squeezed between nearby poles, roots of very fast oscillations, and roots outside ±10¹⁵ (scaled by the target unit); the result then says "no real solution".
/// - **Systems** are solved numerically from a fixed set of starts; solutions far away from them can be missed. Underdetermined systems show one arbitrary solution.
/// - **Domains:** values are complex, with the real value where there is one: `sqrt(-1)` is i, `(-8)^(1/3)` is −2. Higher-degree polynomial solutions with parameters are deferred until coefficients have values.
/// - **Complex numbers:** numerical polynomial roots use bounded iteration and can lose root-location accuracy near repeated or clustered roots; real-root isolation uses derivative roots to recover repeated real locations. Graphs, `compile`, numeric solving and inequalities need real values, and complex numbers have no order (`<` on them is an error).
/// - **°C** (`degC`) is a temperature difference. Use `celsius(reading)` or `fahrenheit(reading)` for explicit absolute-temperature conversion to kelvin; temperatures in formulas like `p V = n R T` use these Kelvin values.
/// - **Unit expressions** take whole-number powers (`#m^2`, `#s^(-1)`); fractional ones (`#m^(1/2)`) aren't units.
/// - **Functions** can't call themselves.
/// - **Ranges** have at most 100000 values, and their bounds and steps need values when they're defined. In math an index follows its name directly, so `a[b + c]` is an element of a – write `a dot [b + c]` or `a (b + c)` for a product.
/// - **Convolution** of functions is exact for piecewise polynomials with numeric breakpoints (rect, tri, sgn, abs, cases with affine conditions, polynomials); exponentials, trigonometric functions, symbolic shifts and integrals that diverge stay the integral, evaluated numerically.
/// - **Matrices:** names without a value are scalars, so they commute in products until they get a value (define matrices before multiplying them, or pass them to a function). Symbolic elimination treats an entry as zero only when it simplifies to 0, so entries that vanish by an identity like sin² + cos² = 1 count as nonzero. Floats count as zero within 10⁻¹³ of the largest element (times the size). Unknowns of `solve` are scalars: write a vector of unknowns as `vec(x, y)`.
/// - **Math in a worksheet:** an equation with `=` and only known names is checked, so a formula meant as plain text that happens to use defined names (`$a^2 + b^2 = c^2$` after defining a, b and c) must hold. Put those outside the worksheet or use `#worksheet(evaluate: false)[…]` around them.

#import "display.typ": *

#let _p = plugin("solveng.wasm")
#let _call(f, ..args) = cbor(f(..args.pos().map(a => if type(a) == bytes { a } else { cbor.encode(a) })))

// ---------- options ----------
#let _LANGS = ("de", "fr", "it", "es", "pt", "nl", "ru", "pl", "cs", "sk", "sl", "hr", "hu", "sv", "da", "nb", "fi", "tr", "ro", "uk")
// needs context: the decimal decimal-separator follows the document language
#let _sep(cf) = if cf.decimal-separator != auto { cf.decimal-separator } else if text.lang in _LANGS { "," } else { "." }
// plain text of content (a unit's display)
#let _plain(c) = if type(c) == str { c } else if type(c) in (int, float, symbol) { str(c) } else if c.has("text") { _plain(c.text) } else if c.has("children") { c.children.map(_plain).join() } else if c.has("body") { _plain(c.body) } else if c.has("child") { _plain(c.child) } else if c.func() == math.attach { _plain(c.base) + (if c.has("b") and c.b != none { "_" + _plain(c.b) } else { "" }) + (if c.has("t") and c.t != none { "^" + _plain(c.t) } else { "" }) } else if c.func() == math.frac { _plain(c.num) + "/" + _plain(c.denom) } else { " " }
// ---------- reading math as written ----------
#let _space = [ ].func()
#let _word-end = regex("[\\p{L}\\p{N}\"⦆⦈)]$")
#let _word-start = regex("^[\\p{L}\\p{N}\"⦅⦇]")
#let _align-point = $&$.body.func()
#let _number = regex("^[0-9]*\\.?[0-9]+$")
// In a cases condition, quoted text is the branch's label ("für", "sonst."), not a name: text that isn't a number.
#let _label(c) = c.func() == text and c.text.match(_number) == none
// math content -> the equation as text for the engine: letters as they are, quoted text "…" (names of several
// letters, as), solveng's bindings (units, constants) by their token, operations ⦇tri⦈, keywords ⦅solve(x)⦆; or an
// error for what isn't a formula
#let _src(c) = {
  if type(c) == content and c.has("label") and c.label == <solveng-binding> {
    return c.children.find(x => x.func() == metadata).value.token
  }

  if type(c) == content and c.has("label") and c.label == <solveng-operation> { return "⦇" + c.children.find(x => x.func() == metadata).value + "⦈" }
  if c == math.dif { return "dif" }
  if type(c) == str { return c }
  if type(c) in (int, float) { return str(c) }
  if type(c) == symbol { return if str(c) == "ⅆ" { "dif" } else { str(c) } }
  if type(c) != content { return _err("not a formula") }
  let f = c.func()
  if f == math.vec {
    let parts = c.children.map(x => _src(x))
    let error = parts.find(_E)
    return if error != none { error } else { "⦇vec⦈(" + parts.join(", ") + ")" }
  }
  if f == math.mat {
    // Typst pads shorter rows (of blocks) with empty cells
    let trim(row) = { while row.len() > 1 and row.last() == "" { row = row.slice(0, -1) }; row }
    let rows = c.rows.map(row => trim(row.map(x => _src(x))))
    let error = rows.flatten().find(_E)
    return if error != none { error } else { "mat(" + rows.map(row => row.join(", ")).join("; ") + ")" }
  }
  if f == math.cases {
    let branches = ()
    for (i, row) in c.children.enumerate() {
      let parts = if row.has("children") { row.children } else { (row,) }
      let at = range(parts.len()).filter(i => parts.at(i).func() == _align-point)
      if at.len() > 1 { return _err("cases: one & separates a value from its condition") }
      let value = _src(if at.len() == 0 { row } else { parts.slice(0, at.first()).join() })
      if _E(value) { return value }
      // A condition's quoted text labels it, whatever it says: only a label leaves the default branch.
      let condition = if at.len() == 0 { () } else { parts.slice(at.first() + 1).filter(p => p.func() != _space and p.func() != h and not _label(p)) }
      if condition.len() == 0 and i != c.children.len() - 1 { return _err("cases: only the last branch can omit its condition") }
      let test = if condition.len() == 0 { "1" } else { _src(condition.join()) }
      if _E(test) { return test }
      branches.push(value + ", " + test)
    }
    return "⦇cases⦈(" + branches.join(", ") + ")"
  }
  if c.has("label") and c.label == <solveng-builtin-operation> { return "⦇" + _plain(c) + "⦈" }
  if f == metadata {
    if c.has("label") and c.label == <solveng-key> {
      let args = c.value.args.map(a => { let s = _src(a); if _E(s) { "?" } else { s.replace("\"", "").trim() } })
      return "⦅" + c.value.key + (if args.len() > 0 { "(" + args.join(",") + ")" } else { "" }) + "⦆"
    }
    return ""
  }
  if f == text {
    let t = c.text
    if t == "ⅆ" { return "dif" }
    return if t == "" { "\"\"" } else if t.match(regex("\\p{L}|\\p{So}|[°%‰]")) != none { repr(t) } else { t }
  }
  if f == _align-point { return "" }
  if f == linebreak { return "\\" }
  if f == _space or f == h { return " " }
  if c.has("children") {
    let out = ""
    let prev = ""
    for x in c.children {
      let s = _src(x)
      if _E(s) { return s }
      if s == "" { continue }
      // names must not run into each other (Δ""r glues on purpose)
      if prev != "\"\"" and s != "\"\"" and prev.match(_word-end) != none and s.match(_word-start) != none { out += " " }
      out += s
      prev = s
    }
    return out
  }
  if f == math.frac {
    let (a, b) = (_src(c.num), _src(c.denom))
    return if _E(a) { a } else if _E(b) { b } else if a.trim() == "dif" { "dif / (" + b.replace("ⅆ", "dif") + ")" } else { "frac(" + a + ", " + b + ")" }
  }
  if f == math.attach {
    let base = _src(c.base)
    if _E(base) { return base }
    if (base == "∫" or base == "∑") and c.has("b") and c.b != none and c.has("t") and c.t != none {
      let (lower, upper) = (_src(c.b), _src(c.t))
      if _E(lower) { return lower }
      if _E(upper) { return upper }
      return (if base == "∑" { "sum_(" } else { "integral_(" }) + lower + ")^(" + upper + ")"
    }
    let out = base
    // y_A(a p): Typst sets the (a p) in the subscript; it's the call's arguments, spaces and all
    if c.has("b") and c.b != none and c.b.has("children") {
      let b = c.b.children
      let group = b.last()
      if b.len() > 1 and group.func() == math.lr and _plain(group).starts-with("(") and b.slice(0, -1).any(x => x.func() != _space) {
        let fields = c.fields()
        let _ = fields.remove("b")
        let t = fields.remove("t", default: none)
        let head = _src(math.attach(fields.remove("base"), b: b.slice(0, -1).join(), ..fields))
        let args = _src(group)
        if _E(head) { return head }
        if _E(args) { return args }
        if t == none { return head + args }
        let ts = _src(t)
        return if _E(ts) { ts } else { head + "(" + args + ")^(" + ts + ")" }
      }
    }
    // subscripts are part of a name (R_"load", "x"_("in" Delta))
    if c.has("b") and c.b != none {
      let sub = _src(c.b)
      if _E(sub) { return sub }
      // spaces inside a subscript go (R_(a b) is R_ab), but not after a comma: H_c(1, 2) is a call, not 1,2
      out = base.trim("\"") + "_" + sub.replace("\"", "").split(",").map(p => p.replace(regex("\\s"), "")).join(", ")
    }
    if c.has("t") and c.t != none {
      let t = _src(c.t)
      if _E(t) { return t }
      out += "^(" + t + ")"
    }
    for k in ("tl", "tr", "bl", "br") { if c.has(k) and c.at(k) != none { return _err("not a formula") } }
    return out
  }
  if f == math.class and _plain(c.body) == "d" { return "dif" }
  // math.op explicitly selects the underlying operation
  if f == math.op {
    let name = _plain(c.text).trim()
    return if name == "d" { "dif" } else { "⦇" + name + "⦈" }
  }
  if f == math.root {
    let r = _src(c.radicand)
    if _E(r) { return r }
    if c.has("index") and c.index != none { let i = _src(c.index); return if _E(i) { i } else { "(" + r + ")^(1/(" + i + "))" } }
    return "⦇sqrt⦈(" + r + ")"
  }
  if f == math.lr { return _src(c.body) }
  // styling (upright, class, …) is read through
  if c.has("body") { return _src(c.body) }

  if c.has("text") and type(c.text) == str { return c.text }
  _err("not a formula")
}


// A unit expression (compile's units and arguments) as the plugin reads it.
#let _unit-src(c) = {
  if type(c) == content and c.has("label") and c.label == <solveng-binding> { return _src(c) }
  if type(c) == content {
    if c.func() == math.attach {
      let base = _unit-src(c.base)
      if c.has("b") and c.b != none { panic("solveng: units: use unit for a subscripted unit name") }
      return base + if c.has("t") and c.t != none { "^(" + _unit-src(c.t) + ")" } else { "" }
    }
    if c.func() == math.lr { return "(" + _unit-src(c.body) + ")" }
    if c.func() == math.frac { return "(" + _unit-src(c.num) + ")/(" + _unit-src(c.denom) + ")" }
    if c.has("children") { return c.children.map(_unit-src).join(" ") }
    if c.has("body") { return _unit-src(c.body) }
  }
  let s = _src(c)
  if _E(s) { panic("solveng: units: not a unit expression") }
  s
}
// the options as the engine reads them
#let _req-cfg(cf) = {
  let g = cf.grouping
  (
    digits: cf.digits, trailing-zeros: cf.trailing-zeros, separator: _sep(cf),
    grouping: if g == none { none } else if type(g) == str { g } else if type(g) == symbol { str(g) } else { "#" },
    scientific: if cf.notation == "plain" { none } else if cf.notation in ("scientific", "engineering") { (0, 1) } else { cf.notation-thresholds }, engineering: cf.notation == "engineering", multiplication: cf.multiplication, form: cf.number-form,
    max-denominator: cf.max-denominator, fractions: cf.fraction-style,
    prefixes: if cf.prefixes == none { "None" } else if cf.prefixes == "all" { "All" } else { (Some: cf.prefixes) },
    show-si: cf.show-si,
    preferred-units: cf.preferred-units.map(u => _src(u.body)),
    approximate: cf.show-approximation, block: cf.block, max-solutions: cf.max-solutions,
    show-types: cf.show-types,
    words: (any: cf.words.at("any", default: "any")),
    unit-style: type(cf.unit-style) == function,
  )
}
// what the engine's markup refers to
#let _UDOT = h(0.06em) + math.class("normal", sym.dot.op) + h(0.06em)
#let _binding-displays = state("solveng-binding-displays", (:))
// how constants are shown, by identity: the built-in displays under the worksheet's option constants
#let _CONSTANTS = (pi: sym.pi, euler: $e$, imaginary: $i$, speed-of-light: $c$)
#let _constant-display(identity, fallback, cf: auto) = {
  let cf = if cf == auto { _cf.get() } else { cf }
  (_CONSTANTS + cf.at("constant-displays", default: (:))).at(identity, default: fallback)
}
#let _scope(cf, displays: (:)) = {
  (
  svconst: (id, ..fallback) => _constant-display(id, fallback.pos().at(0, default: math.upright(id)), cf: cf),
  svref: (id, ..name) => displays.at(id, default: math.upright(name.pos().at(0, default: id))),
  svop: id => displays.at("operation:" + id, default: math.op(id)),
  at: math.op("at"),
  svsep: { let s = cf.at("unit-separator", default: auto); if s == auto { _UDOT } else if type(s) == str { math.upright(s) } else { s } },
  svgroup: cf.grouping,
  svu: { let f = cf.at("unit-style", default: auto); if type(f) == function { f } else { x => x } },
  svchip: (kind, mark, u) => _chip(kind, mark, u, cf),
  )
}
// markup from the engine as math content
#let _m(s, cf) = eval(s, mode: "math", scope: _scope(cf, displays: if s.contains("#svref(") or s.contains("#svop(") { _binding-displays.get() } else { (:) }))

// ---------- the equation as written ----------
// solveng's equations carry a mark, so its rules never read them again
#let _RESHOWN = metadata("solveng-reshown")
#let _reshown(eq) = eq.body.has("children") and eq.body.children.any(c => c == _RESHOWN)
#let _unit-mk(s, cf) = {
  let r = _call(_p.unit, (cfg: _req-cfg(cf), src: s))
  if r == none { none } else { _m(r, cf) }
}
// what a unit binding says about its display: numeric (starts with a number), compound (more than one atom)
#let _binding-meta(c) = {
  if type(c) == content and c.has("label") and c.label == <solveng-binding> {
    return c.children.find(x => x.func() == metadata).value
  }
  (:)
}
#let _ends-factor = regex("[\\p{L}\\p{N})\\]}′]$")
#let _starts-number = regex("^\\p{N}")
#let _blank(x) = type(x) == content and x.func() in (_space, h)
// whether content as shown starts with a number: 2.54, a unit shown as 2.54 cm, a fraction or power of one
#let _starts-num(x) = {
  let m = _binding-meta(x)
  if m.len() > 0 { return m.at("numeric", default: false) }
  if type(x) == content {
    if x.func() == math.frac { return _starts-num(x.num) }
    if x.func() == math.attach { return _starts-num(x.base) }
    if x.has("children") { let first = x.children.find(c => not _blank(c)); return first != none and _starts-num(first) }
  }
  _plain(x).trim().match(_starts-number) != none
}
#let _ends-number = regex("\\p{N}$")
// an operator applies to what follows (sin 2, ∑_(k=1)^10 2^k, ∫_0^(2 s) 3 A dif t, d/(dif x) 2x): no factor ends with it
#let _operator(x) = {
  if type(x) not in (symbol, content) { return false }
  if type(x) == symbol { return str(x) in ("∫", "∬", "∭", "∮", "∑", "∏") }
  if x.has("label") and x.label in (<solveng-operation>, <solveng-builtin-operation>) { return true }
  let f = x.func()
  if f == math.op { return true }
  if f == math.attach or f == math.limits or f == math.scripts { return _operator(x.at(if f == math.attach { "base" } else { "body" })) }
  // d/(dif x), d^2/(dif x^2), ∂/(∂ x): a derivative without its operand
  let differential(n) = n == math.dif or _plain(n).trim() in ("d", "ⅆ", "∂") or (type(n) == content and n.func() == math.attach and differential(n.base))
  if f == math.frac { return differential(x.num) }
  _plain(x).trim() in ("∫", "∬", "∭", "∮", "∑", "∏")
}
// factors written next to each other, joined as results are written: by a dot where digits would meet
// (1 · 2.54 cm), a number and its unit by a thin space (3 in)
#let _dotted(out) = {
  let ends(x) = not _operator(x) and (_binding-meta(x).len() > 0 or _plain(x).trim().match(_ends-factor) != none)
  let (joined, prev) = ((), none)
  for x in out {
    if not _blank(x) {
      let join = if prev == none or not ends(prev) { none } else if _starts-num(x) { sym.dot.op }
        else if _binding-meta(x).at("unit", default: false) and _binding-meta(prev).len() == 0 and _plain(prev).trim().match(_ends-number) != none { h(0.1667em) }
      if join != none {
        // the join replaces the spaces typed between them
        while joined.len() > 0 and _blank(joined.last()) { let _ = joined.pop() }
        joined.push(join)
      }
      prev = x
    }
    joined.push(x)
  }
  joined.join()
}
// the arguments of a call written in math, f(a, b): what Typst shows as the operation and the parenthesized
// list after it; none for anything else
#let _call-args(c) = {
  let text-of(x) = if type(x) == content and x.has("text") and type(x.text) == str { x.text } else { none }
  if type(c) != content or c.func() != math.lr { return none }
  let cs = if c.body.has("children") { c.body.children } else { (c.body,) }
  if cs.len() < 2 or text-of(cs.first()) != "(" or text-of(cs.last()) != ")" { return none }
  let (args, part) = ((), ())
  for x in cs.slice(1, -1) {
    if text-of(x) == "," { args.push(part); part = () } else { part.push(x) }
  }
  args.push(part)
  // without the spaces around it; a part Typst grouped into one sequence is read as its children
  args.map(a => {
    while a.len() > 0 and _blank(a.first()) { let _ = a.remove(0) }
    while a.len() > 0 and _blank(a.last()) { let _ = a.pop() }
    if a.len() == 1 and a.first().func() == [].func() { a.first().children } else { a }
  })
}
// diff, integrate, laplace and invlaplace called in math, shown as mathematics writes them: d/(d x) f,
// ∫_a^b f d x, ℒ{f}(s), ℒ⁻¹{F}(t); none for other operations and other numbers of arguments
#let _notation(op, next, cf, restyle) = {
  if type(op) != content or not (op.has("label") and op.label == <solveng-builtin-operation>) { return none }
  let name = _plain(op).trim()
  if name not in ("diff", "integrate", "laplace", "invlaplace") { return none }
  let args = _call-args(next)
  if args == none or args.any(a => a.len() == 0) { return none }
  let shown = args.map(a => restyle(a, cf))
  // an operand that is a sum is put in parentheses: d/(d x) (x^2 + 1), not for a leading sign: d/(d x) −x
  let sum(a) = a.slice(1).any(x => type(x) == content and x.has("text") and x.text in ("+", "−", "-", "±", "∓"))
  let operand = if sum(args.first()) { math.lr[(#shown.first())] } else { shown.first() }
  let n = args.len()
  if name == "diff" and n == 2 { return $frac(dif, dif #shown.at(1)) #operand$.body }
  if name == "integrate" and n == 2 { return $integral #operand dif #shown.at(1)$.body }
  if name == "integrate" and n == 4 { return $integral_(#shown.at(2))^(#shown.at(3)) #operand dif #shown.at(1)$.body }
  let transform = if name == "laplace" { $cal(L)$.body } else { $cal(L)^(-1)$.body }
  if n == 1 { return $#transform lr({#shown.first()})$.body }
  if n == 3 { return $#transform lr({#shown.first()})(#shown.at(2))$.body }
  none
}
// types (f(x: #A)) as chips, plain or left out, as the options say; names as the engine
// spells them (Delta → Δ)
// `c` may be an array of children: joining them first would flatten the bindings' labelled sequences.
#let _restyle(c, cf) = {
  if type(c) == array { c = [].func()(c) }
  if type(c) != content { return c }
  if c.has("label") and c.label in (<solveng-binding>, <solveng-operation>, <solveng-builtin-operation>) { return c }
  if c == math.dif { return c }
  let f = c.func()
  if f == text {
    let normalized = _call(_p.name, c.text)
    if normalized != none { return _m(normalized, cf) }
  }
  if f == math.vec {
    let fields = c.fields()
    let children = fields.remove("children")
    return math.vec(..fields, ..children.map(x => _restyle(x, cf)))
  }
  if f == math.mat {
    let fields = c.fields()
    let rows = fields.remove("rows")
    return math.mat(..fields, ..rows.map(row => row.map(x => _restyle(x, cf))))
  }
  if f == math.cases {
    let fields = c.fields()
    let children = fields.remove("children")
    return math.cases(..fields, ..children.map(x => _restyle(x, cf)))
  }
  let space(x) = x == none or x.func() == _space
  let word(x) = if x.has("text") and type(x.text) == str { x.text } else { none }
  // y_A(x): Typst sets the (x) in the subscript, solveng reads the call of y_A – shown as it is calculated
  if f == math.attach and c.at("b", default: none) != none and c.b.has("children") {
    let b = c.b.children
    let group = b.last()
    if b.len() > 1 and group.func() == math.lr and _plain(group).starts-with("(") and b.slice(0, -1).any(x => not space(x)) {
      let fields = c.fields()
      let base = fields.remove("base")
      let _ = fields.remove("b")
      let t = fields.remove("t", default: none)
      let head = math.attach(base, b: b.slice(0, -1).join(), ..fields)
      let n = _call(_p.name, _src(head))
      let group = _restyle(group, cf)
      return (if n != none { _m(n, cf) } else { head }) + (if t == none { group } else { math.attach(group, t: _restyle(t, cf)) })
    }
  }
  if c.has("children") {
    let (out, ch, i) = ((), c.children, 0)
    while i < ch.len() {
      let x = ch.at(i)
      // A differential is an operator, even though _src spells it as `dif`.
      // Preserve it before the name scanner can turn it into a literal name.
      if x == math.dif {
        out.push(x)
        i += 1
        continue
      }
      let notation = _notation(x, ch.at(i + 1, default: none), cf, _restyle)
      if notation != none {
        out.push(notation)
        i += 2
        continue
      }
      let mark = word(x)
      if mark == ":" {
        // the unit: the longest run of children after the mark that reads as one
        let (k, end, um) = (i + 1, none, none)
        while k < ch.len() {
          let w = word(ch.at(k))
          if not space(ch.at(k)) and w not in ("∗", "*", "·", "⋅", "/") {
            let s = ch.slice(i + 1, k + 1).map(_src)
            if s.any(_E) { break }
            let r = _unit-mk(s.join(" "), cf)
            if r == none { if end != none { break } } else { (end, um) = (k + 1, r) }
          }
          k += 1
        }
        if end != none {
          while out.len() > 0 and space(out.last()) { let _ = out.pop() }
          let how = cf.at("show-types", default: "chip")
          let m = math.class("normal", sym.colon)
          if how == "chip" { out.push(h(0.15em) + _chip("type", m, um, cf)) }
          else if how == "plain" { out.push($med #m med #um$.body) }
          i = end
          continue
        }
      }
      let (end, normalized, source) = (none, none, "")
      let k = i
      while k < ch.len() and not space(ch.at(k)) {
        let s = _src(ch.at(k))
        if _E(s) { break }
        source += s
        let n = _call(_p.name, source)
        if n != none { (end, normalized) = (k + 1, n) } else if s != "\"\"" { break }
        k += 1
      }
      if end != none {
        out.push(_m(normalized, cf))
        i = end
      } else {
        out.push(_restyle(x, cf))
        i += 1
      }
    }
    return _dotted(out)
  }
  // a compound unit display under a power is one factor: (2.54 cm)²
  if f == math.attach and c.at("t", default: none) != none and _binding-meta(c.base).at("compound", default: false) {
    let fields = c.fields()
    let base = fields.remove("base")
    return math.attach($lr((#base))$.body, ..fields)
  }
  if f == math.lr {
    let fields = c.fields()
    let body = fields.remove("body")
    return math.lr(..fields, _restyle(body, cf))
  }
  if f == math.frac { return math.frac(_restyle(c.num, cf), _restyle(c.denom, cf)) }
  if f == math.root { return math.root(c.at("index", default: none), _restyle(c.radicand, cf)) }
  c
}
// the equation with a new body, marked as read
#let _with-body(eq, body) = {
  let fs = eq.fields()
  let _ = fs.remove("body")
  math.equation(..fs, _RESHOWN + body)
}
// an equation's children -> (head, marker, clause): at the last top-level →, else at the last top-level =
#let _split-eq(body, mark) = {
  let cs = if body.has("children") { body.children } else { (body,) }
  let t = if mark == "->" { "→" } else { "⇒" }
  let at = range(cs.len()).filter(i => cs.at(i).has("text") and (cs.at(i).text == t or (mark == "=>" and cs.at(i).text == "=")))
  if at.len() == 0 { return (cs, none) }
  let head = cs.slice(0, at.last())
  while head.len() > 0 and head.last().func() == _space { let _ = head.pop() }
  (head, t)
}
// Numeric evaluation is a mathematical result arrow, with normal relation spacing.
#let _BEQ = $=>$.body

// ---------- running ----------
// the state: env (the engine's bytes), last (what the last line gave), ^ (outside a worksheet), ^0 (its start)
#let _env(s) = s.at("env", default: bytes(()))
// Every operation leaves the same last-result shape, including operations without math output.
#let _out(errors: (), mark: none, result: none, prose: false, defined: (), operation: "error", source: "") = (
  errors: errors, mark: mark, result: result, prose: prose, defined: defined, solutions: (), operation: operation, source: source,
)
// Validate the plugin boundary before any consumer reads dictionary fields. A bad
// response is a calculation error, preserving the old environment and the source.
#let _line-response(r, previous, source) = {
  let bad(detail) = (
    env: previous,
    out: _out(errors: ("internal engine response error while calculating " + repr(source) + ": " + detail + ". The previous worksheet definitions were preserved.",)),
  )
  if type(r) != dictionary { return bad("expected a response dictionary, got " + repr(type(r))) }
  for k in ("env", "out") {
    if k not in r { return bad("missing response field " + repr(k) + "; received fields: " + r.keys().join(", ")) }
  }
  if type(r.env) != bytes { return bad("response field 'env' must be bytes, got " + repr(type(r.env))) }
  let out = r.out
  if type(out) != dictionary { return bad("response field 'out' must be a dictionary, got " + repr(type(out))) }
  let missing = ("prose", "errors", "mark", "result", "defined").filter(k => k not in out)
  if missing.len() > 0 { return bad("missing calculation fields: " + missing.join(", ") + "; received fields: " + out.keys().join(", ")) }
  if type(out.prose) != bool { return bad("calculation field 'prose' must be a boolean, got " + repr(type(out.prose))) }
  for k in ("errors", "defined") {
    let v = out.at(k)
    if type(v) != array { return bad("calculation field '" + k + "' must be an array, got " + repr(type(v))) }
    if not v.all(x => type(x) == str) { return bad("calculation field '" + k + "' must contain strings") }
  }
  if out.mark not in (none, "=>", "->") { return bad("calculation field 'mark' must be none, '=>' or '->', got " + repr(out.mark)) }
  if out.result != none and type(out.result) != str { return bad("calculation field 'result' must be none or a string, got " + repr(type(out.result))) }
  r
}
#let _run(s, req) = {
  let previous = _env(s)
  let r = _line-response(_call(_p.line, previous, req), previous, req.src)
  s + (env: r.env, last: r.out + (operation: "line", source: req.src))
}
// A layout/state mismatch must not turn a graph or clear result into an equation's output.
#let _calculation-out(s, source) = {
  let raw = s.at("last", default: none)
  if type(raw) == dictionary and "operation" in raw and raw.operation != "line" {
    let operation = raw.at("operation", default: "unknown operation")
    return _out(errors: ("internal worksheet state error while calculating " + repr(source) + ": expected this equation's result, received a result from " + repr(operation) + ". The equation was left unchanged.",))
  }
  if type(raw) == dictionary and raw.at("source", default: source) != source {
    return _out(errors: ("internal worksheet state error while calculating " + repr(source) + ": received the result for " + repr(raw.source) + ". The equation was left unchanged.",))
  }
  _line-response((env: _env(s), out: raw), _env(s), source).out
}
// one line: calculated in the state, shown with view(out) (in context)
#let _calc(src, cf, view) = {
  let req = (src: src, cfg: _req-cfg(cf))
  _st.update(s => _run(s, req))
  context {
    let s = _st.get()
    let last = s.at("last", default: none)
    let belongs = type(last) == dictionary and last.at("operation", default: none) == "line" and last.at("source", default: none) == src
    // Measurement can discard state updates while still evaluating contexts. In
    // that case calculate this equation locally instead of rendering another
    // operation's last result. Keep state updates outside the context for convergence.
    view(if belongs { _calculation-out(s, src) } else { _run(s, req).last })
  }
}
