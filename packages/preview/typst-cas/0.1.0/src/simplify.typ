// =========================================================================
// CAS Simplification Engine
// =========================================================================
// Bottom-up recursive simplifier. Applies algebraic rules until fixed point.
// =========================================================================

#import "expr.typ": *

// --- Internal helpers ---

/// Check if expr is num(0)
#let _is-zero(e) = is-type(e, "num") and e.val == 0

/// Check if expr is num(1)
#let _is-one(e) = is-type(e, "num") and e.val == 1

/// Check if expr is a numeric literal
#let _is-num(e) = is-type(e, "num")

// --- Single-pass simplify helpers ---

/// Flatten nested add trees into a list of terms.
#let _flatten-add(expr) = {
  if is-type(expr, "add") {
    let left = _flatten-add(expr.args.at(0))
    let right = _flatten-add(expr.args.at(1))
    return left + right
  }
  return (expr,)
}

/// Extract (coefficient, base) from a term.
/// 3x → (3, x), neg(x) → (-1, x), x → (1, x), num(5) → (5, num(1))
#let _get-coeff-and-base(expr) = {
  if is-type(expr, "num") { return (expr.val, num(1)) }
  if is-type(expr, "neg") {
    if is-type(expr.arg, "num") { return (-expr.arg.val, num(1)) }
    if is-type(expr.arg, "mul") and is-type(expr.arg.args.at(0), "num") {
      return (-expr.arg.args.at(0).val, expr.arg.args.at(1))
    }
    return (-1, expr.arg)
  }
  if is-type(expr, "mul") and is-type(expr.args.at(0), "num") {
    return (expr.args.at(0).val, expr.args.at(1))
  }
  return (1, expr)
}

/// Collect like terms from a flat list of expressions.
/// Returns a new list of simplified terms.
#let _collect-like-terms(terms) = {
  // Build groups: array of (coeff, base)
  let groups = () // array of (total_coeff, base_expr)

  for term in terms {
    let (coeff, base) = _get-coeff-and-base(term)
    let found = false
    let new-groups = ()
    for g in groups {
      if not found and expr-eq(g.at(1), base) {
        new-groups.push((g.at(0) + coeff, base))
        found = true
      } else {
        new-groups.push(g)
      }
    }
    if not found {
      new-groups.push((coeff, base))
    }
    groups = new-groups
  }

  // Rebuild terms from groups
  let result = ()
  for g in groups {
    let (c, base) = g
    if c == 0 { continue }
    if expr-eq(base, num(1)) {
      result.push(num(c))
    } else if c == 1 {
      result.push(base)
    } else if c == -1 {
      result.push(neg(base))
    } else {
      result.push(mul(num(c), base))
    }
  }
  result
}

// --- Single-pass simplify ---

