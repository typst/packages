// =========================================================================
// typcas — Lightweight CAS (Computer Algebra System) in Typst
// =========================================================================
// Import this file to use the CAS in your Typst document:
//   #import "@preview/typcas:<version>": *
//   (view typst.toml for the correct version)
//
// All public functions accept raw Typst math content ($x^2 + 1$),
// strings ("x^2 + 1"), or pre-built CAS expressions (add(pow(x,2), 1)).
// =========================================================================

// Import internals — expression constructors are re-exported for manual use.
#import "src/expr.typ": *
#import "src/parse.typ": cas-parse

// =========================================================================
// DISPLAY
// =========================================================================

/// Render a CAS expression as Typst math content.
///
/// - expr: CAS expression, Typst math content, or string.
/// - returns: Typst math content suitable for use in $ ... $.
///
/// example
/// $ #cas-display(simplify($x + x$)) $  // shows 2x
///
#import "src/display.typ" as _disp
/// Public helper `cas-display`.
#let cas-display(expr) = _disp.cas-display(cas-parse(expr))

/// Render an equation lhs = rhs in display math.
///
/// - lhs: Left-hand side expression.
/// - rhs: Right-hand side expression.
/// - returns: Typst content: $ lhs = rhs $
#let cas-equation(lhs, rhs) = _disp.cas-equation(cas-parse(lhs), cas-parse(rhs))

// =========================================================================
// MATH OPERATORS (for content parsing)
// =========================================================================
// These let you write e.g. $arccsc(x)$ in Typst math mode.

/// Public helper `arccsc`.
#let arccsc = math.op("arccsc")
/// Public helper `arcsec`.
#let arcsec = math.op("arcsec")
/// Public helper `arccot`.
#let arccot = math.op("arccot")
/// Public helper `csch`.
#let csch = math.op("csch")
/// Public helper `sech`.
#let sech = math.op("sech")
/// Public helper `coth`.
#let coth = math.op("coth")
/// Public helper `arcsinh`.
#let arcsinh = math.op("arcsinh")
/// Public helper `arccosh`.
#let arccosh = math.op("arccosh")
/// Public helper `arctanh`.
#let arctanh = math.op("arctanh")
/// Public helper `arccsch`.
#let arccsch = math.op("arccsch")
/// Public helper `arcsech`.
#let arcsech = math.op("arcsech")
/// Public helper `arccoth`.
#let arccoth = math.op("arccoth")

#import "src/simplify.typ" as _sim
#import "src/eval-num.typ" as _eval
#import "src/calculus.typ": diff as _diff_core
#import "src/calculus.typ": integrate as _integrate_core
#import "src/calculus.typ": diff-n as _diff_n_core
#import "src/calculus.typ": definite-integral as _def_integral_core
#import "src/calculus.typ": taylor as _taylor_core
#import "src/calculus.typ": limit as _limit_core
#import "src/calculus.typ": implicit-diff as _implicit_diff_core
#import "src/solve.typ": solve as _solve_core
#import "src/solve.typ": solve-meta as _solve_meta_core
#import "src/solve.typ": factor as _factor_core
#import "src/matrix.typ" as _mat
#import "src/poly.typ" as _poly
#import "src/system.typ" as _sys
#import "src/steps.typ": step-diff as _step_diff_core
#import "src/steps.typ": step-integrate as _step_integrate_core
#import "src/steps.typ": step-simplify as _step_simplify_core
#import "src/steps.typ": step-solve as _step_solve_core
#import "src/steps.typ": display-steps as _display_steps_core
#import "src/assumptions.typ" as _assume
#import "src/helpers.typ": check-free-var as _check-free-var, check-free-vars as _check-free-vars

// =========================================================================
// SIMPLIFICATION & EXPANSION
// =========================================================================

