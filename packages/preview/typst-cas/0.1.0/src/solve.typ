// =========================================================================
// CAS Equation Solver
// =========================================================================
// Solves equations of the form lhs = rhs for a given variable.
// Supports linear and quadratic equations.
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify

// --- Internal helpers ---

/// Simple var containment check
#let _contains-var-simple(expr, v) = {
  if is-type(expr, "var") { return expr.name == v }
  if is-type(expr, "num") or is-type(expr, "const") { return false }
  if is-type(expr, "neg") { return _contains-var-simple(expr.arg, v) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return _contains-var-simple(expr.args.at(0), v) or _contains-var-simple(expr.args.at(1), v)
  }
  if is-type(expr, "pow") { return _contains-var-simple(expr.base, v) or _contains-var-simple(expr.exp, v) }
  if is-type(expr, "div") { return _contains-var-simple(expr.num, v) or _contains-var-simple(expr.den, v) }
  if is-type(expr, "func") { return _contains-var-simple(expr.arg, v) }
  return false
}

/// Collect coefficients a, b from a linear expression a*x + b.
/// Returns (a: expr, b: expr) or none if not linear.
#let _linear-coeffs(expr, v) = {
  let e = simplify(expr)

  // Case: just the variable x  =>  1*x + 0
  if is-type(e, "var") and e.name == v {
    return (a: num(1), b: num(0))
  }

  // Case: a number (no x)  =>  0*x + c
  if is-type(e, "num") or is-type(e, "const") {
    return (a: num(0), b: e)
  }

  // Case: neg(x)  =>  -1*x + 0
  if is-type(e, "neg") {
    if is-type(e.arg, "var") and e.arg.name == v {
      return (a: num(-1), b: num(0))
    }
    let inner = _linear-coeffs(e.arg, v)
    if inner != none {
      return (a: simplify(neg(inner.a)), b: simplify(neg(inner.b)))
    }
  }

  // Case: c * x  =>  c*x + 0
  if is-type(e, "mul") {
    let l = e.args.at(0)
    let r = e.args.at(1)
    // num * var
    if not _contains-var-simple(l, v) and is-type(r, "var") and r.name == v {
      return (a: l, b: num(0))
    }
    if not _contains-var-simple(r, v) and is-type(l, "var") and l.name == v {
      return (a: r, b: num(0))
    }
    // If neither side has the var, it's a constant
    if not _contains-var-simple(l, v) and not _contains-var-simple(r, v) {
      return (a: num(0), b: e)
    }
  }

  // Case: a + b
  if is-type(e, "add") {
    let lc = _linear-coeffs(e.args.at(0), v)
    let rc = _linear-coeffs(e.args.at(1), v)
    if lc != none and rc != none {
      return (
        a: simplify(add(lc.a, rc.a)),
        b: simplify(add(lc.b, rc.b)),
      )
    }
  }

  // Not recognized as linear
  return none
}

