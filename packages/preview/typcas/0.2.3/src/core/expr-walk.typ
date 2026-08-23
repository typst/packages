// =========================================================================
// typcas v2 Expression Walkers
// =========================================================================

#import "../expr.typ": *

#let _iter-children(expr, f) = {
  if is-type(expr, "neg") {
    return f(expr.arg)
  }
  if is-type(expr, "add") or is-type(expr, "mul") {
    if f(expr.args.at(0)) { return true }
    return f(expr.args.at(1))
  }
  if is-type(expr, "pow") {
    if f(expr.base) { return true }
    return f(expr.exp)
  }
  if is-type(expr, "div") {
    if f(expr.num) { return true }
    return f(expr.den)
  }
  if is-type(expr, "func") {
    for a in func-args(expr) {
      if f(a) { return true }
    }
    return false
  }
  if is-type(expr, "log") {
    if f(expr.base) { return true }
    return f(expr.arg)
  }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    if f(expr.body) { return true }
    if f(expr.from) { return true }
    return f(expr.to)
  }
  if is-type(expr, "matrix") {
    for row in expr.rows {
      for item in row {
        if f(item) { return true }
      }
    }
    return false
  }
  if is-type(expr, "piecewise") {
    for (body, cond) in expr.cases {
      if f(body) { return true }
      if is-expr(cond) and f(cond) { return true }
    }
    return false
  }
  if is-type(expr, "cond-rel") {
    if f(expr.lhs) { return true }
    return f(expr.rhs)
  }
  if is-type(expr, "cond-and") {
    for c in expr.args {
      if f(c) { return true }
    }
    return false
  }
  if is-type(expr, "complex") {
    if f(expr.re) { return true }
    return f(expr.im)
  }
  false
}

/// True if variable `v` exists anywhere in expression.
#let contains-var(expr, v) = {
  if is-type(expr, "var") { return expr.name == v }
  if is-type(expr, "num") or is-type(expr, "const") { return false }
  _iter-children(expr, x => contains-var(x, v))
}

/// True if constant named `name` exists in expression.
#let contains-const(expr, name) = {
  if is-type(expr, "const") { return expr.name == name }
  if is-type(expr, "num") or is-type(expr, "var") { return false }
  _iter-children(expr, x => contains-const(x, name))
}

/// Cheap structural complexity metric for rewrite heuristics.
#let expr-complexity(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return 1 }
  if is-type(expr, "neg") { return 1 + expr-complexity(expr.arg) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return 2 + expr-complexity(expr.args.at(0)) + expr-complexity(expr.args.at(1))
  }
  if is-type(expr, "pow") or is-type(expr, "div") {
    let a = if is-type(expr, "pow") { expr.base } else { expr.num }
    let b = if is-type(expr, "pow") { expr.exp } else { expr.den }
    return 3 + expr-complexity(a) + expr-complexity(b)
  }
  if is-type(expr, "func") {
    let c = 3
    for a in func-args(expr) {
      c += expr-complexity(a)
    }
    return c
  }
  if is-type(expr, "log") {
    return 4 + expr-complexity(expr.base) + expr-complexity(expr.arg)
  }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return 5 + expr-complexity(expr.body) + expr-complexity(expr.from) + expr-complexity(expr.to)
  }
  if is-type(expr, "matrix") {
    let c = 6
    for row in expr.rows {
      for item in row {
        c += expr-complexity(item)
      }
    }
    return c
  }
  if is-type(expr, "piecewise") {
    let c = 7
    for (body, cond) in expr.cases {
      c += expr-complexity(body)
      if is-expr(cond) { c += expr-complexity(cond) }
    }
    return c
  }
  if is-type(expr, "cond-rel") {
    return 3 + expr-complexity(expr.lhs) + expr-complexity(expr.rhs)
  }
  if is-type(expr, "cond-and") {
    let c = 4
    for cond in expr.args {
      c += expr-complexity(cond)
    }
    return c
  }
  if is-type(expr, "complex") {
    return 4 + expr-complexity(expr.re) + expr-complexity(expr.im)
  }
  10
}
