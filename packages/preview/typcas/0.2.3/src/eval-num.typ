// =========================================================================
// CAS Numeric Evaluation
// =========================================================================
// Evaluate expressions to floating-point numbers given variable bindings.
// =========================================================================

#import "expr.typ": *
#import "truths/function-registry.typ": fn-spec, fn-arity-ok

#let _rel-holds(a, rel, b) = {
  if rel == ">" { return a > b }
  if rel == ">=" { return a >= b }
  if rel == "<" { return a < b }
  if rel == "<=" { return a <= b }
  if rel == "!=" { return a != b }
  if rel == "=" or rel == "==" { return a == b }
  none
}

/// Evaluate an expression to a numeric value.
///
/// `bindings` is a dictionary mapping variable names to numbers.
///   e.g. eval-expr(add(cvar("x"), 1), (x: 5))  =>  6
///
/// Returns `none` if the expression cannot be fully evaluated.
#let eval-expr(expr, bindings) = {
  // Auto-wrap raw numbers
  let expr = if type(expr) == int or type(expr) == float { num(expr) } else { expr }

  // Number
  if is-type(expr, "num") { return expr.val }

  // Variable: look up binding
  if is-type(expr, "var") {
    let v = bindings.at(expr.name, default: none)
    return v
  }

  // Constant
  if is-type(expr, "const") {
    // Philosophy exception: foundational numeric constants are structural.
    if expr.name == "i" { return none }
    // allow constants to be shadowed by bindings (except reserved imaginary i)
    if expr.name in bindings { return bindings.at(expr.name) }

    if expr.name == "e" { return calc.e }
    if expr.name == "pi" { return calc.pi }
    return none
  }

  // Negation
  if is-type(expr, "neg") {
    let a = eval-expr(expr.arg, bindings)
    if a == none { return none }
    return -a
  }

  // Addition
  if is-type(expr, "add") {
    let a = eval-expr(expr.args.at(0), bindings)
    let b = eval-expr(expr.args.at(1), bindings)
    if a == none or b == none { return none }
    return a + b
  }

  // Multiplication
  if is-type(expr, "mul") {
    let a = eval-expr(expr.args.at(0), bindings)
    let b = eval-expr(expr.args.at(1), bindings)
    if a == none or b == none { return none }
    return a * b
  }

  // Power
  if is-type(expr, "pow") {
    let b = eval-expr(expr.base, bindings)
    let e = eval-expr(expr.exp, bindings)
    if b == none or e == none { return none }
    // Avoid non-real result panic
    if b < 0 and type(e) == float and calc.fract(e) != 0.0 { return none }
    return calc.pow(b, e)
  }

  // Division
  if is-type(expr, "div") {
    let n = eval-expr(expr.num, bindings)
    let d = eval-expr(expr.den, bindings)
    if n == none or d == none or d == 0 { return none }
    return n / d
  }

  // Named function (registry-dispatched)
  if is-type(expr, "func") {
    let spec = fn-spec(expr.name)
    if spec == none or spec.eval == none { return none }
    let args = ()
    for aexpr in func-args(expr) {
      let v = eval-expr(aexpr, bindings)
      if v == none { return none }
      args.push(v)
    }
    if not fn-arity-ok(spec, args.len()) { return none }
    return (spec.eval)(args)
  }

  // Log with base
  if is-type(expr, "log") {
    let b = eval-expr(expr.base, bindings)
    let a = eval-expr(expr.arg, bindings)
    if b == none or a == none or b <= 0 or a <= 0 or b == 1 { return none }
    return calc.ln(a) / calc.ln(b)
  }

  if is-type(expr, "cond-rel") {
    let lhs = eval-expr(expr.lhs, bindings)
    let rhs = eval-expr(expr.rhs, bindings)
    if lhs == none or rhs == none { return none }
    return _rel-holds(lhs, expr.rel, rhs)
  }

  if is-type(expr, "cond-and") {
    let all = true
    for c in expr.args {
      let v = eval-expr(c, bindings)
      if v == none { return none }
      if v == false { return false }
      if v != true { return none }
      all = all and v
    }
    return all
  }

  if is-type(expr, "piecewise") {
    let unknown-hit = false
    for (body, cond) in expr.cases {
      if cond == none {
        return eval-expr(body, bindings)
      }
      if not is-expr(cond) { continue }
      let c = eval-expr(cond, bindings)
      if c == true {
        return eval-expr(body, bindings)
      }
      if c == none {
        unknown-hit = true
      }
    }
    if unknown-hit { return none }
    return none
  }


  // Sum: evaluate by iteration
  if is-type(expr, "sum") {
    let lo = eval-expr(expr.from, bindings)
    let hi = eval-expr(expr.to, bindings)
    if lo == none or hi == none { return none }
    let lo = int(lo)
    let hi = int(hi)
    let result = 0
    for k in range(lo, hi + 1) {
      let new-bindings = bindings
      new-bindings.insert(expr.idx, k)
      let val = eval-expr(expr.body, new-bindings)
      if val == none { return none }
      result = result + val
    }
    return result
  }

  // Product: evaluate by iteration
  if is-type(expr, "prod") {
    let lo = eval-expr(expr.from, bindings)
    let hi = eval-expr(expr.to, bindings)
    if lo == none or hi == none { return none }
    let lo = int(lo)
    let hi = int(hi)
    let result = 1
    for k in range(lo, hi + 1) {
      let new-bindings = bindings
      new-bindings.insert(expr.idx, k)
      let val = eval-expr(expr.body, new-bindings)
      if val == none { return none }
      result = result * val
    }
    return result
  }

  return none
}

