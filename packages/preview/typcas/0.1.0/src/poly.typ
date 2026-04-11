// =========================================================================
// CAS Polynomial Utilities
// =========================================================================
// Polynomial division, GCD, and partial fraction decomposition.
// Coefficients are arrays (a_0, a_1, ..., a_n) where a_k is the
// coefficient of x^k.
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify

// =========================================================================
// COEFFICIENT EXTRACTION
// =========================================================================

/// Extract polynomial coefficients from an expression.
/// The result is an array (a_0, a_1, ..., a_n) where a_k is the coefficient of x^k.
///
/// - expr: A CAS expression representing a polynomial.
/// - v: Variable name (string), e.g. "x".
/// - returns: Array of numeric coefficients (a_0, a_1, ..., a_n), or none if not a polynomial.
///
/// example
/// poly-coeffs($x^2 + 3x + 5$, "x")  // => (5, 3, 1)
/// 
#let poly-coeffs(expr, v) = {
  let e = simplify(expr)

  // Constant
  if is-type(e, "num") { return (e.val,) }

  // Variable: 0 + 1*x
  if is-type(e, "var") and e.name == v { return (0, 1) }

  // Negative
  if is-type(e, "neg") {
    let inner = poly-coeffs(e.arg, v)
    if inner == none { return none }
    return inner.map(c => -c)
  }

  // c * x^n
  if is-type(e, "mul") {
    let a = e.args.at(0)
    let b = e.args.at(1)
    if is-type(a, "num") {
      if is-type(b, "var") and b.name == v {
        return (0, a.val)
      }
      if is-type(b, "pow") and is-type(b.base, "var") and b.base.name == v and is-type(b.exp, "num") {
        let deg = int(b.exp.val)
        let result = (0,) * (deg + 1)
        result.at(deg) = a.val
        return result
      }
    }
  }

  // x^n
  if is-type(e, "pow") and is-type(e.base, "var") and e.base.name == v and is-type(e.exp, "num") {
    let deg = int(e.exp.val)
    let result = (0,) * (deg + 1)
    result.at(deg) = 1
    return result
  }

  // Addition: try to add coefficient vectors
  if is-type(e, "add") {
    let left = poly-coeffs(e.args.at(0), v)
    let right = poly-coeffs(e.args.at(1), v)
    if left == none or right == none { return none }
    let max-len = calc.max(left.len(), right.len())
    let result = (0,) * max-len
    for i in range(left.len()) { result.at(i) = result.at(i) + left.at(i) }
    for i in range(right.len()) { result.at(i) = result.at(i) + right.at(i) }
    return result
  }

  return none
}

/// Rebuild a CAS expression from a coefficient array.
///
/// - coeffs: Array of numeric coefficients (a_0, a_1, ..., a_n) where a_k is the coefficient of var^k.
/// - v: Variable name (string).
/// - returns: CAS expression equivalent to a_0 + a_1·x + a_2·x² + ...
#let coeffs-to-expr(coeffs, v) = {
  // Strip trailing zeros
  let c = coeffs
  while c.len() > 1 and c.at(c.len() - 1) == 0 {
    c = c.slice(0, c.len() - 1)
  }

  let terms = ()
  let i = c.len() - 1
  while i >= 0 {
    let coeff = c.at(i)
    if calc.abs(coeff - calc.round(coeff)) < 1e-10 {
      coeff = int(calc.round(coeff))
    }
    if coeff != 0 {
      let term = if i == 0 {
        num(coeff)
      } else if i == 1 {
        if coeff == 1 { cvar(v) } else if coeff == -1 { neg(cvar(v)) } else { mul(num(coeff), cvar(v)) }
      } else {
        let xn = pow(cvar(v), num(i))
        if coeff == 1 { xn } else if coeff == -1 { neg(xn) } else { mul(num(coeff), xn) }
      }
      terms.push(term)
    }
    i -= 1
  }

  if terms.len() == 0 { return num(0) }
  let result = terms.at(0)
  for i in range(1, terms.len()) {
    result = add(result, terms.at(i))
  }
  result
}

// =========================================================================
// POLYNOMIAL LONG DIVISION
// =========================================================================

/// Remove trailing zeros from coefficient array.
#let _trim(c) = {
  let r = c
  while r.len() > 1 and r.at(r.len() - 1) == 0 {
    r = r.slice(0, r.len() - 1)
  }
  r
}