/// Simplify an expression by applying algebraic rules repeatedly.
/// Collects like terms, folds constants, applies trig identities, etc.
///
/// - expr: The expression to simplify.
/// - expand: If true, expand products and powers before simplifying (default: false).
/// - assumptions: Optional assumptions dictionary (from `assume(...)` or
///   `merge-assumptions(...)`) applied after simplification.
/// - returns: A simplified CAS expression.
///
/// example
/// simplify($x + x$)       // => 2x
/// simplify($sin(x)^2 + cos(x)^2$)  // => 1
/// simplify($sqrt(x^2)$, assumptions: assume("x", real: true))  // => |x|
/// simplify($(x+3)^2 + (x+3)$, expand: true)  // => x² + 7x + 12
///
#let simplify(expr, expand: false, assumptions: none) = {
  let parsed = cas-parse(expr)
  if expand { parsed = _sim.expand(parsed) }
  let out = _sim.simplify(parsed)
  if assumptions != none {
    out = _sim.simplify(_assume.apply-assumptions(out, assumptions))
  }
  out
}

/// Expand an expression: distribute products and expand integer powers.
/// Does NOT collect like terms — use simplify(expand(...)) for full simplification.
///
/// - expr: The expression to expand.
/// - returns: An expanded CAS expression.
///
/// example
/// expand($(x+1)^2$)       // => x·x + x·1 + 1·x + 1·1
/// simplify(expand($(x+1)^2$))  // => x² + 2x + 1
///
#let expand(expr) = _sim.expand(cas-parse(expr))

// =========================================================================
// NUMERICAL EVALUATION & SUBSTITUTION
// =========================================================================

/// Evaluate an expression to a numeric value.
///
/// - expr: The expression to evaluate.
/// - bindings: Dictionary mapping variable names to numeric values, e.g. (x: 5, y: 3).
/// - returns: A float or integer result.
///
/// example
/// eval-expr($x^2 + 1$, (x: 3))  // => 10
///
#let eval-expr(expr, bindings) = _eval.eval-expr(cas-parse(expr), bindings)

/// Substitute a variable with a replacement expression.
///
/// - expr: The expression to substitute into.
/// - var: Variable name to replace (string, e.g. "x").
/// - repl: Replacement expression.
/// - returns: New CAS expression with all occurrences of var replaced.
///
/// example
/// substitute($x^2 + x$, "x", $a + 1$)  // => (a+1)² + (a+1)
///
#let substitute(expr, var, repl) = {
  _check-free-var(var)
  _eval.substitute(cas-parse(expr), var, cas-parse(repl))
}

// =========================================================================
// CALCULUS
// =========================================================================

/// Symbolic differentiation.
///
/// - expr: The expression to differentiate.
/// - var: Variable to differentiate with respect to (string, e.g. "x").
/// - assumptions: Optional assumptions dictionary applied to the derivative.
/// - returns: The derivative as a CAS expression.
///
/// example
/// diff($x^3$, "x")        // => 3x²
/// diff($sin(x)$, "x")     // => cos(x)
///
#let diff(expr, var, assumptions: none) = {
  _check-free-var(var)
  let src = cas-parse(expr)
  let src = if assumptions != none {
    _sim.simplify(_assume.apply-assumptions(src, assumptions))
  } else {
    src
  }
  let out = _diff_core(src, var)
  if assumptions != none {
    return _sim.simplify(_assume.apply-assumptions(out, assumptions))
  }
  out
}

/// Nth derivative: differentiate n times.
///
/// - expr: The expression to differentiate.
/// - var: Variable name (string).
/// - n: Number of times to differentiate (integer).
/// - assumptions: Optional assumptions dictionary applied to the result.
/// - returns: The nth derivative as a CAS expression.
///
/// example
/// diff-n($x^4$, "x", 3)   // => 24x
///
#let diff-n(expr, var, n, assumptions: none) = {
  _check-free-var(var)
  let src = cas-parse(expr)
  let src = if assumptions != none {
    _sim.simplify(_assume.apply-assumptions(src, assumptions))
  } else {
    src
  }
  let out = _diff_n_core(src, var, n)
  if assumptions != none {
    return _sim.simplify(_assume.apply-assumptions(out, assumptions))
  }
  out
}

