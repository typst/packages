// =========================================================================
// typst-CAS — A Lightweight Computer Algebra System for Typst
// =========================================================================
// Single entry point: #import "typst-CAS/lib.typ": *
// =========================================================================

// --- Core expression constructors ---
#import "src/expr.typ": const-e, const-expr, const-pi, cvar, num
#import "src/expr.typ": add, cdiv, mul, neg, pow, sub
#import "src/expr.typ": expr-eq, func, is-expr, is-type
#import "src/expr.typ": prod-of, sum-of

// Basic trig (6)
#import "src/expr.typ": cos-of, cot-of, csc-of, sec-of, sin-of, tan-of
// Inverse trig (6)
#import "src/expr.typ": arccos-of, arccot-of, arccsc-of, arcsec-of, arcsin-of, arctan-of
// Hyperbolic (6)
#import "src/expr.typ": cosh-of, coth-of, csch-of, sech-of, sinh-of, tanh-of
// Inverse hyperbolic (6)
#import "src/expr.typ": arccosh-of, arccoth-of, arccsch-of, arcsech-of, arcsinh-of, arctanh-of
// Other functions
#import "src/expr.typ": exp-of, ln-of, sqrt-of
// Abs & log
#import "src/expr.typ": abs-of, log-of

// Summation & product notation
#import "src/expr.typ": cprod, csum
// Matrix
#import "src/expr.typ": cmat, mat-id

// --- Simplification ---
#import "src/simplify.typ": simplify

// --- Calculus ---
#import "src/calculus.typ": diff, integrate
// Higher-order, definite, Taylor, limits
#import "src/calculus.typ": definite-integral, diff-n, limit, taylor

// --- Equation solving & factoring ---
#import "src/solve.typ": factor, solve

// --- Display ---
#import "src/display.typ": cas-display, cas-equation

// --- Numeric evaluation & substitution ---
#import "src/eval-num.typ": eval-expr, substitute

// --- Matrix algebra ---
#import "src/matrix.typ": mat-add, mat-det, mat-dims, mat-inv, mat-mul, mat-scale, mat-solve, mat-sub, mat-transpose

// --- Parser ---
#import "src/parse.typ": cas-parse