/// Extract quadratic coefficients a, b, c from ax^2 + bx + c.
/// Returns (a: expr, b: expr, c: expr) or none.
#let _quadratic-coeffs(expr, v) = {
  let e = simplify(expr)

  // Try to identify x^2 terms, x terms, and constant terms
  // We'll check common patterns

  // x^2  =>  a=1, b=0, c=0
  if is-type(e, "pow") and is-type(e.base, "var") and e.base.name == v {
    if is-type(e.exp, "num") and e.exp.val == 2 {
      return (a: num(1), b: num(0), c: num(0))
    }
  }

  // k * x^2  =>  a=k, b=0, c=0
  if is-type(e, "mul") {
    let l = e.args.at(0)
    let r = e.args.at(1)
    if not _contains-var-simple(l, v) and is-type(r, "pow") {
      if is-type(r.base, "var") and r.base.name == v and is-type(r.exp, "num") and r.exp.val == 2 {
        return (a: l, b: num(0), c: num(0))
      }
    }
  }

  // sum: try to split into quadratic + rest
  if is-type(e, "add") {
    let l = e.args.at(0)
    let r = e.args.at(1)

    let lq = _quadratic-coeffs(l, v)
    let rq = _quadratic-coeffs(r, v)

    if lq != none and rq != none {
      return (
        a: simplify(add(lq.a, rq.a)),
        b: simplify(add(lq.b, rq.b)),
        c: simplify(add(lq.c, rq.c)),
      )
    }

    // One side is quadratic, other is linear
    if lq != none {
      let rl = _linear-coeffs(r, v)
      if rl != none {
        return (
          a: lq.a,
          b: simplify(add(lq.b, rl.a)),
          c: simplify(add(lq.c, rl.b)),
        )
      }
    }
    if rq != none {
      let ll = _linear-coeffs(l, v)
      if ll != none {
        return (
          a: rq.a,
          b: simplify(add(rq.b, ll.a)),
          c: simplify(add(rq.c, ll.b)),
        )
      }
    }
  }

  // Fall back: check if it's linear (quadratic with a=0)
  let lin = _linear-coeffs(e, v)
  if lin != none {
    return (a: num(0), b: lin.a, c: lin.b)
  }

  return none
}

// --- Public API ---

/// Solve the equation `lhs = rhs` for variable `v` (string).
/// Returns an array of solution expressions.
#let solve(lhs, rhs, v) = {
  // Auto-wrap raw numbers
  let lhs = if type(lhs) == int or type(lhs) == float { num(lhs) } else { lhs }
  let rhs = if type(rhs) == int or type(rhs) == float { num(rhs) } else { rhs }
  // Move everything to one side: lhs - rhs = 0
  let combined = simplify(sub(lhs, rhs))

  // Try linear: ax + b = 0  =>  x = -b/a
  let lin = _linear-coeffs(combined, v)
  if lin != none and not expr-eq(lin.a, num(0)) {
    let sol = simplify(cdiv(neg(lin.b), lin.a))
    return (sol,)
  }

  // Try quadratic: ax^2 + bx + c = 0
  let quad = _quadratic-coeffs(combined, v)
  if quad != none and not expr-eq(quad.a, num(0)) {
    let a = quad.a
    let b = quad.b
    let c = quad.c
    // discriminant = b^2 - 4ac
    let disc = simplify(sub(pow(b, num(2)), mul(num(4), mul(a, c))))
    // x = (-b ± √disc) / (2a)
    let neg-b = neg(b)
    let two-a = mul(num(2), a)
    let sqrt-disc = pow(disc, cdiv(num(1), num(2)))
    let sol1 = simplify(cdiv(add(neg-b, sqrt-disc), two-a))
    let sol2 = simplify(cdiv(sub(neg-b, sqrt-disc), two-a))
    return (sol1, sol2)
  }

  // Cannot solve
  return ()
}

// =========================================================================
// POLYNOMIAL FACTORING
// =========================================================================

/// Get integer factors of |n|
#let _int-factors(n) = {
  let n = int(calc.abs(n))
  if n == 0 { return (1,) }
  let result = ()
  for i in range(1, n + 1) {
    if calc.rem(n, i) == 0 {
      result.push(i)
    }
  }
  result
}

/// Evaluate a polynomial coefficient array at x (Horner's method).
/// coeffs is (a_0, a_1, ..., a_n) where a_i is the coeff of x^i.
#let _poly-eval-at(coeffs, x) = {
  let result = 0
  let i = coeffs.len() - 1
  while i >= 0 {
    result = result * x + coeffs.at(i)
    i -= 1
  }
  result
}

/// Polynomial long division: divide coeffs by (x - root).
/// Returns the quotient coefficient array.
#let _poly-divide(coeffs, root) = {
  let n = coeffs.len() - 1 // degree
  let result = (0,) * n
  result.at(n - 1) = coeffs.at(n)
  let i = n - 2
  while i >= 0 {
    result.at(i) = coeffs.at(i + 1) + root * result.at(i + 1)
    i -= 1
  }
  result
}