/// Symbolic indefinite integration (antiderivative).
/// Handles power rule, trig/exp/log integrals, sum rule, and constant factoring.
///
/// - expr: The expression to integrate.
/// - var: Variable to integrate with respect to (string).
/// - assumptions: Optional assumptions dictionary applied to the antiderivative.
/// - returns: The antiderivative, or a symbolic integral node if no closed form is found.
///
/// example
/// integrate($x^2$, "x")   // => x³/3
/// integrate($cos(x)$, "x") // => sin(x)
///
#let integrate(expr, var, assumptions: none) = {
  _check-free-var(var)
  let src = cas-parse(expr)
  let src = if assumptions != none {
    _sim.simplify(_assume.apply-assumptions(src, assumptions))
  } else {
    src
  }
  let result = _integrate_core(src, var)
  let result = if assumptions != none {
    _sim.simplify(_assume.apply-assumptions(result, assumptions))
  } else {
    result
  }
  // Only add C if the result is not an "integral" node (failed integration)
  if type(result) == dictionary and result.at("type", default: "") == "integral" {
    result
  } else {
    _sim.simplify(add(result, cvar("C")))
  }
}

/// Definite integral: evaluate ∫_a^b expr dx.
///
/// - expr: The integrand.
/// - var: Variable of integration (string).
/// - a: Lower bound of integration.
/// - b: Upper bound of integration.
/// - assumptions: Optional assumptions dictionary applied to the final value.
/// - returns: The definite integral as a CAS expression (F(b) − F(a)).
///
/// example
/// definite-integral($x^2$, "x", 0, 1)  // => 1/3
///
#let definite-integral(expr, var, a, b, assumptions: none) = {
  _check-free-var(var)
  let out = _def_integral_core(cas-parse(expr), var, cas-parse(a), cas-parse(b))
  if assumptions != none {
    return _sim.simplify(_assume.apply-assumptions(out, assumptions))
  }
  out
}

/// Taylor series expansion around a point.
///
/// - expr: The function to expand.
/// - var: Variable name (string).
/// - x0: Point to expand around (e.g. 0 for Maclaurin series).
/// - n: Order of the expansion (integer). Terms up to (x - x0)^n are included.
/// - assumptions: Optional assumptions dictionary applied to the polynomial.
/// - returns: The Taylor polynomial as a CAS expression.
///
/// example
/// taylor($sin(x)$, "x", 0, 5)  // => x − x³/6 + x⁵/120
///
#let taylor(expr, var, x0, n, assumptions: none) = {
  _check-free-var(var)
  let out = _taylor_core(cas-parse(expr), var, cas-parse(x0), n)
  if assumptions != none {
    return _sim.simplify(_assume.apply-assumptions(out, assumptions))
  }
  out
}

/// Compute the limit of an expression as var → to.
///
/// - expr: The expression.
/// - var: Variable name (string).
/// - to: The value the variable approaches.
/// - returns: The limit as a CAS expression, or a symbolic limit node.
///
/// example
/// limit($sin(x) / x$, "x", 0)  // => 1
///
#let limit(expr, var, to) = {
  _check-free-var(var)
  _limit_core(cas-parse(expr), var, cas-parse(to))
}

/// Implicit differentiation: given F(x, y) = 0, compute dy/dx = −Fₓ/F_y.
///
/// - expr: The expression F(x, y) (set equal to zero implicitly).
/// - x: Independent variable name (string).
/// - y: Dependent variable name (string).
/// - returns: dy/dx as a CAS expression.
///
/// example
/// implicit-diff($x^2 + y^2 - 1$, "x", "y")  // => −x/y
///
#let implicit-diff(expr, x, y) = {
  _check-free-vars(x, y)
  _implicit_diff_core(cas-parse(expr), x, y)
}

// =========================================================================
// EQUATION SOLVING & FACTORING
// =========================================================================

