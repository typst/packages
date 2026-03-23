# typcas (v 0.2.1)

Task-centric CAS for Typst with Builder-style orchestration and structured results.

[`Repository`](https://github.com/sihooleebd/typCAS) ·
[`Complete Guide`](https://github.com/sihooleebd/typCAS/blob/master/docs/COMPLETE_GUIDE.md) ·
[`Function Reference`](https://github.com/sihooleebd/typCAS/blob/master/docs/functions.md) ·
[`Contributing`](https://github.com/sihooleebd/typCAS/blob/master/CONTRIBUTING.md) ·
[`Changelog`](https://github.com/sihooleebd/typCAS/blob/master/docs/CHANGELOG.md)

---

## Documentation

- [Complete Guide](https://github.com/sihooleebd/typCAS/blob/master/docs/COMPLETE_GUIDE.md) for full API and internals documentation.
- [Function Reference](https://github.com/sihooleebd/typCAS/blob/master/docs/functions.md) for signatures and usage examples of all public and parser-level functions.
- [Changelog](https://github.com/sihooleebd/typCAS/blob/master/docs/CHANGELOG.md) for release history and full-refactor rationale.

## Contributing

- [Contributing Guide](https://github.com/sihooleebd/typCAS/blob/master/CONTRIBUTING.md) is the binding contributor policy for philosophy, invariants, and merge gates.

## Quick Start

```typst
#import "@preview/typcas:0.2.1": *

#let r = cas.simplify("sin(x)^2 + cos(x)^2")

#if cas.ok(r) [
  $ #cas.display(cas.expr-of(r)) $
]
```

Optional local convenience imports (in this repo):

```typst
#import "translators/translation.typ": *
// v1-style function aliases mapped to v2 cas.* API
```

## Core API

### Task-First Operations (Primary)

```typst
#let s = cas.simplify(input, expand: false, allow-domain-sensitive: false, detail: 0, depth: none)
#let d = cas.diff(input, "x", order: 1, detail: 0, depth: none)
#let i = cas.integrate(input, "x", definite: none, detail: 0, depth: none)
#let id = cas.implicit-diff(input, "x", "y")
#let z = cas.solve(input, rhs: 0, var: "x", detail: 0, depth: none)
#let f = cas.factor(input, var: "x")
#let l = cas.limit(input, "x", to)
#let t = cas.taylor(input, "x", x0, order)
#let v = cas.eval(input, bindings: (x: 2))
#let dm = cas.domain(input, "x")
#let tr = cas.trace(input, "diff", var: "x", depth: none, detail: 2)
```

One-sided limits are supported with additive suffix notation:

```typst
#let r = cas.limit("sin(x)/x", "x", "0+")
#let l = cas.limit("sin(x)/x", "x", "0-")
```

### Utility Function Library (Additive)

The registry now includes common numeric helpers through the same parse/eval/simplify pipeline:

- `sign(u)` / alias `sgn(u)`
- `floor(u)`, `ceil(u)`, `round(u)`, `trunc(u)`, `fracpart(u)`
- `min(a, b, ...)`, `max(a, b, ...)`
- `clamp(x, lo, hi)`

Known function calls are arity-checked at parse time (for example `min(1)` and `clamp(1, 2)` now fail fast).

### Context Pack (`cas.with`)

Bind `assumptions` / `field` / `strict` once:

```typst
#let cx = cas.with(assumptions: a, field: "real", strict: true)
#let simplify = cx.simplify
#let diff = cx.diff

#let s = simplify("sin(x)^2 + cos(x)^2")
#let d = diff("x^3 + 1", "x")
```

### Result Extractors

Structured results remain canonical; these helpers reduce boilerplate:

```typst
#let ok = cas.ok(res)
#let expr = cas.expr-of(res)
#let value = cas.value-of(res)
#let roots = cas.roots-of(res)        // expressions
#let roots-meta = cas.roots-of(res, mode: "meta")
#let steps = cas.steps-of(res)
#let err = cas.error-message(res)
```

Core operations can include steps in the same result with `detail > 0`:

```typst
#let r = cas.simplify("sin(x)^2 + cos(x)^2", detail: 2)
// r.expr is simplified output, r.steps contains the trace tuple
// r.diagnostics.identity-events contains ordered identity rule usage
// r.diagnostics.restriction-panel contains compact restriction rows/status
```

Non-smooth derivatives (`abs`, `sign`, `min/max`, `clamp`) now return piecewise-aware symbolic forms, and emit `warnings` when boundary branches remain symbolic.

## Step-By-Step Tracing

Use dedicated helpers to avoid op-string arguments:

```typst
#let tr-s = cas.trace-simplify("sin(x)^2 + cos(x)^2", detail: 2)
#let tr-d = cas.trace-diff("(x^2+1)^3", var: "x", detail: 3)
#let tr-i = cas.trace-integrate("2x*cos(x^2)", var: "x", detail: 4)
#let tr-z = cas.trace-solve("x^2-4", rhs: 0, var: "x", detail: 3)

#if cas.ok(tr-i) [
  #cas.render-steps("2x*cos(x^2)", tr-i, operation: "integrate", var: "x")
]
```

Generic endpoint remains available:

```typst
#let tr = cas.trace("2x*cos(x^2)", "integrate", var: "x", detail: 4)
#if tr.ok [
  #cas.render-steps("2x*cos(x^2)", tr, operation: "integrate", var: "x")
]
```

Depth is uniform across core-4:

- `depth: none` => full recursion
- `depth: 1` => top-level transform only
- `depth: n` => recurse up to `n - 1` child levels

Numeric detail levels:

- `detail: 0` => no steps (core-op default)
- `detail: 1` => concise, shallow (`depth: 1`)
- `detail: 2` => concise, medium (`depth: 2`) (trace default)
- `detail: 3` => pedagogical, deeper (`depth: 3`)
- `detail: 4` => pedagogical, full recursion (`depth: none`)

If both `detail` and `depth` are passed, explicit `depth` wins.

Integration traces include explicit u-sub narration when selected:

- `u = ...`
- `du = ...`
- transformed integral
- primitive in `u`
- back-substitution

### Advanced: Builder Query Object

Builder is still fully supported:

```typst
#let q = cas.expr("sin(x)^2 + cos(x)^2")
#let r = (q.simplify)()
```

Typst note: builder members are dictionary function fields, so method calls require parentheses:
`(q.simplify)(...)`, `(q.diff)("x")`, etc.

### Step Style (Doc-Level)

Use document-global style settings for colors/arrows/indentation:

```typst
#cas.set-step-style((
  palette: (
    transform: rgb("#0A9AA4"),
    warn: rgb("#C27B00"),
    error: rgb("#B4372F"),
    meta: rgb("#2E6E77"),
  ),
  arrow: (main: "⇒", sub: "↦", meta: "⟹"),
  indent-size: 1.25em,
  branch: (
    mode: "inline",
    marker: "↳",
  ),
))
```

Read current style inside a `context` block with `cas.get-step-style()`.
Use `branch.mode: "divider"` to opt into heavier branch separators.

### Structured Result Contract

Each operation returns:

```typst
(
  ok: bool,
  op: str,
  field: "real" | "complex",
  strict: bool,
  expr: expr | none,
  value: any | none,
  roots: tuple | none,
  steps: tuple | none,
  restrictions: tuple,
  satisfied: tuple,
  conflicts: tuple,
  residual: tuple,
  variable-domains: dictionary,
  warnings: tuple,
  errors: tuple,
  diagnostics: dictionary,
)
```

## Assumptions & Domains

```typst
#let a1 = cas.assume("x", real: true, positive: true)
#let a2 = cas.assume-domain("x", "(-inf,1) ∪ (1,inf)")
#let a3 = cas.assume-string("x", "(0")
#let a = cas.merge-assumptions(a1, a2, a3)
```

Domain strings support both classic interval notation and compact syntax such as:

- `2)(2`
- `2)[3,4](5`
- `3)`
- `(4`

## Integration Constant `C` Policy

- Bare `C` is reserved as the integration constant and canonicalized as `const("C")`.
- If you need a regular variable, use `c` or `C_0`.
- `sum/prod` index variable `C` is rejected by parser with a clear error.

```typst
#let c0 = cas.parse("C")
$ #cas.display(c0) $ // italic C constant

#let i = cas.integrate("x*exp(x)", "x")
$ #cas.display(cas.expr-of(i)) $ // ... + C (C kept at tail)
```

## Namespaced Helpers

- `cas.parse(...)`
- `cas.display(expr)`
- `cas.equation(lhs, rhs)`
- `cas.parse-domain(...)`
- `cas.display-domain("x", assumptions)`
- `cas.poly-coeffs(expr, "x")`
- `cas.coeffs-to-expr((a_0, a_1, ...), "x")`
- `cas.poly-div(p, d, "x")`
- `cas.partial-fractions(expr, "x")`

## Project Layout

- `src/`: active v2 implementation surface.
- `archive/v1/`: archived pre-v2 codebase and examples, with standalone `archive/v1/typst.toml` + `archive/v1/lib.typ`.
- `translators/translation.typ`: v1->v2 migration alias layer (migration-only).
- [`docs/COMPLETE_GUIDE.md`](https://github.com/sihooleebd/typCAS/blob/master/docs/COMPLETE_GUIDE.md): comprehensive end-to-end guide (API + architecture).

## Local Validation

```bash
typst compile examples/test.typ examples/out/typcas-test.pdf --root .
for probe in examples/probes/*.typ; do \
  typst compile "$probe" "examples/out/$(basename "$probe" .typ).pdf" --root .; \
done
```
