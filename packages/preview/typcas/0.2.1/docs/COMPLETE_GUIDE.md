# typcas Complete Guide

This guide documents the current typcas system from user-facing APIs to core architecture decisions.

## Table of Contents

1. [What Is a CAS?](#what-is-a-cas)
2. [Quick Start](#quick-start)
3. [Core Concepts](#core-concepts)
4. [Public API Overview](#public-api-overview)
5. [Structured Result Contract](#structured-result-contract)
6. [Assumptions, Domains, and Restrictions](#assumptions-domains-and-restrictions)
7. [Step and Trace System](#step-and-trace-system)
8. [Function Cookbook (Registry-Driven)](#function-cookbook-registry-driven)
9. [Identity Engine](#identity-engine)
10. [Non-Smooth Derivatives](#non-smooth-derivatives)
11. [Limit Engine](#limit-engine)
12. [Restriction Panel UX](#restriction-panel-ux)
13. [Simplifier Safety and Performance](#simplifier-safety-and-performance)
14. [Architecture Map](#architecture-map)
15. [Extending typcas Safely](#extending-typcas-safely)
16. [Troubleshooting](#troubleshooting)
17. [Local Validation](#local-validation)

## What Is a CAS?

A CAS (Computer Algebra System) manipulates symbolic mathematics as structured expressions, not only numbers.

typcas supports:

- symbolic simplify/diff/integrate/solve
- numeric evaluation
- matrix/system/poly helpers
- restrictions and domain metadata
- step-by-step traces with configurable rendering

## Quick Start

```typst
#import "@preview/typcas:0.2.1": *

#let s = cas.simplify("sin(x)^2 + cos(x)^2")
#if cas.ok(s) [
  $ #cas.display(cas.expr-of(s)) $
]

#let d = cas.diff("x^3 + ln(x)", "x")
#let i = cas.integrate("2x*cos(x^2)", "x")
#let z = cas.solve("x^2 - 4", rhs: 0)
```

## Core Concepts

- `input`: string/content/AST/query/result accepted by task APIs.
- `query`: object from `cas.expr(...)` that carries context.
- `assumptions`: per-variable flags/domain metadata.
- `restrictions`: constraints collected from structure and function truth metadata.
- `strict`: if true, restriction conflicts return `ok: false`.
- `detail`/`depth`: control trace generation depth.

## Public API Overview

Primary task APIs:

```typst
#let s = cas.simplify(input, expand: false, allow-domain-sensitive: false, detail: 0, depth: none)
#let d = cas.diff(input, "x", order: 1, detail: 0, depth: none)
#let i = cas.integrate(input, "x", definite: none, detail: 0, depth: none)
#let id = cas.implicit-diff(input, "x", "y")
#let z = cas.solve(input, rhs: 0, var: "x", detail: 0, depth: none)
#let f = cas.factor(input, var: "x")
#let l = cas.limit(input, "x", to)
#let t = cas.taylor(input, "x", x0, order)
#let v = cas.eval(input, bindings: (:))
```

Limit target accepts finite points, `inf/-inf`, and one-sided strings:

```typst
#let l0 = cas.limit("sin(x)/x", "x", 0)
#let lplus = cas.limit("sin(x)/x", "x", "0+")
#let lminus = cas.limit("sin(x)/x", "x", "0-")
#let linf = cas.limit("(3x^2+1)/(2x^2-5)", "x", "inf")
```

Utility helpers:

```typst
#let p = cas.parse(input)
#let shown = cas.display(p)
#let eq = cas.equation("x^2-1", "(x-1)(x+1)")
#let tr = cas.trace-diff("(x^2+1)^3", var: "x", detail: 3)
#let rendered = cas.render-steps("(x^2+1)^3", tr, operation: "diff", var: "x")
```

Result extractors:

```typst
#let ok = cas.ok(res)
#let expr = cas.expr-of(res)
#let value = cas.value-of(res)
#let roots = cas.roots-of(res)
#let steps = cas.steps-of(res)
#let message = cas.error-message(res)
```

Context pack:

```typst
#let cx = cas.with(assumptions: cas.assume-string("x", "(0"))
#let simplify = cx.simplify
#let diff = cx.diff
```

## Structured Result Contract

Most task calls return:

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

`expr` is populated for symbolic operations, `value` for numeric/system data, `roots` for solve metadata, `steps` when detail/trace is requested.

## Assumptions, Domains, and Restrictions

Assumption constructors:

```typst
#let a1 = cas.assume("x", real: true, positive: true)
#let a2 = cas.assume-string("x", "(0")
#let a3 = cas.assume-domain("x", "(-inf,1) ∪ (1,inf)")
#let a = cas.merge-assumptions(a1, a2, a3)
```

Domain display:

```typst
$ #cas.display-domain("x", assumptions: a) $
```

Restriction model:

- structural constraints (for example denominator not zero)
- function-defined constraints from `src/truths/function-registry.typ`
- filtered against assumptions into `restrictions/satisfied/conflicts/residual`

`strict: true` blocks conflicting results with `ok: false`.

Each core operation also exposes a compact panel in diagnostics:

```typst
#let r = cas.simplify("(x^2-1)/(x-1)", assumptions: cas.assume-domain("x", "(-inf,1) ∪ (1,inf)"))
#let panel = r.diagnostics.at("restriction-panel", default: none)
```

`panel` includes:

- `counts` (`active/satisfied/conflicts`)
- `rows` with `status`, `source`, `stage`, relation, and note
- passthrough tuples (`restrictions`, `satisfied`, `conflicts`, `residual`, `variable-domains`)

## Step and Trace System

Trace endpoints:

- `cas.trace-simplify`
- `cas.trace-diff`
- `cas.trace-integrate`
- `cas.trace-solve`

Numeric detail scale:

- `0`: no steps
- `1`: concise shallow
- `2`: concise medium (trace default)
- `3`: pedagogical deeper
- `4`: full recursion

`depth` explicitly overrides detail-derived depth.

Style is document-global:

```typst
#cas.set-step-style((
  arrow: (main: "=>", sub: "->", meta: "=>"),
  branch: (mode: "inline", marker: "->"),
))
```

## Function Cookbook (Registry-Driven)

Functions are defined centrally in `src/truths/function-registry.typ` and flow automatically to parse/eval/display/restrictions/calculus dispatch.

### Trig/Hyperbolic/Inverse/Log Families

Examples:

```typst
cas.simplify("sin(x)^2 + cos(x)^2")
cas.diff("ln(x)", "x")
cas.integrate("sec(x)^2 + csc(x)^2", "x")
```

### Numeric + Logic Bundle (Conservative Expansion)

Added utility functions:

- `sign(u)` with alias `sgn(u)`
- `floor(u)`
- `ceil(u)`
- `round(u)`
- `trunc(u)`
- `fracpart(u)` defined numerically as `u - trunc(u)`
- `min(a,b,...)` variadic, minimum 2 args
- `max(a,b,...)` variadic, minimum 2 args
- `clamp(x, lo, hi)` with restriction `lo <= hi`

Examples:

```typst
cas.eval("sign(-3)")
cas.eval("sgn(5)")
cas.eval("floor(2.9)")
cas.eval("ceil(2.1)")
cas.eval("round(2.6)")
cas.eval("trunc(-2.9)")
cas.eval("fracpart(-2.9)")
cas.eval("min(3,4,1)")
cas.eval("max(3,4,1)")
cas.eval("clamp(10,0,5)")
```

### Arity Enforcement

Known function calls are arity-checked at parse time:

- `sign(1,2)` fails parse
- `clamp(1,2)` fails parse
- `min(1)` fails parse (`min/max` require at least 2 args)

Unknown function names remain symbolic fallback.

### Calculus Policy for New Non-Smooth Helpers

Integration remains conservative (`integ: none` for these helpers), but differentiation is now piecewise-aware with symbolic boundary fallback.

## Identity Engine

Identity rules are defined in `src/truths/identities.typ` and applied by the simplifier under a deterministic priority order.

Conservative additions in this pass:

- `log1p(expm1(u)) = u`
- `expm1(log1p(u)) = u` (domain-sensitive)
- `cbrt(u)^3 = u`
- `(sqrt(u))^2 = u` (domain-sensitive)
- `min(u,u) = u`
- `max(u,u) = u`
- `clamp(u,a,a) = a`
- `sign(u)*abs(u) = u`
- `abs(u)/u = sign(u)` (domain-sensitive)
- `u/abs(u) = sign(u)` (domain-sensitive)

Identity telemetry is available in simplify diagnostics:

```typst
#let s = cas.simplify("min(x,x)", detail: 1)
#let count = s.diagnostics.at("identity-count", default: 0)
#let events = s.diagnostics.at("identity-events", default: ())
```

## Non-Smooth Derivatives

typcas now emits piecewise forms for non-smooth derivatives:

- `d/dx abs(u)` -> piecewise with `u > 0` and `u < 0` branches plus boundary fallback
- `d/dx sign(u)` -> `0` for `u != 0` plus boundary fallback
- `d/dx min(a,b)` / `max(a,b)` -> ordered relation branches (`a < b`, `b < a`, etc.)
- `d/dx clamp(x, lo, hi)` -> outer and interior branches (`x < lo`, `lo < x < hi`, `x > hi`)

Boundary branches are intentionally symbolic for correctness. Results include warnings:

```typst
#let d = cas.diff("abs(x)", "x", strict: false)
#let warnings = d.warnings
```

Look for warning code `nonsmooth-boundary`.

## Limit Engine

Limit handling is conservative but expanded:

- one-sided finite limits (`"a+"`, `"a-"`)
- `x -> ±inf` rational degree rules for `P(x)/Q(x)`
- guarded trig standard forms:
  - `sin(u)/u -> 1` at `u -> 0`
  - `tan(u)/u -> 1` at `u -> 0`
  - `(1-cos(u))/u^2 -> 1/2` at `u -> 0`
- L'Hospital path for finite-point quotient indeterminate forms
- unresolved forms remain symbolic `limit(...)` nodes (never guessed)

## Restriction Panel UX

The restriction panel is surfaced in two places:

1. `result.diagnostics["restriction-panel"]` for machine-readable UI/logging.
2. step traces (`step-simplify`, `step-diff`, `step-integrate`, `step-solve`) as compact summary + rows.

Statuses:

- `active`: still required under current assumptions
- `satisfied`: proven by assumptions/domain propagation
- `conflict`: assumption/domain contradiction

This keeps domain semantics visible without changing result contract shape.

## Simplifier Safety and Performance

The simplify fixed-point pass includes:

- deterministic pass cap
- cycle detection on seen normalized states
- indeterminate-form safety (for example `0/0` is preserved)
- identity telemetry (`identity-events`, `identity-count`, `identity-unique`)

Per-call memoization is used in:

- simplify pass internals
- diff recursion
- trace recursion

Caches are local to a single operation call (no global cache state).

## Architecture Map

Key modules:

- `src/truths/function-registry.typ`: function metadata truth source.
- `src/truths/identities.typ`: identity truth table.
- `src/parse/engine.typ`: parser/tokenizer and structural forms.
- `src/simplify.typ` + `src/identity-engine.typ`: fixed-point simplify and identity application.
- `src/restrictions.typ` + `src/domain.typ` + `src/assumptions.typ`: restriction/domain propagation.
- `src/calculus/*`: diff/integrate/advanced engines.
- `src/steps/*`: trace model, generation, and rendering.
- `src/api/cas.typ` + `src/api/builder.typ`: task-first public surface and query builder.

Typical path:

1. input -> parse
2. operation engine (simplify/diff/integrate/solve)
3. restrictions/domain classification
4. optional steps generation
5. structured result return

## Extending typcas Safely

### Add a Function

1. Edit `src/truths/function-registry.typ`.
2. Set canonical name, aliases, arity, parse policy, display render, eval closure.
3. Add restrictions/analysis/hints/calculus hooks if valid.
4. No parser/eval/display hardcoding needed for normal function behavior.

### Add an Identity

1. Edit `src/truths/identities.typ`.
2. Provide unique `id`, stable `priority`, `label`, `domain-sensitive`.
3. Add strict assertions in `examples/test.typ`.
4. Confirm no oscillation with existing rules.

## Troubleshooting

- Parse error on function call: check known function arity.
- Domain conflict in strict mode: inspect `res.conflicts` and assumptions.
- Missing simplification: check if identity is domain-sensitive and whether `allow-domain-sensitive: true` is enabled.
- Steps missing: ensure `detail > 0` or use explicit trace API.
- Non-smooth derivative confusion: inspect `warnings` for `nonsmooth-boundary`.
- Unexpected limit form: check whether result stayed symbolic `limit(...)` (means unresolved safely).

## Local Validation

```bash
typst compile examples/test.typ /tmp/typcas-test.pdf --root .
```

Probe compiles:

```bash
for probe in examples/probes/*.typ; do
  typst compile "$probe" "/tmp/$(basename "$probe" .typ).pdf" --root .
done
```

Optional historical regression check:

```bash
typst compile archive/v1/examples/regression_check.typ /tmp/typcas-v1-regression.pdf --root .
```