/// Solve equation lhs = rhs for var.
/// Handles linear, quadratic, and some factorable polynomial equations.
///
/// - lhs: Left-hand side of the equation.
/// - rhs: Right-hand side of the equation.
/// - var: Variable to solve for (string).
/// - assumptions: Optional assumptions dictionary applied to each returned root.
/// - returns: Array of solution expressions. Empty array if no solutions found.
///
/// example
/// solve($x^2 - 4$, 0, "x")  // => (num(2), num(-2))
/// solve($2x + 6$, 0, "x")   // => (num(-3),)
///
#let solve(lhs, rhs, var, assumptions: none) = {
  _check-free-var(var)
  let sols = _solve_core(cas-parse(lhs), cas-parse(rhs), var)
  if assumptions == none { return sols }
  sols.map(s => _sim.simplify(_assume.apply-assumptions(s, assumptions)))
}

/// Solve equation lhs = rhs and return structured polynomial metadata.
///
/// Returns a dictionary with fields such as:
/// - `roots`: array of `{ expr, multiplicity, exact, numeric, complex }`
/// - `factor-form`: product form reconstructed from roots
/// - `square-free-gcd` and `square-free-part`
/// - `assumptions` argument: Optional assumptions dictionary applied to each
///   root expression in `meta.roots`.
///
/// example
/// let meta = solve-meta($x^4 + 1$, 0, "x")
/// meta.roots
///
#let solve-meta(lhs, rhs, var, assumptions: none) = {
  _check-free-var(var)
  let meta = _solve_meta_core(cas-parse(lhs), cas-parse(rhs), var)
  if assumptions == none or meta == none or meta.roots == none { return meta }
  let roots = meta.roots.map(r => (..r, expr: _sim.simplify(_assume.apply-assumptions(r.expr, assumptions))))
  (..meta, roots: roots)
}

/// Factor a polynomial expression.
///
/// - expr: The polynomial to factor.
/// - var: Variable name (string).
/// - returns: The factored form as a CAS expression (product of linear factors).
///
/// example
/// factor($x^2 - 4$, "x")  // => (x − 2)(x + 2)
///
#let factor(expr, var) = {
  _check-free-var(var)
  _factor_core(cas-parse(expr), var)
}

/// Build one assumptions block for a variable.
#let assume(var, real: false, positive: false, nonzero: false, nonnegative: false, negative: false) = {
  _assume.assume(var, real: real, positive: positive, nonzero: nonzero, nonnegative: nonnegative, negative: negative)
}

/// Merge multiple assumptions dictionaries.
#let merge-assumptions(..assumptions) = _assume.merge-assumptions(..assumptions)

/// Apply assumptions to an expression tree (without solving).
#let apply-assumptions(expr, assumptions) = _assume.apply-assumptions(cas-parse(expr), assumptions)

/// Solve a linear system symbolically.
///
/// - equations: array of `(lhs, rhs)` tuples.
/// - vars: array of variable-name strings in solve order.
/// - returns: dictionary `{var: solution-expr, ...}` or `none`.
#let solve-linear-system(equations, vars) = {
  for v in vars { _check-free-var(v) }
  let parsed = equations.map(eq => (cas-parse(eq.at(0)), cas-parse(eq.at(1))))
  _sys.solve-linear-system(parsed, vars)
}

/// Solve a nonlinear system numerically with Newton's method.
///
/// - equations: array of `(lhs, rhs)` tuples.
/// - vars: array of variable-name strings.
/// - initial: dictionary of initial guesses, e.g. `(x: 1.0, y: 1.0)`.
/// - returns: `(converged, iterations, solution)` or `none`.
#let solve-nonlinear-system(equations, vars, initial, max-iters: 40, tol: 1e-10) = {
  for v in vars { _check-free-var(v) }
  let residuals = equations.map(eq => simplify(sub(cas-parse(eq.at(0)), cas-parse(eq.at(1)))))
  _sys.solve-nonlinear-system(residuals, vars, initial, max-iters: max-iters, tol: tol)
}

// =========================================================================
// POLYNOMIAL OPERATIONS
// =========================================================================

/// Polynomial long division: p(x) ÷ d(x).
///
/// - p: Dividend polynomial expression.
/// - d: Divisor polynomial expression.
/// - var: Variable name (string).
/// - returns: (quotient-expr, remainder-expr) tuple, or none if inputs aren't polynomials.
///
/// example
/// let (q, r) = poly-div($x^3 - 1$, $x - 1$, "x")
/// // q = x² + x + 1,  r = 0
///
#let poly-div(p, d, var) = {
  _check-free-var(var)
  let result = _poly.poly-div(cas-parse(p), cas-parse(d), var)
  if result == none { return none }
  let (q, r) = result
  (_poly.coeffs-to-expr(q, var), _poly.coeffs-to-expr(r, var))
}

