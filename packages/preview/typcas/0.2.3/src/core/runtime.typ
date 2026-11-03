// =========================================================================
// typcas v2 Runtime Export Surface (Legacy-Free)
// =========================================================================
// Canonical v2 runtime export surface.
// =========================================================================

#import "../expr.typ": *

#import "../parse.typ": cas-parse
#import "../display.typ": cas-display, cas-equation

#import "../simplify.typ": simplify, simplify-meta-core, expand
#import "../eval-num.typ": eval-expr, substitute

#import "../calculus.typ": diff, integrate, diff-n, definite-integral, taylor, limit, implicit-diff
#import "../solve.typ": solve, solve-meta, factor

#import "../assumptions.typ": assume, assume-domain, assume-string, merge-assumptions, apply-assumptions, variable-domain, display-variable-domain
#import "../domain.typ": parse-domain, domain-to-string

#import "../restrictions.typ": mk-restriction, restriction-key, merge-restrictions, collect-structural-restrictions, collect-function-restrictions, filter-restrictions-by-assumptions, propagate-variable-domains, render-restriction-note, build-restriction-panel

#import "../steps.typ": step-diff, step-integrate, step-simplify, step-solve, display-steps, set-step-style, get-step-style, detail-valid, normalize-detail, detail-mode, detail-depth, resolve-detail-depth

#import "../system.typ": solve-linear-system, solve-nonlinear-system
#import "../poly.typ": poly-coeffs, coeffs-to-expr, poly-div, poly-gcd, partial-fractions
#import "../matrix.typ": mat-dims, mat-at, mat-add, mat-sub, mat-scale, mat-mul, mat-transpose, mat-det, mat-inv, mat-solve, mat-eigenvalues, mat-eigenvectors

#import "../truths/function-registry.typ": fn-registry, fn-alias-map, fn-canonical, fn-spec, fn-arity-ok, fn-known-names, fn-calc-rules, fn-square-power-integral-rules, fn-square-power-integral-spec
#import "../truths/identities.typ": identity-rules
#import "../identities.typ": wild, apply-identities-once, apply-identities-once-meta
