# typcas Function Reference

This file lists how to use the public `cas.*` functions and the expression-level math functions recognized by the parser/registry.

## Import

```typst
#import "@preview/typcas:0.2.1": *
```

## 1) Public `cas.*` Functions

## 1.1 Core Query/Input

- `cas.expr(input, assumptions: none, field: "real", strict: true)`
  - Creates a query context object.
  - Example: `#let q = cas.expr("x^2 + 1")`
- `cas.parse(input)`
  - Parses input to expression AST.
  - Example: `#let e = cas.parse("sin(x)^2")`
- `cas.parsed(input, assumptions: none, field: none, strict: none)`
  - Parse via task pipeline, returns structured result.
- `cas.display(input)`
  - Renders expression or parseable input.
  - Example: `$ #cas.display("x^2 + 1") $`
- `cas.equation(lhs, rhs)`
  - Renders `lhs = rhs`.

## 1.2 Algebra / Calculus / Solve

- `cas.simplify(input, expand: false, allow-domain-sensitive: false, detail: 0, depth: none, assumptions: none, field: none, strict: none)`
- `cas.diff(input, var, order: 1, detail: 0, depth: none, assumptions: none, field: none, strict: none)`
- `cas.integrate(input, var, definite: none, detail: 0, depth: none, assumptions: none, field: none, strict: none)`
- `cas.implicit-diff(input, x, y, assumptions: none, field: none, strict: none)`
- `cas.solve(input, rhs: 0, var: "x", detail: 0, depth: none, assumptions: none, field: none, strict: none)`
- `cas.factor(input, var: "x", assumptions: none, field: none, strict: none)`
- `cas.limit(input, var, to, assumptions: none, field: none, strict: none)`
- `cas.taylor(input, var, x0, order, assumptions: none, field: none, strict: none)`
- `cas.eval(input, bindings: (:), assumptions: none, field: none, strict: none)`
- `cas.substitute(input, var, repl, assumptions: none, field: none, strict: none)`
- `cas.domain(input, var, assumptions: none, field: none, strict: none)`

## 1.3 Step Trace / Rendering

- `cas.trace(input, op, var: "x", rhs: 0, depth: none, detail: 2, assumptions: none, field: none, strict: none)`
  - `op`: `"simplify" | "diff" | "integrate" | "solve"`
- `cas.trace-simplify(input, detail: 2, depth: none, assumptions: none, field: none, strict: none)`
- `cas.trace-diff(input, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none)`
- `cas.trace-integrate(input, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none)`
- `cas.trace-solve(input, rhs: 0, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none)`
- `cas.render-steps(original, trace-or-steps, operation: none, var: none, rhs: none)`

## 1.4 Step Style

- `cas.set-step-style(style-map)`
- `cas.get-step-style()`

## 1.5 Assumptions / Domains

- `cas.assume(var, real: false, positive: false, nonzero: false, nonnegative: false, negative: false)`
- `cas.assume-domain(var, domain-str)`
- `cas.assume-string(var, spec)`
- `cas.merge-assumptions(..assumptions)`
- `cas.parse-domain(domain-str)`
- `cas.variable-domain(var, assumptions: none)`
- `cas.display-domain(var, assumptions: none)`

## 1.6 Result Helpers

- `cas.ok(result)`
- `cas.error-message(result, default: "unknown")`
- `cas.expr-of(x, default: none)`
- `cas.value-of(x, default: none)`
- `cas.steps-of(x, default: ())`
- `cas.roots-of(result, mode: "expr" | "meta")`

## 1.7 Context Pack

- `cas.with(assumptions: none, field: "real", strict: true)`
  - Returns reusable task functions: `parsed`, `simplify`, `diff`, `integrate`, `implicit-diff`, `solve`, `factor`, `limit`, `taylor`, `eval`, `substitute`, `trace`, `domain`, `render-steps`.

## 1.8 Matrix / Systems / Polynomial Tools

- `cas.matrix(rows)`
- `cas.mat-add(a, b)`
- `cas.mat-sub(a, b)`
- `cas.mat-scale(c, m)`
- `cas.mat-mul(a, b)`
- `cas.mat-transpose(m)`
- `cas.mat-det(m)`
- `cas.mat-inv(m)`
- `cas.mat-solve(a, b)`
- `cas.mat-eigenvalues(m)`
- `cas.mat-eigenvectors(m)`
- `cas.solve-linear-system(equations, vars)`
- `cas.solve-nonlinear-system(equations, vars, initial, max-iters: 40, tol: 1e-10)`
- `cas.poly-coeffs(expr, var)`
- `cas.coeffs-to-expr(coeffs, var)`
- `cas.poly-div(p, d, var)`
- `cas.partial-fractions(expr, var)`

## 2) Expression Functions (Parser/Registry)

Notes:

- Unary functions support implicit syntax when enabled (for example `sin x`).
- `min/max` are variadic and require at least 2 args.
- Known function calls are arity-checked at parse time.
- This section is the complete registry inventory (canonical names + accepted aliases).