/// Substitute a variable in an expression with another expression.
/// Returns the new expression with all occurrences of `var-name` replaced by `replacement`.
#let substitute(expr, var-name, replacement) = {
  // Auto-wrap raw number replacements
  let replacement = if type(replacement) == int or type(replacement) == float { num(replacement) } else { replacement }

  if is-type(expr, "num") { return expr }
  if is-type(expr, "const") {
    if expr.name == var-name { return replacement }
    return expr
  }
  if is-type(expr, "var") {
    if expr.name == var-name { return replacement }
    return expr
  }
  if is-type(expr, "neg") {
    return neg(substitute(expr.arg, var-name, replacement))
  }
  if is-type(expr, "add") {
    return add(
      substitute(expr.args.at(0), var-name, replacement),
      substitute(expr.args.at(1), var-name, replacement),
    )
  }
  if is-type(expr, "mul") {
    return mul(
      substitute(expr.args.at(0), var-name, replacement),
      substitute(expr.args.at(1), var-name, replacement),
    )
  }
  if is-type(expr, "pow") {
    return pow(
      substitute(expr.base, var-name, replacement),
      substitute(expr.exp, var-name, replacement),
    )
  }
  if is-type(expr, "div") {
    return cdiv(
      substitute(expr.num, var-name, replacement),
      substitute(expr.den, var-name, replacement),
    )
  }
  if is-type(expr, "func") {
    let args = func-args(expr).map(a => substitute(a, var-name, replacement))
    return func(expr.name, ..args)
  }
  if is-type(expr, "log") {
    return (
      type: "log",
      base: substitute(expr.base, var-name, replacement),
      arg: substitute(expr.arg, var-name, replacement),
    )
  }

  if is-type(expr, "sum") {
    // Don't substitute the index variable inside the body
    if expr.idx == var-name { return expr }
    return (
      type: "sum",
      body: substitute(expr.body, var-name, replacement),
      idx: expr.idx,
      from: substitute(expr.from, var-name, replacement),
      to: substitute(expr.to, var-name, replacement),
    )
  }
  if is-type(expr, "prod") {
    if expr.idx == var-name { return expr }
    return (
      type: "prod",
      body: substitute(expr.body, var-name, replacement),
      idx: expr.idx,
      from: substitute(expr.from, var-name, replacement),
      to: substitute(expr.to, var-name, replacement),
    )
  }
  if is-type(expr, "piecewise") {
    return piecewise(expr.cases.map(c => {
      let cond = c.at(1)
      (
        substitute(c.at(0), var-name, replacement),
        if is-expr(cond) { substitute(cond, var-name, replacement) } else { cond },
      )
    }))
  }
  if is-type(expr, "cond-rel") {
    return cond-rel(
      substitute(expr.lhs, var-name, replacement),
      expr.rel,
      substitute(expr.rhs, var-name, replacement),
    )
  }
  if is-type(expr, "cond-and") {
    return cond-and(..expr.args.map(c => substitute(c, var-name, replacement)))
  }
  if is-type(expr, "complex") {
    return (
      type: "complex",
      re: substitute(expr.re, var-name, replacement),
      im: substitute(expr.im, var-name, replacement),
    )
  }
  return expr
}
