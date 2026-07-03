// =========================================================================
// typcas v2 Expression Model
// =========================================================================
// Core symbolic node constructors and helpers.
// =========================================================================

/// Check exact node type.
#let is-type(expr, t) = type(expr) == dictionary and expr.at("type", default: none) == t

/// True when value looks like an expression node.
#let is-expr(expr) = type(expr) == dictionary and expr.at("type", default: none) != none

// --- Atoms ---

#let num(n) = (type: "num", val: n)
#let cvar(name) = (type: "var", name: name)
#let const-expr(name) = (type: "const", name: name)
#let const-e = const-expr("e")
#let const-pi = const-expr("pi")

/// Coerce plain numbers to numeric nodes.
#let _coerce(x) = if type(x) == int or type(x) == float { num(x) } else { x }

// --- Primitive operators ---

#let add(a, b) = (type: "add", args: (_coerce(a), _coerce(b)))
#let mul(a, b) = (type: "mul", args: (_coerce(a), _coerce(b)))
#let pow(base, exp) = (type: "pow", base: _coerce(base), exp: _coerce(exp))
#let cdiv(numer, denom) = (type: "div", num: _coerce(numer), den: _coerce(denom))
#let neg(arg) = (type: "neg", arg: _coerce(arg))

// --- Function application ---

#let func(name, ..args) = {
  let xs = args.pos().map(_coerce)
  if xs.len() == 1 {
    return (type: "func", name: name, args: xs, arg: xs.at(0))
  }
  (type: "func", name: name, args: xs)
}

#let func-args(expr) = {
  if not is-type(expr, "func") { return () }
  let xs = expr.at("args", default: none)
  if xs != none { return xs }
  let x = expr.at("arg", default: none)
  if x == none { () } else { (x,) }
}

#let func-arity(expr) = func-args(expr).len()

// --- Common named constructors ---

#let sin-of(arg) = func("sin", arg)
#let cos-of(arg) = func("cos", arg)
#let tan-of(arg) = func("tan", arg)
#let csc-of(arg) = func("csc", arg)
#let sec-of(arg) = func("sec", arg)
#let cot-of(arg) = func("cot", arg)

#let arcsin-of(arg) = func("arcsin", arg)
#let arccos-of(arg) = func("arccos", arg)
#let arctan-of(arg) = func("arctan", arg)
#let arccsc-of(arg) = func("arccsc", arg)
#let arcsec-of(arg) = func("arcsec", arg)
#let arccot-of(arg) = func("arccot", arg)

#let sinh-of(arg) = func("sinh", arg)
#let cosh-of(arg) = func("cosh", arg)
#let tanh-of(arg) = func("tanh", arg)
#let csch-of(arg) = func("csch", arg)
#let sech-of(arg) = func("sech", arg)
#let coth-of(arg) = func("coth", arg)

#let arcsinh-of(arg) = func("arcsinh", arg)
#let arccosh-of(arg) = func("arccosh", arg)
#let arctanh-of(arg) = func("arctanh", arg)
#let arccsch-of(arg) = func("arccsch", arg)
#let arcsech-of(arg) = func("arcsech", arg)
#let arccoth-of(arg) = func("arccoth", arg)

#let ln-of(arg) = func("ln", arg)
#let exp-of(arg) = func("exp", arg)
#let sqrt-of(arg) = pow(_coerce(arg), cdiv(num(1), num(2)))
#let abs-of(arg) = func("abs", _coerce(arg))

// --- Composite constructors ---

#let sub(a, b) = add(_coerce(a), neg(_coerce(b)))

#let sum-of(..args) = {
  let xs = args.pos().map(_coerce)
  if xs.len() == 0 { return num(0) }
  let out = xs.at(0)
  for i in range(1, xs.len()) {
    out = add(out, xs.at(i))
  }
  out
}

#let prod-of(..args) = {
  let xs = args.pos().map(_coerce)
  if xs.len() == 0 { return num(1) }
  let out = xs.at(0)
  for i in range(1, xs.len()) {
    out = mul(out, xs.at(i))
  }
  out
}

#let log-of(base, arg) = (type: "log", base: _coerce(base), arg: _coerce(arg))

#let csum(body, idx, from, to) = (
  type: "sum",
  body: _coerce(body),
  idx: idx,
  from: _coerce(from),
  to: _coerce(to),
)

