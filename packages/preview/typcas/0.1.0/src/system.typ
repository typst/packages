// =========================================================================
// CAS Systems of Equations
// =========================================================================
// Linear symbolic systems + nonlinear numeric Newton solver.
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify
#import "eval-num.typ": eval-expr
#import "calculus.typ": diff

/// Internal helper `_contains-var`.
#let _contains-var(expr, v) = {
  if is-type(expr, "var") { return expr.name == v }
  if is-type(expr, "num") or is-type(expr, "const") { return false }
  if is-type(expr, "neg") { return _contains-var(expr.arg, v) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return _contains-var(expr.args.at(0), v) or _contains-var(expr.args.at(1), v)
  }
  if is-type(expr, "pow") { return _contains-var(expr.base, v) or _contains-var(expr.exp, v) }
  if is-type(expr, "div") { return _contains-var(expr.num, v) or _contains-var(expr.den, v) }
  if is-type(expr, "func") {
    for a in func-args(expr) {
      if _contains-var(a, v) { return true }
    }
    return false
  }
  if is-type(expr, "log") { return _contains-var(expr.base, v) or _contains-var(expr.arg, v) }
  false
}

/// Internal helper `_contains-any-var`.
#let _contains-any-var(expr, vars) = {
  for v in vars {
    if _contains-var(expr, v) { return true }
  }
  false
}

/// Internal helper `_var-index`.
#let _var-index(vars, name) = {
  for (i, v) in vars.enumerate() {
    if v == name { return i }
  }
  none
}

/// Internal helper `_zeros`.
#let _zeros(n) = (num(0),) * n

/// Internal helper `_lin-add`.
#let _lin-add(a, b) = {
  let n = a.coeffs.len()
  let c = _zeros(n)
  for i in range(n) {
    c.at(i) = simplify(add(a.coeffs.at(i), b.coeffs.at(i)))
  }
  (
    coeffs: c,
    const: simplify(add(a.const, b.const)),
  )
}

/// Internal helper `_lin-scale`.
#let _lin-scale(k, lin) = {
  let n = lin.coeffs.len()
  let c = _zeros(n)
  for i in range(n) {
    c.at(i) = simplify(mul(k, lin.coeffs.at(i)))
  }
  (
    coeffs: c,
    const: simplify(mul(k, lin.const)),
  )
}

/// Internal helper `_is-const-wrt-vars`.
#let _is-const-wrt-vars(expr, vars) = not _contains-any-var(expr, vars)

// Collect linear coefficients:
// expr = c0*x0 + ... + cn*xn + const
/// Internal helper `_linear-collect`.
#let _linear-collect(expr, vars) = {
  let n = vars.len()
  let e = simplify(expr)

  if is-type(e, "num") or is-type(e, "const") {
    return (coeffs: _zeros(n), const: e)
  }

  if is-type(e, "var") {
    let i = _var-index(vars, e.name)
    if i == none { return none }
    let c = _zeros(n)
    c.at(i) = num(1)
    return (coeffs: c, const: num(0))
  }

  if is-type(e, "neg") {
    let inner = _linear-collect(e.arg, vars)
    if inner == none { return none }
    return _lin-scale(num(-1), inner)
  }

  if is-type(e, "add") {
    let l = _linear-collect(e.args.at(0), vars)
    let r = _linear-collect(e.args.at(1), vars)
    if l == none or r == none { return none }
    return _lin-add(l, r)
  }

  if is-type(e, "mul") {
    let a = e.args.at(0)
    let b = e.args.at(1)
    let a-const = _is-const-wrt-vars(a, vars)
    let b-const = _is-const-wrt-vars(b, vars)

    if a-const and not b-const {
      let lb = _linear-collect(b, vars)
      if lb == none { return none }
      return _lin-scale(a, lb)
    }
    if b-const and not a-const {
      let la = _linear-collect(a, vars)
      if la == none { return none }
      return _lin-scale(b, la)
    }
    if a-const and b-const {
      return (coeffs: _zeros(n), const: simplify(mul(a, b)))
    }
    return none
  }

  if is-type(e, "div") {
    if not _is-const-wrt-vars(e.den, vars) { return none }
    let ln = _linear-collect(e.num, vars)
    if ln == none { return none }
    return _lin-scale(cdiv(num(1), e.den), ln)
  }

  none
}

/// Internal helper `_mat-det`.
#let _mat-det(m) = {
  let n = m.rows.len()
  if n == 1 { return m.rows.at(0).at(0) }
  if n == 2 {
    return simplify(sub(
      mul(m.rows.at(0).at(0), m.rows.at(1).at(1)),
      mul(m.rows.at(0).at(1), m.rows.at(1).at(0)),
    ))
  }
  let res = num(0)
  for j in range(n) {
    let minor = ()
    for i in range(1, n) {
      let row = ()
      for k in range(n) {
        if k != j { row.push(m.rows.at(i).at(k)) }
      }
      minor.push(row)
    }
    let cof = mul(m.rows.at(0).at(j), _mat-det(cmat(minor)))
    if calc.rem(j, 2) == 0 {
      res = add(res, cof)
    } else {
      res = sub(res, cof)
    }
  }
  simplify(res)
}