/// Extract polynomial coefficients from a simplified expression.
/// Returns (a_0, a_1, ..., a_n) or none if not polynomial.
#let _extract-poly-coeffs(expr, v) = {
  let e = simplify(expr)

  // Constant
  if is-type(e, "num") { return (e.val,) }

  // Variable: 0 + 1*x
  if is-type(e, "var") and e.name == v { return (0, 1) }

  // Negative
  if is-type(e, "neg") {
    let inner = _extract-poly-coeffs(e.arg, v)
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
    let left = _extract-poly-coeffs(e.args.at(0), v)
    let right = _extract-poly-coeffs(e.args.at(1), v)
    if left == none or right == none { return none }
    let max-len = calc.max(left.len(), right.len())
    let result = (0,) * max-len
    for i in range(left.len()) { result.at(i) = result.at(i) + left.at(i) }
    for i in range(right.len()) { result.at(i) = result.at(i) + right.at(i) }
    return result
  }

  return none
}

/// Factor a polynomial expression over the rationals.
/// Returns a product of linear factors and possibly an irreducible remainder.
/// E.g., factor(x^2 - 5x + 6, "x") => (x - 2)(x - 3)
#let factor(expr, v) = {
  let coeffs = _extract-poly-coeffs(simplify(expr), v)
  if coeffs == none { return expr } // Can't factor

  let degree = coeffs.len() - 1
  if degree <= 1 { return simplify(expr) } // Linear or constant

  // Try rational roots: ±(factors of a_0) / (factors of a_n)
  let a0-factors = _int-factors(coeffs.at(0))
  let an-factors = _int-factors(coeffs.at(degree))
  let roots = ()
  let current-coeffs = coeffs

  // Candidate roots
  let candidates = ()
  for p in a0-factors {
    for q in an-factors {
      let r = p / q
      if r not in candidates { candidates.push(r) }
      if -r not in candidates { candidates.push(-r) }
    }
  }

  // Test each candidate
  for root in candidates {
    if current-coeffs.len() <= 1 { break }
    let val = _poly-eval-at(current-coeffs, root)
    if calc.abs(val) < 1e-10 {
      roots.push(root)
      current-coeffs = _poly-divide(current-coeffs, root)
      // Check same root again (multiplicity)
      let val2 = _poly-eval-at(current-coeffs, root)
      if calc.abs(val2) < 1e-10 {
        roots.push(root)
        current-coeffs = _poly-divide(current-coeffs, root)
      }
    }
  }

  if roots.len() == 0 { return simplify(expr) } // No rational roots

  // Build factored form
  let result = num(1)
  // Leading coefficient of remaining quotient
  let lead = current-coeffs.at(current-coeffs.len() - 1)
  if lead != 1 {
    result = num(int(lead))
  }
  for root in roots {
    let root-int = int(root)
    let factor-expr = if root-int == 0 {
      cvar(v)
    } else if root-int > 0 {
      sub(cvar(v), num(root-int))
    } else {
      add(cvar(v), num(-root-int))
    }
    result = mul(result, factor-expr)
  }

  // Remaining quotient (if degree > 0)
  if current-coeffs.len() > 1 {
    // Build remaining polynomial
    let rem = num(0)
    for i in range(current-coeffs.len()) {
      let c = current-coeffs.at(i)
      if c == 0 { continue }
      let term = if i == 0 {
        num(int(c))
      } else if i == 1 {
        if c == 1 { cvar(v) } else { mul(num(int(c)), cvar(v)) }
      } else {
        if c == 1 { pow(cvar(v), num(i)) } else { mul(num(int(c)), pow(cvar(v), num(i))) }
      }
      rem = add(rem, term)
    }
    rem = simplify(rem)
    if not expr-eq(rem, num(1)) and not expr-eq(rem, num(0)) {
      result = mul(result, rem)
    }
  }

  return result
}