/// One pass of bottom-up simplification.
#let _simplify-once(expr) = {
  // Base cases: leaves don't simplify further
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  // --- Negation ---
  if is-type(expr, "neg") {
    let a = _simplify-once(expr.arg)
    // neg(num(n)) => num(-n)
    if _is-num(a) { return num(-a.val) }
    // neg(neg(x)) => x
    if is-type(a, "neg") { return a.arg }
    return neg(a)
  }

  // --- Addition ---
  if is-type(expr, "add") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    // Constant folding
    if _is-num(a) and _is-num(b) { return num(a.val + b.val) }
    // Identity: x + 0 = x
    if _is-zero(b) { return a }
    if _is-zero(a) { return b }
    // x + neg(x) = 0  and neg(x) + x = 0
    if is-type(b, "neg") and expr-eq(a, b.arg) { return num(0) }
    if is-type(a, "neg") and expr-eq(a.arg, b) { return num(0) }
    // x + neg(y) where x and y are nums => fold
    if _is-num(a) and is-type(b, "neg") and _is-num(b.arg) {
      return num(a.val - b.arg.val)
    }

    // --- Flatten additions and collect like terms ---
    let terms = _flatten-add(add(a, b))
    if terms.len() >= 2 {
      let collected = _collect-like-terms(terms)
      if collected.len() == 0 { return num(0) }
      if collected.len() == 1 { return collected.at(0) }
      // Check if collection actually changed anything
      if collected.len() < terms.len() {
        // Rebuild right-associatively
        let result = collected.at(collected.len() - 1)
        let idx = collected.len() - 2
        while idx >= 0 {
          result = add(collected.at(idx), result)
          idx -= 1
        }
        return result
      }
    }

    return add(a, b)
  }

  // --- Multiplication ---
  if is-type(expr, "mul") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    // Constant folding
    if _is-num(a) and _is-num(b) { return num(a.val * b.val) }
    // Annihilation: x * 0 = 0
    if _is-zero(a) or _is-zero(b) { return num(0) }
    // Identity: x * 1 = x
    if _is-one(a) { return b }
    if _is-one(b) { return a }
    // x * -1 = neg(x)
    if _is-num(a) and a.val == -1 { return neg(b) }
    if _is-num(b) and b.val == -1 { return neg(a) }
    // x * x = x^2 (but not when x is add — let distribution handle that)
    if expr-eq(a, b) and not is-type(a, "add") { return pow(a, num(2)) }
    // x^a * x^b = x^(a+b)
    if is-type(a, "pow") and is-type(b, "pow") and expr-eq(a.base, b.base) {
      return pow(a.base, _simplify-once(add(a.exp, b.exp)))
    }
    // x * x^n = x^(n+1)
    if is-type(b, "pow") and expr-eq(a, b.base) {
      return pow(a, _simplify-once(add(b.exp, num(1))))
    }
    if is-type(a, "pow") and expr-eq(a.base, b) {
      return pow(b, _simplify-once(add(a.exp, num(1))))
    }
    // Move numeric coefficients to the left: x * 3 => 3 * x
    if _is-num(b) and not _is-num(a) { return mul(b, a) }
    // Flatten nested coefficients: n * (m * expr) => (n*m) * expr
    if _is-num(a) and is-type(b, "mul") and _is-num(b.args.at(0)) {
      return mul(num(a.val * b.args.at(0).val), b.args.at(1))
    }
    // Distribution: a * (b + c) => a*b + a*c
    if is-type(b, "add") {
      return add(mul(a, b.args.at(0)), mul(a, b.args.at(1)))
    }
    if is-type(a, "add") {
      return add(mul(a.args.at(0), b), mul(a.args.at(1), b))
    }
    return mul(a, b)
  }

  // --- Power ---
  if is-type(expr, "pow") {
    let b = _simplify-once(expr.base)
    let e = _simplify-once(expr.exp)

    // x^0 = 1
    if _is-zero(e) { return num(1) }
    // x^1 = x
    if _is-one(e) { return b }
    // 0^n = 0 (n > 0)
    if _is-zero(b) and _is-num(e) and e.val > 0 { return num(0) }
    // 1^n = 1
    if _is-one(b) { return num(1) }
    // num^num = constant fold (integers only)
    if _is-num(b) and _is-num(e) and type(e.val) == int and e.val >= 0 {
      let result = 1
      for _ in range(e.val) { result = result * b.val }
      return num(result)
    }
    // (x^a)^b = x^(a*b)
    if is-type(b, "pow") {
      return pow(b.base, _simplify-once(mul(b.exp, e)))
    }
    // n^(1/2) where n is a perfect square => sqrt(n)
    if _is-num(b) and is-type(e, "div") {
      if is-type(e.num, "num") and e.num.val == 1 and is-type(e.den, "num") and e.den.val == 2 {
        if type(b.val) == int and b.val >= 0 {
          let s = calc.sqrt(b.val)
          let si = int(s)
          if si * si == b.val {
            return num(si)
          }
        }
      }
    }
    // (a + b)^n for small integer n => expand via repeated multiplication
    if is-type(b, "add") and _is-num(e) and type(e.val) == int and e.val >= 2 and e.val <= 4 {
      let result = b
      for _ in range(e.val - 1) {
        result = mul(result, b)
      }
      return result
    }
    return pow(b, e)
  }

  // --- Division ---
  if is-type(expr, "div") {
    let n = _simplify-once(expr.num)
    let d = _simplify-once(expr.den)

    // 0 / x = 0
    if _is-zero(n) { return num(0) }
    // x / 1 = x
    if _is-one(d) { return n }
    // x / x = 1
    if expr-eq(n, d) { return num(1) }
    // num / num = fold
    if _is-num(n) and _is-num(d) and d.val != 0 {
      // Keep as fraction if not evenly divisible
      if type(n.val) == int and type(d.val) == int {
        let r = calc.rem(n.val, d.val)
        if r == 0 { return num(int(n.val / d.val)) }
        // Reduce by GCD
        let gcd-val = calc.gcd(calc.abs(n.val), calc.abs(d.val))
        if gcd-val > 1 {
          return cdiv(num(int(n.val / gcd-val)), num(int(d.val / gcd-val)))
        }
      }
    }
    // neg(x) / neg(y) = x / y
    if is-type(n, "neg") and is-type(d, "neg") {
      return _simplify-once(cdiv(n.arg, d.arg))
    }
    // neg(x) / y = neg(x / y)
    if is-type(n, "neg") {
      return neg(_simplify-once(cdiv(n.arg, d)))
    }
    // x / neg(y) = neg(x / y)
    if is-type(d, "neg") {
      return neg(_simplify-once(cdiv(n, d.arg)))
    }
    // num(-a) / num(-b) => num(a) / num(b) (raw negative numbers)
    if _is-num(n) and _is-num(d) and n.val < 0 and d.val < 0 {
      return _simplify-once(cdiv(num(-n.val), num(-d.val)))
    }
    // num(a) / num(-b) => neg(a/b) (normalize sign to numerator)
    if _is-num(d) and d.val < 0 {
      return neg(_simplify-once(cdiv(n, num(-d.val))))
    }
    return cdiv(n, d)
  }

  // --- Function ---
  if is-type(expr, "func") {
    let a = _simplify-once(expr.arg)
    // exp(0) = 1
    if expr.name == "exp" and _is-zero(a) { return num(1) }
    // ln(1) = 0
    if expr.name == "ln" and _is-one(a) { return num(0) }
    // ln(e) = 1
    if expr.name == "ln" and is-type(a, "const") and a.name == "e" { return num(1) }
    // sin(0) = 0
    if expr.name == "sin" and _is-zero(a) { return num(0) }
    // cos(0) = 1
    if expr.name == "cos" and _is-zero(a) { return num(1) }
    // exp(ln(x)) = x
    if expr.name == "exp" and is-type(a, "func") and a.name == "ln" { return a.arg }
    // ln(exp(x)) = x
    if expr.name == "ln" and is-type(a, "func") and a.name == "exp" { return a.arg }
    // tan(0) = 0
    if expr.name == "tan" and _is-zero(a) { return num(0) }
    // sinh(0) = 0
    if expr.name == "sinh" and _is-zero(a) { return num(0) }
    // cosh(0) = 1
    if expr.name == "cosh" and _is-zero(a) { return num(1) }
    // tanh(0) = 0
    if expr.name == "tanh" and _is-zero(a) { return num(0) }

    // --- Log rules ---
    // ln(a * b) => ln(a) + ln(b)
    if expr.name == "ln" and is-type(a, "mul") {
      return add(func("ln", a.args.at(0)), func("ln", a.args.at(1)))
    }
    // ln(a / b) => ln(a) - ln(b)
    if expr.name == "ln" and is-type(a, "div") {
      return sub(func("ln", a.num), func("ln", a.den))
    }
    // ln(a^n) => n * ln(a)
    if expr.name == "ln" and is-type(a, "pow") {
      return mul(a.exp, func("ln", a.base))
    }

    // --- Abs rules ---
    // |n| => abs(n) for numeric
    if expr.name == "abs" and _is-num(a) {
      return num(calc.abs(a.val))
    }
    // |−x| => |x|
    if expr.name == "abs" and is-type(a, "neg") {
      return func("abs", a.arg)
    }

    return func(expr.name, a)
  }

  // --- Log with base ---
  if is-type(expr, "log") {
    let b = _simplify-once(expr.base)
    let a = _simplify-once(expr.arg)
    // log_b(b) = 1
    if expr-eq(b, a) { return num(1) }
    // log_b(1) = 0
    if _is-one(a) { return num(0) }
    return (type: "log", base: b, arg: a)
  }



  // --- Sum/Prod: simplify body ---
  if is-type(expr, "sum") {
    return (
      type: "sum",
      body: _simplify-once(expr.body),
      idx: expr.idx,
      from: _simplify-once(expr.from),
      to: _simplify-once(expr.to),
    )
  }
  if is-type(expr, "prod") {
    return (
      type: "prod",
      body: _simplify-once(expr.body),
      idx: expr.idx,
      from: _simplify-once(expr.from),
      to: _simplify-once(expr.to),
    )
  }

  // --- Matrix: simplify each entry ---
  if is-type(expr, "matrix") {
    let rows = expr.rows.map(row => row.map(e => _simplify-once(e)))
    return (type: "matrix", rows: rows)
  }

  return expr
}

// --- Public API ---

/// Simplify an expression by applying rules until a fixed point (max 10 passes).
#let simplify(expr) = {
  let current = expr
  let max-passes = 10
  for _ in range(max-passes) {
    let next = _simplify-once(current)
    if expr-eq(next, current) { return current }
    current = next
  }
  current
}