// Solve linear system A x = b with symbolic coefficients.
// equations is an array of (lhs, rhs) tuples.
/// Public helper `solve-linear-system`.
#let solve-linear-system(equations, vars) = {
  let n = vars.len()
  if equations.len() != n { return none }

  let rows = ()
  let bvec = ()

  for eq in equations {
    let lhs = eq.at(0)
    let rhs = eq.at(1)
    let combined = simplify(sub(lhs, rhs))
    let lin = _linear-collect(combined, vars)
    if lin == none { return none }
    rows.push(lin.coeffs)
    bvec.push(simplify(neg(lin.const)))
  }

  // Cramer's rule via existing matrix representation.
  let a = cmat(rows)
  let det-a = _mat-det(a)
  if expr-eq(simplify(det-a), num(0)) { return none }

  let sol = ()
  for j in range(n) {
    let mod-rows = ()
    for i in range(n) {
      let row = ()
      for k in range(n) {
        row.push(if k == j { bvec.at(i) } else { rows.at(i).at(k) })
      }
      mod-rows.push(row)
    }
    sol.push(simplify(cdiv(_mat-det(cmat(mod-rows)), det-a)))
  }

  let out = (:)
  for (i, name) in vars.enumerate() {
    out.insert(name, sol.at(i))
  }
  out
}

/// Internal helper `_solve-linear-float`.
#let _solve-linear-float(a, b) = {
  let n = a.len()
  let m = a.map(row => row)
  let rhs = b

  let i = 0
  while i < n {
    // Pivot
    let pivot = i
    let best = calc.abs(m.at(i).at(i))
    let r = i + 1
    while r < n {
      let cand = calc.abs(m.at(r).at(i))
      if cand > best {
        best = cand
        pivot = r
      }
      r += 1
    }
    if best < 1e-14 { return none }

    if pivot != i {
      let tmp-row = m.at(i)
      m.at(i) = m.at(pivot)
      m.at(pivot) = tmp-row
      let tmp-rhs = rhs.at(i)
      rhs.at(i) = rhs.at(pivot)
      rhs.at(pivot) = tmp-rhs
    }

    // Eliminate
    let piv = m.at(i).at(i)
    let rr = i + 1
    while rr < n {
      let factor = m.at(rr).at(i) / piv
      let cc = i
      while cc < n {
        m.at(rr).at(cc) = m.at(rr).at(cc) - factor * m.at(i).at(cc)
        cc += 1
      }
      rhs.at(rr) = rhs.at(rr) - factor * rhs.at(i)
      rr += 1
    }
    i += 1
  }

  // Back substitution
  let x = (0.0,) * n
  let ii = n - 1
  while ii >= 0 {
    let s = rhs.at(ii)
    let jj = ii + 1
    while jj < n {
      s = s - m.at(ii).at(jj) * x.at(jj)
      jj += 1
    }
    let piv = m.at(ii).at(ii)
    if calc.abs(piv) < 1e-14 { return none }
    x.at(ii) = s / piv
    ii -= 1
  }

  x
}

// Numeric Newton solver for nonlinear systems F(x)=0.
// equations is array of expressions assumed equal to zero.
// initial is dictionary of variable -> numeric guess.
/// Public helper `solve-nonlinear-system`.
#let solve-nonlinear-system(equations, vars, initial, max-iters: 40, tol: 1e-10) = {
  let n = vars.len()
  if equations.len() != n { return none }

  // Precompute Jacobian symbolically.
  let jac = ()
  for fi in equations {
    let row = ()
    for v in vars {
      row.push(simplify(diff(fi, v)))
    }
    jac.push(row)
  }

  let x = ()
  for v in vars {
    let guess = initial.at(v, default: none)
    if guess == none { return none }
    x.push(guess)
  }

  let converged = false
  let iters = 0

  while iters < max-iters {
    let bindings = (:)
    for (i, v) in vars.enumerate() {
      bindings.insert(v, x.at(i))
    }

    let fvals = ()
    for fi in equations {
      let val = eval-expr(fi, bindings)
      if val == none { return none }
      fvals.push(val)
    }

    let a = ()
    for i in range(n) {
      let row = ()
      for j in range(n) {
        let v = eval-expr(jac.at(i).at(j), bindings)
        if v == none { return none }
        row.push(v)
      }
      a.push(row)
    }

    let rhs = fvals.map(v => -v)
    let dx = _solve-linear-float(a, rhs)
    if dx == none { return none }

    let step = 0.0
    for i in range(n) {
      x.at(i) = x.at(i) + dx.at(i)
      step = calc.max(step, calc.abs(dx.at(i)))
    }

    if step < tol {
      converged = true
      break
    }

    iters += 1
  }

  let sol = (:)
  for (i, v) in vars.enumerate() {
    sol.insert(v, num(x.at(i)))
  }

  (
    converged: converged,
    iterations: iters + 1,
    solution: sol,
  )
}
