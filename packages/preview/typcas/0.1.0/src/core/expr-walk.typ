// =========================================================================
// CAS Expression Walk Helpers
// =========================================================================
// Shared recursive walkers used across calculus/solve/steps.
// =========================================================================

#import "../expr.typ": *

/// Public helper `contains-var`.
#let contains-var(expr, v) = {
  if is-type(expr, "var") { return expr.name == v }
  if is-type(expr, "num") or is-type(expr, "const") { return false }

  if is-type(expr, "neg") { return contains-var(expr.arg, v) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return contains-var(expr.args.at(0), v) or contains-var(expr.args.at(1), v)
  }
  if is-type(expr, "div") { return contains-var(expr.num, v) or contains-var(expr.den, v) }
  if is-type(expr, "pow") { return contains-var(expr.base, v) or contains-var(expr.exp, v) }
  if is-type(expr, "func") {
    for a in func-args(expr) {
      if contains-var(a, v) { return true }
    }
    return false
  }
  if is-type(expr, "log") { return contains-var(expr.base, v) or contains-var(expr.arg, v) }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return contains-var(expr.body, v) or contains-var(expr.from, v) or contains-var(expr.to, v)
  }
  if is-type(expr, "matrix") {
    for row in expr.rows {
      for item in row {
        if contains-var(item, v) { return true }
      }
    }
    return false
  }
  if is-type(expr, "piecewise") {
    for (body, cond) in expr.cases {
      if contains-var(body, v) { return true }
      if is-expr(cond) and contains-var(cond, v) { return true }
    }
    return false
  }
  false
}

/// Public helper `contains-const`.
#let contains-const(expr, name) = {
  if is-type(expr, "const") { return expr.name == name }
  if is-type(expr, "num") or is-type(expr, "var") { return false }

  if is-type(expr, "neg") { return contains-const(expr.arg, name) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return contains-const(expr.args.at(0), name) or contains-const(expr.args.at(1), name)
  }
  if is-type(expr, "div") { return contains-const(expr.num, name) or contains-const(expr.den, name) }
  if is-type(expr, "pow") { return contains-const(expr.base, name) or contains-const(expr.exp, name) }
  if is-type(expr, "func") {
    for a in func-args(expr) {
      if contains-const(a, name) { return true }
    }
    return false
  }
  if is-type(expr, "log") { return contains-const(expr.base, name) or contains-const(expr.arg, name) }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return contains-const(expr.body, name) or contains-const(expr.from, name) or contains-const(expr.to, name)
  }
  if is-type(expr, "matrix") {
    for row in expr.rows {
      for item in row {
        if contains-const(item, name) { return true }
      }
    }
    return false
  }
  if is-type(expr, "piecewise") {
    for (body, cond) in expr.cases {
      if contains-const(body, name) { return true }
      if is-expr(cond) and contains-const(cond, name) { return true }
    }
    return false
  }
  false
}

/// Public helper `expr-complexity`.
#let expr-complexity(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return 1 }
  if is-type(expr, "neg") { return 1 + expr-complexity(expr.arg) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return 2 + expr-complexity(expr.args.at(0)) + expr-complexity(expr.args.at(1))
  }
  if is-type(expr, "div") {
    return 3 + expr-complexity(expr.num) + expr-complexity(expr.den)
  }
  if is-type(expr, "pow") {
    return 3 + expr-complexity(expr.base) + expr-complexity(expr.exp)
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
    let c = 5
    for row in expr.rows {
      for item in row {
        c += expr-complexity(item)
      }
    }
    return c
  }
  if is-type(expr, "piecewise") {
    let c = 5
    for (body, cond) in expr.cases {
      c += expr-complexity(body)
      if is-expr(cond) {
        c += expr-complexity(cond)
      }
    }
    return c
  }
  10
}
