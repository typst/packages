// =========================================================================
// typcas v1 -> v2 Translation Layer
// =========================================================================
// Migration bridge that exposes v1-style top-level names while delegating to
// v2 internals.
//
// Notes:
// - v1-style names are primary (`cas-parse`, `solve-meta`, `step-diff`, ...).
// - Additional v2-like aliases are kept for convenience.
// =========================================================================

#import "../lib.typ": *
#import "../src/core/runtime.typ": simplify-meta-core as _simplify-meta-core, expand as _expand-core, diff-n as _diff-n-core, definite-integral as _definite-integral-core, solve-meta as _solve-meta-core, step-diff as _step-diff-core, step-integrate as _step-integrate-core, step-simplify as _step-simplify-core, step-solve as _step-solve-core, display-steps as _display-steps-core, apply-assumptions as _apply-assumptions-core, domain-to-string as _domain-to-string-core, eval-expr as _eval-expr-core, substitute as _substitute-core, poly-coeffs as _poly-coeffs-core, coeffs-to-expr as _coeffs-to-expr-core, poly-div as _poly-div-core, poly-gcd as _poly-gcd-core, partial-fractions as _partial-fractions-core, mat-dims as _mat-dims-core, mat-at as _mat-at-core, mat-add as _mat-add-core, mat-sub as _mat-sub-core, mat-scale as _mat-scale-core, mat-mul as _mat-mul-core, mat-transpose as _mat-transpose-core, mat-det as _mat-det-core, mat-inv as _mat-inv-core, mat-solve as _mat-solve-core, mat-eigenvalues as _mat-eigenvalues-core, mat-eigenvectors as _mat-eigenvectors-core, solve-linear-system as _solve-linear-system-core, solve-nonlinear-system as _solve-nonlinear-system-core, variable-domain as _variable-domain-core, display-variable-domain as _display-variable-domain-core

#let _to-expr(x) = cas.parse(x)
#let _to-expr-with-assumptions(x, assumptions) = {
  let e = _to-expr(x)
  if assumptions == none { return e }
  _apply-assumptions-core(e, assumptions)
}

// -------------------------------------------------------------------------
// v1-style parser/display names
// -------------------------------------------------------------------------

#let cas-parse = cas.parse
#let cas-display = cas.display
#let cas-equation = cas.equation

// -------------------------------------------------------------------------
// v1-style assumptions/domain
// -------------------------------------------------------------------------

#let assume = cas.assume
#let assume-domain = cas.assume-domain
#let assume-string = cas.assume-string
#let merge-assumptions = cas.merge-assumptions
#let parse-domain = cas.parse-domain
#let domain-to-string = _domain-to-string-core
#let variable-domain = _variable-domain-core
#let display-variable-domain = _display-variable-domain-core

// -------------------------------------------------------------------------
// v1-style core algebra/calculus APIs
// -------------------------------------------------------------------------

#let simplify(expr, expand: false, assumptions: none, allow-domain-sensitive: false) = {
  let src = _to-expr(expr)
  let work = if expand { _expand-core(src) } else { src }
  let meta = _simplify-meta-core(work, allow-domain-sensitive: allow-domain-sensitive, assumptions: assumptions)
  meta.expr
}

#let simplify-meta(expr, expand: false, assumptions: none, allow-domain-sensitive: false) = {
  let src = _to-expr(expr)
  let work = if expand { _expand-core(src) } else { src }
  _simplify-meta-core(work, allow-domain-sensitive: allow-domain-sensitive, assumptions: assumptions)
}

#let diff(expr, var, assumptions: none) = {
  let res = cas.diff(expr, var, assumptions: assumptions)
  res.expr
}

#let diff-n(expr, var, order, assumptions: none) = {
  let src = _to-expr-with-assumptions(expr, assumptions)
  _diff-n-core(src, var, order)
}

#let integrate(expr, var, assumptions: none) = {
  let res = cas.integrate(expr, var, assumptions: assumptions)
  res.expr
}

#let definite-integral(expr, var, lo, hi, assumptions: none) = {
  let src = _to-expr-with-assumptions(expr, assumptions)
  _definite-integral-core(src, var, _to-expr(lo), _to-expr(hi))
}

#let taylor(expr, var, x0, order, assumptions: none) = {
  let res = cas.taylor(expr, var, x0, order, assumptions: assumptions)
  res.expr
}

#let limit(expr, var, to, assumptions: none) = {
  let res = cas.limit(expr, var, to, assumptions: assumptions)
  res.expr
}

#let implicit-diff(expr, x, y, assumptions: none) = {
  let res = cas.implicit-diff(expr, x, y, assumptions: assumptions)
  res.expr
}

// -------------------------------------------------------------------------
// v1-style solving APIs
// -------------------------------------------------------------------------

