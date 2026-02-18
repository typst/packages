// =========================================================================
// CAS Numeric Evaluation
// =========================================================================
// Evaluate expressions to floating-point numbers given variable bindings.
// =========================================================================

#import "expr.typ": *

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
    // allow constants to be shadowed by bindings (e.g. sum variable "i")
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
    return calc.pow(b, e)
  }

  // Division
  if is-type(expr, "div") {
    let n = eval-expr(expr.num, bindings)
    let d = eval-expr(expr.den, bindings)
    if n == none or d == none or d == 0 { return none }
    return n / d
  }

  // Named function
  if is-type(expr, "func") {
    let a = eval-expr(expr.arg, bindings)
    if a == none { return none }

    // Basic trig
    if expr.name == "sin" { return calc.sin(a) }
    if expr.name == "cos" { return calc.cos(a) }
    if expr.name == "tan" { return calc.tan(a) }
    if expr.name == "csc" { return 1.0 / calc.sin(a) }
    if expr.name == "sec" { return 1.0 / calc.cos(a) }
    if expr.name == "cot" { return calc.cos(a) / calc.sin(a) }

    // Inverse trig
    if expr.name == "arcsin" { return calc.asin(a) }
    if expr.name == "arccos" { return calc.acos(a) }
    if expr.name == "arctan" { return calc.atan(a) }
    if expr.name == "arccsc" { return calc.asin(1.0 / a) }
    if expr.name == "arcsec" { return calc.acos(1.0 / a) }
    if expr.name == "arccot" { return calc.atan(1.0 / a) }

    // Hyperbolic
    if expr.name == "sinh" { return (calc.exp(a) - calc.exp(-a)) / 2.0 }
    if expr.name == "cosh" { return (calc.exp(a) + calc.exp(-a)) / 2.0 }
    if expr.name == "tanh" {
      let ep = calc.exp(a)
      let em = calc.exp(-a)
      return (ep - em) / (ep + em)
    }
    if expr.name == "csch" { return 2.0 / (calc.exp(a) - calc.exp(-a)) }
    if expr.name == "sech" { return 2.0 / (calc.exp(a) + calc.exp(-a)) }
    if expr.name == "coth" {
      let ep = calc.exp(a)
      let em = calc.exp(-a)
      return (ep + em) / (ep - em)
    }

    // Inverse hyperbolic
    if expr.name == "arcsinh" { return calc.ln(a + calc.sqrt(a * a + 1.0)) }
    if expr.name == "arccosh" { return calc.ln(a + calc.sqrt(a * a - 1.0)) }
    if expr.name == "arctanh" { return 0.5 * calc.ln((1.0 + a) / (1.0 - a)) }
    if expr.name == "arccsch" { return calc.ln(1.0 / a + calc.sqrt(1.0 / (a * a) + 1.0)) }
    if expr.name == "arcsech" { return calc.ln(1.0 / a + calc.sqrt(1.0 / (a * a) - 1.0)) }
    if expr.name == "arccoth" { return 0.5 * calc.ln((a + 1.0) / (a - 1.0)) }

    // Other
    if expr.name == "ln" { return calc.ln(a) }
    if expr.name == "exp" { return calc.exp(a) }
    if expr.name == "abs" { return calc.abs(a) }

    return none
  }

  // Log with base
  if is-type(expr, "log") {
    let b = eval-expr(expr.base, bindings)
    let a = eval-expr(expr.arg, bindings)
    if b == none or a == none or b <= 0 or a <= 0 { return none }
    return calc.ln(a) / calc.ln(b)
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
    return func(expr.name, substitute(expr.arg, var-name, replacement))
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
  return expr
}