/// Partial fraction decomposition of a rational expression P(x)/Q(x).
/// Only handles denominators with rational roots.
///
/// - expr: A division expression (numerator/denominator).
/// - var: Variable name (string).
/// - returns: Sum of simpler fractions, or the original expression if decomposition fails.
///
/// example
/// partial-fractions($(2x + 3) / (x^2 - 1)$, "x")
///
#let partial-fractions(expr, var) = {
  _check-free-var(var)
  _poly.partial-fractions(cas-parse(expr), var)
}

// =========================================================================
// MATRIX OPERATIONS
// =========================================================================
// All matrix functions accept CAS matrices built with cmat().
// Matrices are constructed from nested arrays:
//   let m = cmat(((1, 2), (3, 4)))  // 2×2 matrix

/// Matrix addition: A + B. Matrices must have the same dimensions.
///
/// - a: First matrix (CAS matrix).
/// - b: Second matrix (CAS matrix).
/// - returns: Sum matrix.
#let mat-add(a, b) = _mat.mat-add(cas-parse(a), cas-parse(b))

/// Matrix subtraction: A − B.
///
/// - a: First matrix (CAS matrix).
/// - b: Second matrix (CAS matrix).
/// - returns: Difference matrix.
#let mat-sub(a, b) = _mat.mat-sub(cas-parse(a), cas-parse(b))

/// Scalar multiplication: c · M.
///
/// - c: Scalar value (number or CAS expression).
/// - m: Matrix (CAS matrix).
/// - returns: Scaled matrix.
#let mat-scale(c, m) = _mat.mat-scale(cas-parse(c), cas-parse(m))

/// Matrix multiplication: A × B. Inner dimensions must match.
///
/// - a: Left matrix (CAS matrix, m×n).
/// - b: Right matrix (CAS matrix, n×p).
/// - returns: Product matrix (m×p).
#let mat-mul(a, b) = _mat.mat-mul(cas-parse(a), cas-parse(b))

/// Matrix transpose: swap rows and columns.
///
/// - m: Matrix (CAS matrix).
/// - returns: Transposed matrix.
#let mat-transpose(m) = _mat.mat-transpose(cas-parse(m))

/// Determinant of an n×n matrix (cofactor expansion, any size).
///
/// - m: Square matrix (CAS matrix).
/// - returns: Determinant as a CAS expression.
///
/// example
/// mat-det(cmat(((1, 2), (3, 4))))  // => -2
///
#let mat-det(m) = _mat.mat-det(cas-parse(m))

/// Matrix inverse: A⁻¹ via adjugate/determinant (any n×n).
///
/// - m: Square matrix (CAS matrix).
/// - returns: Inverse matrix (CAS matrix).
///
/// example
/// mat-inv(cmat(((1, 2), (3, 4))))
///
#let mat-inv(m) = _mat.mat-inv(cas-parse(m))

/// Solve Ax = b using Cramer's rule (any n×n system).
///
/// - a: Coefficient matrix (CAS matrix, n×n).
/// - b: Right-hand side column vector (array of n CAS expressions).
/// - returns: Array of n solution expressions [x₁, x₂, ..., xₙ].
///
/// example
/// mat-solve(cmat(((2, 1), (1, 3))), (num(5), num(6)))
///
#let mat-solve(a, b) = _mat.mat-solve(cas-parse(a), b.map(cas-parse))

/// Eigenvalues of a 2×2 matrix using trace/determinant formula.
///
/// - m: Square 2×2 matrix (CAS matrix).
/// - returns: Array of eigenvalue expressions.
///
/// example
/// mat-eigenvalues(cmat(((2, 1), (1, 2))))  // => (3, 1)
///
#let mat-eigenvalues(m) = _mat.mat-eigenvalues(cas-parse(m))