/// Polynomial long division: p(x) ÷ d(x).
/// Accepts either coefficient arrays or CAS expressions.
///
/// - p: Dividend — CAS expression or coefficient array.
/// - d: Divisor — CAS expression or coefficient array.
/// - v: Variable name (string).
/// - returns: (quotient-coeffs, remainder-coeffs) tuple, or none if inputs aren't polynomials.
///
/// example
/// poly-div($x^3 - 1$, $x - 1$, "x")  // => ((1, 1, 1), (0,))  i.e. x²+x+1 remainder 0
/// 
#let poly-div(p, d, v) = {
  // Accept either coefficient arrays or expressions
  let pc = if type(p) == array { p } else { poly-coeffs(p, v) }
  let dc = if type(d) == array { d } else { poly-coeffs(d, v) }
  if pc == none or dc == none { return none }

  let pc = _trim(pc)
  let dc = _trim(dc)

  let deg-p = pc.len() - 1
  let deg-d = dc.len() - 1

  if deg-d > deg-p {
    return ((0,), pc)
  }

  // Long division
  let remainder = pc
  let quotient = (0,) * (deg-p - deg-d + 1)

  let lead-d = dc.at(deg-d)
  let i = deg-p
  while i >= deg-d {
    let coeff = remainder.at(i) / lead-d
    quotient.at(i - deg-d) = coeff
    // Subtract coeff * d(x) * x^(i - deg-d)
    for j in range(dc.len()) {
      remainder.at(i - deg-d + j) = remainder.at(i - deg-d + j) - coeff * dc.at(j)
    }
    i -= 1
  }

  (_trim(quotient), _trim(remainder))
}

// =========================================================================
// POLYNOMIAL GCD (Euclidean algorithm)
// =========================================================================

/// GCD of two polynomials via the Euclidean algorithm.
/// Result is made monic (leading coefficient = 1).
///
/// - p: First polynomial — CAS expression or coefficient array.
/// - d: Second polynomial — CAS expression or coefficient array.
/// - v: Variable name (string).
/// - returns: GCD as a monic coefficient array, or none if inputs aren't polynomials.
#let poly-gcd(p, d, v) = {
  let pc = if type(p) == array { p } else { poly-coeffs(p, v) }
  let dc = if type(d) == array { d } else { poly-coeffs(d, v) }
  if pc == none or dc == none { return none }

  let a = _trim(pc)
  let b = _trim(dc)

  let max-iter = 50
  let iter = 0
  while b.len() > 1 or b.at(0) != 0 {
    if iter > max-iter { break }
    let (_, rem) = poly-div(a, b, v)
    a = b
    b = _trim(rem)
    iter += 1
  }

  // Make monic
  let lead = a.at(a.len() - 1)
  if lead != 0 and lead != 1 {
    a = a.map(c => c / lead)
  }
  a
}

// =========================================================================
// PARTIAL FRACTION DECOMPOSITION
// =========================================================================

/// Find all rational roots of a polynomial using rational root theorem.
/// Returns array of (root, multiplicity) pairs.
#let _find-rational-roots(coeffs) = {
  let n = coeffs.len() - 1
  if n < 1 { return () }

  let lead = int(calc.abs(coeffs.at(n)))
  let const = int(calc.abs(coeffs.at(0)))
  if const == 0 { const = 1 }
  if lead == 0 { return () }

  // Candidate roots: ±p/q where p | const, q | lead
  let p-factors = ()
  for i in range(1, const + 1) {
    if calc.rem(const, i) == 0 { p-factors.push(i) }
  }
  let q-factors = ()
  for i in range(1, lead + 1) {
    if calc.rem(lead, i) == 0 { q-factors.push(i) }
  }

  let roots = ()
  let current = coeffs

  let found = true
  while found {
    found = false
    for p in p-factors {
      for q in q-factors {
        for sign in (1, -1) {
          let r = sign * p / q
          // Evaluate polynomial at r using Horner's method
          let val = 0
          let i = current.len() - 1
          while i >= 0 {
            val = val * r + current.at(i)
            i -= 1
          }
          if calc.abs(val) < 1e-10 {
            // Found a root! Deflate by synthetic division
            let n2 = current.len() - 1
            let new-coeffs = (0,) * n2
            new-coeffs.at(n2 - 1) = current.at(n2)
            let i2 = n2 - 2
            while i2 >= 0 {
              new-coeffs.at(i2) = current.at(i2 + 1) + r * new-coeffs.at(i2 + 1)
              i2 -= 1
            }
            current = _trim(new-coeffs)
            // Check multiplicity
            let existing = roots.filter(((rt, _)) => calc.abs(rt - r) < 1e-10)
            if existing.len() > 0 {
              roots = roots.map(((rt, m)) => if calc.abs(rt - r) < 1e-10 { (rt, m + 1) } else { (rt, m) })
            } else {
              roots.push((r, 1))
            }
            found = true
            break
          }
        }
        if found { break }
      }
      if found { break }
    }
  }

  roots
}