#let solve(lhs, rhs: 0, var: "x", assumptions: none) = {
  let res = cas.solve(lhs, rhs: rhs, var: var, assumptions: assumptions)
  let sols = res.diagnostics.at("solutions", default: none)
  if sols != none { return sols }
  if res.roots == none { return () }
  res.roots.map(r => r.expr)
}

#let solve-meta(lhs, rhs: 0, var: "x", assumptions: none) = {
  let l = _to-expr-with-assumptions(lhs, assumptions)
  let r = _to-expr-with-assumptions(rhs, assumptions)
  _solve-meta-core(l, r, var)
}

#let factor(expr, var, assumptions: none) = {
  let res = cas.factor(expr, var, assumptions: assumptions)
  res.expr
}

// -------------------------------------------------------------------------
// v1-style evaluation/substitution
// -------------------------------------------------------------------------

#let eval-expr(expr, bindings) = _eval-expr-core(_to-expr(expr), bindings)
#let substitute(expr, var-name, replacement) = _substitute-core(_to-expr(expr), var-name, _to-expr(replacement))

// -------------------------------------------------------------------------
// v1-style polynomial APIs
// -------------------------------------------------------------------------

#let poly-coeffs(expr, var) = _poly-coeffs-core(_to-expr(expr), var)
#let coeffs-to-expr(coeffs, var) = _coeffs-to-expr-core(coeffs, var)
#let poly-div(p, d, var) = _poly-div-core(_to-expr(p), _to-expr(d), var)
#let poly-gcd(p, d, var) = _poly-gcd-core(_to-expr(p), _to-expr(d), var)
#let partial-fractions(expr, var) = _partial-fractions-core(_to-expr(expr), var)

// -------------------------------------------------------------------------
// v1-style matrix/system APIs
// -------------------------------------------------------------------------

#let mat-dims(m) = _mat-dims-core(_to-expr(m))
#let mat-at(m, i, j) = _mat-at-core(_to-expr(m), i, j)
#let mat-add(a, b) = _mat-add-core(_to-expr(a), _to-expr(b))
#let mat-sub(a, b) = _mat-sub-core(_to-expr(a), _to-expr(b))
#let mat-scale(c, m) = _mat-scale-core(_to-expr(c), _to-expr(m))
#let mat-mul(a, b) = _mat-mul-core(_to-expr(a), _to-expr(b))
#let mat-transpose(m) = _mat-transpose-core(_to-expr(m))
#let mat-det(m) = _mat-det-core(_to-expr(m))
#let mat-inv(m) = _mat-inv-core(_to-expr(m))
#let mat-solve(a, b-vec) = _mat-solve-core(_to-expr(a), b-vec.map(_to-expr))
#let mat-eigenvalues(m) = _mat-eigenvalues-core(_to-expr(m))
#let mat-eigenvectors(m) = _mat-eigenvectors-core(_to-expr(m))

#let solve-linear-system(equations, vars) = _solve-linear-system-core(equations, vars)
#let solve-nonlinear-system(equations, vars, initial, max-iters: 40, tol: 1e-10) = _solve-nonlinear-system-core(
  equations.map(_to-expr),
  vars,
  initial,
  max-iters: max-iters,
  tol: tol,
)

// -------------------------------------------------------------------------
// v1-style step tracing/rendering
// -------------------------------------------------------------------------

#let step-diff(expr, var, depth: none, assumptions: none, detail: 1) = _step-diff-core(_to-expr(expr), var, depth: depth, assumptions: assumptions, detail: detail)
#let step-integrate(expr, var, depth: none, assumptions: none, detail: 1) = _step-integrate-core(_to-expr(expr), var, depth: depth, assumptions: assumptions, detail: detail)
#let step-simplify(expr, depth: none, assumptions: none, detail: 1) = _step-simplify-core(_to-expr(expr), depth: depth, assumptions: assumptions, detail: detail)
#let step-solve(lhs, rhs, var, depth: none, detail: 1) = _step-solve-core(_to-expr(lhs), _to-expr(rhs), var, depth: depth, detail: detail)
#let display-steps(original, steps, operation: none, var: none, rhs: none) = _display-steps-core(_to-expr(original), steps, operation: operation, var: var, rhs: rhs)

// -------------------------------------------------------------------------
// Compatibility aliases (kept for mixed migration code)
// -------------------------------------------------------------------------

#let parse = cas-parse
#let display = cas-display
#let equation = cas-equation
#let expr = cas.expr
#let parsed = cas.parsed
#let trace = cas.trace
#let render-steps = cas.render-steps
#let set-step-style = cas.set-step-style
#let get-step-style = cas.get-step-style
#let ast = cas.ast
