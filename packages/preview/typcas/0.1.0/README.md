# typcas

A lightweight Computer Algebra System (CAS) written in pure Typst.

`typcas` lets you parse math input, simplify symbolically, do calculus/solving, and render step-by-step derivations directly in a Typst document.

## Quick Start

Import the library:

```typst
#import "lib.typ": *
```

Parse and simplify:

```typst
#let expr = cas-parse("sin(x)^2 + cos(x)^2 + (x + 1)/(x + 1)")
#let out = simplify(expr)
$ #cas-display(out) $  // 2
```

Differentiate with assumptions:

```typst
#let a = assume("x", real: true, positive: true)
#let d = diff(cas-parse("sqrt(x^2)"), "x", assumptions: a)
$ #cas-display(d) $  // 1
```

Integrate:

```typst
#let i = integrate(cas-parse("sec^2 x + csc^2 x"), "x")
$ #cas-display(i) $  // tan(x) - cot(x) + C
```

Solve:

```typst
#let sols = solve(cas-parse("x^2 - 4"), 0, "x")
$ #sols.map(s => cas-display(s)).join(" or ") $  // 2 or -2
```

## Main Features

- Symbolic simplification with exact rational arithmetic.
- Assumption-aware simplification (`real`, `positive`, `nonzero`, etc.).
- Symbolic differentiation and integration.
- Limits, Taylor series, and implicit differentiation.
- Equation solving with polynomial metadata (`solve-meta`).
- Partial fractions and polynomial long division.
- Matrix operations (determinant, inverse, solve, eigenvalues/eigenvectors for 2x2).
- Step-by-step tracing and rendering for simplify/diff/integrate/solve.

## Step-by-Step Mode

Generate and render derivation traces:

```typst
#let expr = cas-parse("(x^2 + 1)^3")
#let steps = step-diff(expr, "x")
#display-steps(expr, steps, operation: "diff", var: "x")
```

Supported step APIs:

- `step-simplify(expr)`
- `step-diff(expr, var)`
- `step-integrate(expr, var)`
- `step-solve(lhs, rhs, var)`
- `display-steps(original, steps, operation: none, var: none, rhs: none)`

## Assumptions

Build assumptions with:

```typst
#let a1 = assume("x", real: true)
#let a2 = assume("x", positive: true)
#let a = merge-assumptions(a1, a2)
```

Then pass to APIs that support `assumptions:` (notably `simplify`, `diff`, `diff-n`, `integrate`, `definite-integral`, `taylor`, `solve`, `solve-meta`).

## Public API Snapshot

Core:

- `cas-parse(input)`
- `cas-display(expr)`
- `cas-equation(lhs, rhs)`

Algebra:

- `simplify(expr, expand: false, assumptions: none)`
- `expand(expr)`
- `eval-expr(expr, bindings)`
- `substitute(expr, var, repl)`

Calculus:

- `diff(expr, var, assumptions: none)`
- `diff-n(expr, var, n, assumptions: none)`
- `integrate(expr, var, assumptions: none)`
- `definite-integral(expr, var, a, b, assumptions: none)`
- `taylor(expr, var, x0, n, assumptions: none)`
- `limit(expr, var, to)`
- `implicit-diff(expr, x, y)`

Solving:

- `solve(lhs, rhs, var, assumptions: none)`
- `solve-meta(lhs, rhs, var, assumptions: none)`
- `factor(expr, var)`
- `poly-div(p, d, var)`
- `partial-fractions(expr, var)`
- `solve-linear-system(equations, vars)`
- `solve-nonlinear-system(equations, vars, initial, ...)`

Matrices:

- `mat-add`, `mat-sub`, `mat-scale`, `mat-mul`, `mat-transpose`
- `mat-det`, `mat-inv`, `mat-solve`, `mat-eigenvalues`, `mat-eigenvectors`

## Project Layout

- `lib.typ`: public facade.
- `src/truths/`: declarative rule tables (`function-registry`, `calculus-rules` shim, `identities`).
- `src/core/`: shared walkers and integer helpers.
- `src/calculus/`: `diff`, `integrate`, advanced calculus ops.
- `src/solve/`: solver engine.
- `src/parse/`: parser engine.
- `src/steps/`: step model, renderer, trace engine.

Top-level `src/*.typ` files for `calculus`, `solve`, `parse`, `steps`, and `identities` are stable facades over these modular engines.

## Adding a Function (Truths-Only)

To add a new named function, edit only `src/truths/function-registry.typ`.

Required checklist for a new registry entry:

1. `name`, `aliases`, and `arity`.
2. `parse` flags:
   - `allow-implicit`
   - `allow-power-prefix`
3. `display.render` closure.
4. `eval` closure with domain guards (return `none` for invalid real-domain inputs).
5. `calculus` block:
   - unary functions: provide `diff`, optional `integ`, `diff-step`, optional `domain-note`
   - non-unary functions: set calculus fields to `none` (unary calculus only in current engine)

Notes:

- Parser, display, and numeric eval auto-discover functions from the registry.
- `src/truths/calculus-rules.typ` is a compatibility shim derived from the registry.
- Algebraic identities remain separate: add optional simplification identities in `src/truths/identities.typ`.
- Structural operators/functions (`log(base,arg)`, `sqrt`, `root`, `frac`) still have dedicated parser/eval handling.

## Notes

- Variable name `i` is reserved for imaginary-unit support, so do not use `"i"` as a free variable name.
- This project is under active development; behavior can evolve as rules/engines improve.

## Local Validation

Compile the included suites:

```bash
typst compile examples/test.typ examples/out/typcas-test.pdf --root .
typst compile examples/test_new.typ examples/out/typcas-test-new.pdf --root .
typst compile examples/cas_test_suite.typ examples/out/typcas-suite.pdf --root .
```

## License

MIT. See `LICENSE`.