#let cprod(body, idx, from, to) = (
  type: "prod",
  body: _coerce(body),
  idx: idx,
  from: _coerce(from),
  to: _coerce(to),
)

#let cmat(rows) = (type: "matrix", rows: rows.map(r => r.map(_coerce)))

#let mat-id(n) = {
  let rows = ()
  for i in range(n) {
    let row = ()
    for j in range(n) {
      row.push(if i == j { num(1) } else { num(0) })
    }
    rows.push(row)
  }
  cmat(rows)
}

#let piecewise(cases) = (type: "piecewise", cases: cases)

// --- Condition constructors (for piecewise branches) ---

#let cond-rel(lhs, rel, rhs) = (
  type: "cond-rel",
  lhs: _coerce(lhs),
  rel: rel,
  rhs: _coerce(rhs),
)

#let cond-and(..conds) = {
  let xs = ()
  for c in conds.pos() {
    if c == none { continue }
    if is-type(c, "cond-and") {
      for inner in c.args { xs.push(inner) }
    } else {
      xs.push(c)
    }
  }
  if xs.len() == 0 { return none }
  if xs.len() == 1 { return xs.at(0) }
  (type: "cond-and", args: xs)
}

// --- Canonical integration constant helpers ---

/// True when expression is integration constant `C`.
/// Transitional compatibility: accepts both const("C") and var("C").
#let is-int-constant(expr) = {
  if is-type(expr, "const") and expr.name == "C" { return true }
  if is-type(expr, "var") and expr.name == "C" { return true }
  false
}

/// Internal helper `_is-bound-var`.
#let _is-bound-var(bound-vars, name) = {
  for v in bound-vars {
    if v == name { return true }
  }
  false
}

/// Internal helper `_normalize-int-constant`.
#let _normalize-int-constant(expr, bound-vars) = {
  if not is-expr(expr) { return expr }

  if is-type(expr, "num") or is-type(expr, "const") { return expr }
  if is-type(expr, "var") {
    if expr.name == "C" and not _is-bound-var(bound-vars, "C") {
      return const-expr("C")
    }
    return expr
  }
  if is-type(expr, "neg") {
    return neg(_normalize-int-constant(expr.arg, bound-vars))
  }
  if is-type(expr, "add") {
    return add(
      _normalize-int-constant(expr.args.at(0), bound-vars),
      _normalize-int-constant(expr.args.at(1), bound-vars),
    )
  }
  if is-type(expr, "mul") {
    return mul(
      _normalize-int-constant(expr.args.at(0), bound-vars),
      _normalize-int-constant(expr.args.at(1), bound-vars),
    )
  }
  if is-type(expr, "pow") {
    return pow(
      _normalize-int-constant(expr.base, bound-vars),
      _normalize-int-constant(expr.exp, bound-vars),
    )
  }
  if is-type(expr, "div") {
    return cdiv(
      _normalize-int-constant(expr.num, bound-vars),
      _normalize-int-constant(expr.den, bound-vars),
    )
  }
  if is-type(expr, "func") {
    let args = func-args(expr).map(a => _normalize-int-constant(a, bound-vars))
    return func(expr.name, ..args)
  }
  if is-type(expr, "log") {
    return log-of(
      _normalize-int-constant(expr.base, bound-vars),
      _normalize-int-constant(expr.arg, bound-vars),
    )
  }
  if is-type(expr, "sum") {
    if expr.idx == "C" {
      panic("cas-parse: index variable 'C' is reserved; use C_0 or another symbol")
    }
    let body-bound = bound-vars + (expr.idx,)
    return csum(
      _normalize-int-constant(expr.body, body-bound),
      expr.idx,
      _normalize-int-constant(expr.from, bound-vars),
      _normalize-int-constant(expr.to, bound-vars),
    )
  }
  if is-type(expr, "prod") {
    if expr.idx == "C" {
      panic("cas-parse: index variable 'C' is reserved; use C_0 or another symbol")
    }
    let body-bound = bound-vars + (expr.idx,)
    return cprod(
      _normalize-int-constant(expr.body, body-bound),
      expr.idx,
      _normalize-int-constant(expr.from, bound-vars),
      _normalize-int-constant(expr.to, bound-vars),
    )
  }
  if is-type(expr, "integral") {
    let body-bound = bound-vars + (expr.var,)
    return (
      type: "integral",
      expr: _normalize-int-constant(expr.expr, body-bound),
      var: expr.var,
    )
  }
  if is-type(expr, "def-integral") {
    let body-bound = bound-vars + (expr.var,)
    return (
      type: "def-integral",
      expr: _normalize-int-constant(expr.expr, body-bound),
      var: expr.var,
      lo: _normalize-int-constant(expr.lo, bound-vars),
      hi: _normalize-int-constant(expr.hi, bound-vars),
    )
  }
  if is-type(expr, "limit") {
    return (
      type: "limit",
      expr: _normalize-int-constant(expr.expr, bound-vars),
      var: expr.var,
      to: _normalize-int-constant(expr.to, bound-vars),
    )
  }
  if is-type(expr, "matrix") {
    return cmat(expr.rows.map(row => row.map(x => _normalize-int-constant(x, bound-vars))))
  }
  if is-type(expr, "piecewise") {
    return piecewise(expr.cases.map(c => {
      let cond = c.at(1)
      (
        _normalize-int-constant(c.at(0), bound-vars),
        if is-expr(cond) { _normalize-int-constant(cond, bound-vars) } else { cond },
      )
    }))
  }
  if is-type(expr, "cond-rel") {
    return cond-rel(
      _normalize-int-constant(expr.lhs, bound-vars),
      expr.rel,
      _normalize-int-constant(expr.rhs, bound-vars),
    )
  }
  if is-type(expr, "cond-and") {
    return cond-and(..expr.args.map(c => _normalize-int-constant(c, bound-vars)))
  }
  if is-type(expr, "complex") {
    return (
      type: "complex",
      re: _normalize-int-constant(expr.re, bound-vars),
      im: _normalize-int-constant(expr.im, bound-vars),
    )
  }

  expr
}