/// Eigenvectors of a 2×2 matrix.
///
/// - m: Square 2×2 matrix (CAS matrix).
/// - returns: Array of (eigenvalue, (v1, v2)) pairs.
///
/// example
/// mat-eigenvectors(cmat(((2, 1), (1, 2))))  // => ((3, (1, 1)), (1, (1, -1)))
///
#let mat-eigenvectors(m) = _mat.mat-eigenvectors(cas-parse(m))

// =========================================================================
// STEP-BY-STEP MODE
// =========================================================================
// These functions return arrays of typed step dictionaries.
// Each step has a `kind` field: "header", "define", "apply", "combine", "note".
// Use display-steps() to render them as formatted Typst content.
//
// The `depth` parameter controls recursion (default 1):
//   depth 0 — only final result with rule name
//   depth 1 — one level of decomposition (split terms, name, show results)
//   depth 2+ — recursive sub-steps within sub-steps

/// Step-by-step simplification showing each rule applied.
///
/// - expr: The expression to simplify.
/// - depth: Recursion depth (default 1).
/// - returns: Array of typed step dictionaries.
///
/// example
/// let steps = step-simplify($0 dot x + 5$)
/// display-steps($0 dot x + 5$, steps)
///
#let step-simplify(expr, depth: 1) = _step_simplify_core(cas-parse(expr))

/// Step-by-step differentiation showing each rule applied
/// (power rule, chain rule, product rule, quotient rule, etc.).
///
/// - expr: The expression to differentiate.
/// - var: Variable name (string).
/// - depth: Recursion depth (default 1).
/// - returns: Array of typed step dictionaries.
///
/// example
/// let steps = step-diff($x^2 sin(x)$, "x")
/// display-steps($x^2 sin(x)$, steps)
///
#let step-diff(expr, var, depth: 1) = {
  _check-free-var(var)
  _step_diff_core(cas-parse(expr), var)
}

/// Step-by-step integration showing each rule applied.
///
/// - expr: The expression to integrate.
/// - var: Variable name (string).
/// - depth: Recursion depth (default 1).
/// - returns: Array of typed step dictionaries.
///
/// example
/// let steps = step-integrate($x^2 + 3x + 1$, "x")
/// display-steps($x^2 + 3x + 1$, steps)
///
#let step-integrate(expr, var, depth: 1) = {
  _check-free-var(var)
  _step_integrate_core(cas-parse(expr), var)
}

/// Step-by-step equation solving showing each transformation.
///
/// - lhs: Left-hand side of the equation.
/// - rhs: Right-hand side of the equation.
/// - var: Variable to solve for (string).
/// - depth: Recursion depth (default 1).
/// - returns: Array of typed step dictionaries.
///
/// example
/// let steps = step-solve($x^2 - 4$, 0, "x")
/// display-steps($x^2 - 4$, steps)
///
#let step-solve(lhs, rhs, var, depth: 1) = {
  _check-free-var(var)
  _step_solve_core(cas-parse(lhs), cas-parse(rhs), var)
}

/// Render step-by-step output as formatted Typst content.
/// Shows a chain-of-equals with sidebar definitions and sub-computations.
///
/// - original: The original expression (shown at the top).
/// - steps: Array of typed step dictionaries from a step-* function.
/// - operation: Optional: "diff", "integrate", or "solve" to show full equation on first line.
/// - var: Variable name string (needed when operation is set).
/// - rhs: Right-hand side expression for solve mode.
#let display-steps(original, steps, operation: none, var: none, rhs: none) = {
  if var != none { _check-free-var(var) }
  let rhs-parsed = if rhs != none { cas-parse(rhs) } else { none }
  _display_steps_core(cas-parse(original), steps, operation: operation, var: var, rhs: rhs-parsed)
}

// =========================================================================
// PIECEWISE FUNCTIONS
// =========================================================================
// piecewise() is re-exported from expr.typ and available directly.
// Use it to define piecewise functions:
//
//   let f = piecewise(((cvar("x"), "x > 0"), (neg(cvar("x")), none)))
//   $ f(x) = #cas-display(f) $
// =========================================================================