### 2.1 Canonical Registry Functions

| Function | Aliases | Arity | Example |
|---|---|---:|---|
| `sin` | - | 1 | `sin(x)` |
| `cos` | - | 1 | `cos(x)` |
| `tan` | - | 1 | `tan(x)` |
| `csc` | - | 1 | `csc(x)` |
| `sec` | - | 1 | `sec(x)` |
| `cot` | - | 1 | `cot(x)` |
| `arcsin` | `asin` | 1 | `arcsin(x)` / `asin(x)` |
| `arccos` | `acos` | 1 | `arccos(x)` / `acos(x)` |
| `arctan` | `atan` | 1 | `arctan(x)` / `atan(x)` |
| `arccsc` | `acsc` | 1 | `arccsc(x)` / `acsc(x)` |
| `arcsec` | `asec` | 1 | `arcsec(x)` / `asec(x)` |
| `arccot` | `acot` | 1 | `arccot(x)` / `acot(x)` |
| `sinh` | - | 1 | `sinh(x)` |
| `cosh` | - | 1 | `cosh(x)` |
| `tanh` | - | 1 | `tanh(x)` |
| `csch` | - | 1 | `csch(x)` |
| `sech` | - | 1 | `sech(x)` |
| `coth` | - | 1 | `coth(x)` |
| `arcsinh` | `asinh` | 1 | `arcsinh(x)` / `asinh(x)` |
| `arccosh` | `acosh` | 1 | `arccosh(x)` / `acosh(x)` |
| `arctanh` | `atanh` | 1 | `arctanh(x)` / `atanh(x)` |
| `arccsch` | `acsch` | 1 | `arccsch(x)` / `acsch(x)` |
| `arcsech` | `asech` | 1 | `arcsech(x)` / `asech(x)` |
| `arccoth` | `acoth` | 1 | `arccoth(x)` / `acoth(x)` |
| `ln` | `log` (unary log) | 1 | `ln(x)` / `log(x)` |
| `exp` | - | 1 | `exp(x)` |
| `log2` | - | 1 | `log2(x)` |
| `log10` | - | 1 | `log10(x)` |
| `log1p` | - | 1 | `log1p(x)` |
| `expm1` | - | 1 | `expm1(x)` |
| `cbrt` | - | 1 | `cbrt(x)` |
| `sinc` | - | 1 | `sinc(x)` |
| `softplus` | - | 1 | `softplus(x)` |
| `sigmoid` | - | 1 | `sigmoid(x)` |
| `abs` | - | 1 | `abs(x)` |
| `sign` | `sgn` | 1 | `sign(x)` / `sgn(x)` |
| `floor` | - | 1 | `floor(x)` |
| `ceil` | - | 1 | `ceil(x)` |
| `round` | - | 1 | `round(x)` |
| `trunc` | - | 1 | `trunc(x)` |
| `fracpart` | - | 1 | `fracpart(x)` |
| `min` | - | variadic (`>=2`) | `min(a,b,c)` |
| `max` | - | variadic (`>=2`) | `max(a,b,c)` |
| `clamp` | - | 3 | `clamp(x, lo, hi)` |
| `hypot2` | - | 2 | `hypot2(x, y)` |

### 2.2 Accepted Alias Names (Full Map)

These are accepted parser call names that map to canonical registry entries:

| Alias | Canonical |
|---|---|
| `asin` | `arcsin` |
| `acos` | `arccos` |
| `atan` | `arctan` |
| `acsc` | `arccsc` |
| `asec` | `arcsec` |
| `acot` | `arccot` |
| `asinh` | `arcsinh` |
| `acosh` | `arccosh` |
| `atanh` | `arctanh` |
| `acsch` | `arccsch` |
| `asech` | `arcsech` |
| `acoth` | `arccoth` |
| `sgn` | `sign` |
| `log` (unary call) | `ln` |

## 3) Structural Parse Forms (Not Regular Registry Calls)

These are parser-level forms with special AST nodes:

- `sqrt(u)` -> square-root power form.
- `root(n, u)` -> nth-root power form.
- `frac(n, d)` -> division form.
- `log_b(u)` and `log(base, arg)` -> log-with-base form.
- `sum_(k=from)^to body` -> summation node.
- `product_(k=from)^to body` -> product node.

## 4) Quick Usage Examples

```typst
#let a = cas.assume-string("x", "(0")

#let s = cas.simplify("min(x,x) + sin(x)^2 + cos(x)^2", assumptions: a)
#let d = cas.diff("exp(x) + fracpart(x)", "x", assumptions: a)
#let i = cas.integrate("2x*cos(x^2)", "x", assumptions: a)
#let z = cas.solve("x^2 - 4", rhs: 0)
#let tr = cas.trace-integrate("2x*cos(x^2)", var: "x", detail: 3, assumptions: a)

#if cas.ok(s) [$ #cas.display(cas.expr-of(s)) $]
#if cas.ok(tr) [#cas.render-steps("2x*cos(x^2)", tr, operation: "integrate", var: "x")]
```