/// Partial fraction decomposition of a rational expression P(x)/Q(x).
/// Uses the rational root theorem to find roots, then Heaviside cover-up for coefficients.
/// Only handles denominators whose roots are rational numbers.
///
/// - expr: A CAS division expression (numerator/denominator).
/// - v: Variable name (string).
/// - returns: Sum of simpler fractions as a CAS expression. Returns expr unchanged if decomposition fails.
///
/// example
/// partial-fractions(cdiv($2x + 3$, $x^2 - 1$), "x")  // => A/(x-1) + B/(x+1)
/// 
#let partial-fractions(expr, v) = {
  // Expect a "div" node
  if not is-type(expr, "div") { return expr }

  let num-coeffs = poly-coeffs(expr.num, v)
  let den-coeffs = poly-coeffs(expr.den, v)
  if num-coeffs == none or den-coeffs == none { return expr }

  // If deg(num) >= deg(den), do polynomial division first
  let poly-part = num(0)
  let rem-coeffs = num-coeffs
  if num-coeffs.len() >= den-coeffs.len() {
    let (q, r) = poly-div(num-coeffs, den-coeffs, v)
    poly-part = coeffs-to-expr(q, v)
    rem-coeffs = r
  }

  // Find roots of denominator
  let roots = _find-rational-roots(den-coeffs)
  if roots.len() == 0 { return expr }

  // Set up: P(x)/Q(x) = Σ A_i / (x - r_i)^k
  // Use Heaviside cover-up method for simple roots
  let terms = ()
  for (root, mult) in roots {
    if mult == 1 {
      // A = P(root) / Q'(root) where Q'(root) is product of (root - r_j) for j ≠ i
      let p-val = 0
      let i = rem-coeffs.len() - 1
      while i >= 0 {
        p-val = p-val * root + rem-coeffs.at(i)
        i -= 1
      }
      // Q(x) / (x - root) evaluated at x = root
      let q-prime = 1
      for (other-root, other-mult) in roots {
        if calc.abs(other-root - root) > 1e-10 {
          for _ in range(other-mult) {
            q-prime = q-prime * (root - other-root)
          }
        }
      }
      // Account for leading coefficient of denominator
      let lead = den-coeffs.at(den-coeffs.len() - 1)
      q-prime = q-prime * lead

      if q-prime != 0 {
        let a-val = p-val / q-prime
        if calc.abs(a-val) > 1e-10 {
          let denom = if root == 0 { cvar(v) } else if root > 0 { sub(cvar(v), num(root)) } else {
            add(cvar(v), num(-root))
          }

          // Try to express as fraction of integers
          let a-expr = num(a-val)
          // Check if it's close to a simple fraction
          for d in range(1, 13) {
            let n = calc.round(a-val * d)
            if calc.abs(a-val - n / d) < 1e-10 {
              if d == 1 { a-expr = num(int(n)) } else { a-expr = cdiv(num(int(n)), num(d)) }
              break
            }
          }

          terms.push(cdiv(a-expr, denom))
        }
      }
    } else {
      // For repeated roots, use successive differentiation approach
      // Simplified: just return original for now
      return expr
    }
  }

  // Check if all roots were found (degree match)
  let total-roots = roots.map(((_, m)) => m).sum()
  let den-deg = den-coeffs.len() - 1
  if total-roots < den-deg {
    // Not all roots found; return original
    return expr
  }

  // Build result: poly-part + sum of partial fractions
  let result = poly-part
  for term in terms {
    result = add(result, term)
  }
  simplify(result)
}