/// Canonicalize free `var("C")` as `const("C")`.
#let normalize-int-constant(expr, bound-vars: ()) = _normalize-int-constant(expr, bound-vars)

// --- Structural equality ---

#let _expr-eq(a, b) = {
  if is-expr(a) != is-expr(b) { return false }
  if not is-expr(a) { return a == b }
  let t = a.at("type", default: none)
  if t != b.at("type", default: none) { return false }

  if t == "num" { return a.val == b.val }
  if t == "var" or t == "const" { return a.name == b.name }
  if t == "neg" { return _expr-eq(a.arg, b.arg) }
  if t == "add" or t == "mul" {
    return _expr-eq(a.args.at(0), b.args.at(0)) and _expr-eq(a.args.at(1), b.args.at(1))
  }
  if t == "pow" { return _expr-eq(a.base, b.base) and _expr-eq(a.exp, b.exp) }
  if t == "div" { return _expr-eq(a.num, b.num) and _expr-eq(a.den, b.den) }
  if t == "func" {
    if a.name != b.name { return false }
    let aa = func-args(a)
    let ba = func-args(b)
    if aa.len() != ba.len() { return false }
    for i in range(aa.len()) {
      if not _expr-eq(aa.at(i), ba.at(i)) { return false }
    }
    return true
  }
  if t == "log" { return _expr-eq(a.base, b.base) and _expr-eq(a.arg, b.arg) }
  if t == "sum" or t == "prod" {
    return a.idx == b.idx and _expr-eq(a.body, b.body) and _expr-eq(a.from, b.from) and _expr-eq(a.to, b.to)
  }
  if t == "matrix" {
    if a.rows.len() != b.rows.len() { return false }
    for i in range(a.rows.len()) {
      let ar = a.rows.at(i)
      let br = b.rows.at(i)
      if ar.len() != br.len() { return false }
      for j in range(ar.len()) {
        if not _expr-eq(ar.at(j), br.at(j)) { return false }
      }
    }
    return true
  }
  if t == "piecewise" {
    if a.cases.len() != b.cases.len() { return false }
    for i in range(a.cases.len()) {
      let ac = a.cases.at(i)
      let bc = b.cases.at(i)
      if not _expr-eq(ac.at(0), bc.at(0)) { return false }
      if not _expr-eq(ac.at(1), bc.at(1)) { return false }
    }
    return true
  }
  if t == "complex" {
    return _expr-eq(a.re, b.re) and _expr-eq(a.im, b.im)
  }
  false
}

#let expr-eq(a, b) = _expr-eq(a, b)
