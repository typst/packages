// =========================================================================
// CAS Display: Pretty-print expressions as Typst math content
// =========================================================================

#import "expr.typ": *
#import "truths/function-registry.typ": fn-spec, fn-arity-ok

// --- Operator precedence for parenthesization ---
/// Internal helper `_prec`.
#let _prec(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return 100 }
  if is-type(expr, "func") { return 90 }
  if is-type(expr, "pow") { return 70 }
  if is-type(expr, "neg") { return 60 }
  if is-type(expr, "mul") or is-type(expr, "div") { return 50 }
  if is-type(expr, "add") { return 40 }
  return 0
}

/// Wrap in parens if child has lower precedence than parent.
#let _paren(child-content, child-expr, parent-prec) = {
  if _prec(child-expr) < parent-prec {
    return $lr((#child-content))$
  }
  child-content
}

// --- Helper: is expression "negative" at top level? ---
/// Internal helper `_is-neg-term`.
#let _is-neg-term(expr) = {
  if is-type(expr, "neg") { return true }
  if is-type(expr, "num") and expr.val < 0 { return true }
  if is-type(expr, "mul") and is-type(expr.args.at(0), "num") and expr.args.at(0).val < 0 { return true }
  return false
}

// --- Helper: negate a "negative" term to get its absolute form ---
/// Internal helper `_abs-term`.
#let _abs-term(expr) = {
  if is-type(expr, "neg") { return expr.arg }
  if is-type(expr, "num") and expr.val < 0 { return num(calc.abs(expr.val)) }
  if is-type(expr, "mul") and is-type(expr.args.at(0), "num") and expr.args.at(0).val < 0 {
    let pos-coeff = num(calc.abs(expr.args.at(0).val))
    if pos-coeff.val == 1 { return expr.args.at(1) }
    return mul(pos-coeff, expr.args.at(1))
  }
  return expr
}

/// Internal helper `_join-args`.
/// Joins rendered argument content as `a, b, c`.
#let _join-args(args) = {
  if args.len() == 0 { return [] }
  if args.len() == 1 { return args.at(0) }
  let out = args.at(0)
  let i = 1
  while i < args.len() {
    out = $#out, #args.at(i)$
    i += 1
  }
  out
}

// Flatten nested multiplication into factors (for display rewrites only).
/// Internal helper `_flatten-mul-display`.
#let _flatten-mul-display(expr) = {
  if is-type(expr, "mul") {
    return _flatten-mul-display(expr.args.at(0)) + _flatten-mul-display(expr.args.at(1))
  }
  (expr,)
}

// Render variable names with optional single underscore subscript.
// Example: "x_1" -> x_1, "theta" -> theta (italic).
/// Internal helper `_display-var-name`.
#let _display-var-name(name) = {
  if "_" in name {
    let parts = name.split("_")
    if parts.len() == 2 and parts.at(0) != "" and parts.at(1) != "" {
      let base = parts.at(0)
      let sub = parts.at(1)
      return $#math.italic(base)_(#math.italic(sub))$
    }
  }
  $#math.italic(name)$
}

// --- Public API ---

/// Render a CAS expression as Typst math content.
#let cas-display(expr) = {
  if expr == none { return $nothing$ }

  // Number
  if is-type(expr, "num") {
    let v = expr.val
    if v < 0 { return $-#calc.abs(v)$ }
    return $#v$
  }

  // Variable
  if is-type(expr, "var") {
    return _display-var-name(expr.name)
  }

  // Constant
  if is-type(expr, "const") {
    if expr.name == "e" { return $e$ }
    if expr.name == "pi" { return $pi$ }
    if expr.name == "i" { return $i$ }
    return $upright(#expr.name)$
  }

  // Negation
  if is-type(expr, "neg") {
    let inner = cas-display(expr.arg)
    // Force parens for neg(neg(...)), neg(add(...)), neg(num(negative))
    if is-type(expr.arg, "neg") or is-type(expr.arg, "add") {
      return $-(#inner)$
    }
    let wrapped = _paren(inner, expr.arg, 60)
    return $-#wrapped$
  }

  // Addition
  if is-type(expr, "add") {
    let left = cas-display(expr.args.at(0))
    let right-expr = expr.args.at(1)

    // Check if right-side is an add whose first term is negative => flatten
    if is-type(right-expr, "add") and _is-neg-term(right-expr.args.at(0)) {
      let abs-first = _abs-term(right-expr.args.at(0))
      let abs-display = cas-display(abs-first)
      let rest = cas-display(right-expr.args.at(1))
      // Determine sign for the second part of the inner add
      let right-right = right-expr.args.at(1)
      if _is-neg-term(right-right) {
        let abs-rr = cas-display(_abs-term(right-right))
        return $#left - #abs-display - #abs-rr$
      }
      return $#left - #abs-display + #rest$
    }

    // If right side is negation, render as subtraction
    if is-type(right-expr, "neg") {
      let inner-right = cas-display(right-expr.arg)
      let wrapped = _paren(inner-right, right-expr.arg, 41)
      return $#left - #wrapped$
    }
    // If right side is a negative number, render as subtraction
    if is-type(right-expr, "num") and right-expr.val < 0 {
      return $#left - #calc.abs(right-expr.val)$
    }
    // If right side is mul with negative coefficient, render as subtraction
    if is-type(right-expr, "mul") and is-type(right-expr.args.at(0), "num") and right-expr.args.at(0).val < 0 {
      let abs-mul = _abs-term(right-expr)
      let pos-display = cas-display(abs-mul)
      return $#left - #pos-display$
    }
    return $#left + #cas-display(right-expr)$
  }

  // Multiplication
  if is-type(expr, "mul") {
    let l-expr = expr.args.at(0)
    let r-expr = expr.args.at(1)
    let left = cas-display(l-expr)
    let right = cas-display(r-expr)

    let left-w = _paren(left, l-expr, 50)
    // Keep right-side fractions unparenthesized in products:
    // show a/b ⋅ c/d instead of a/b ⋅ (c/d).
    let right-w = if is-type(r-expr, "div") { right } else { _paren(right, r-expr, 51) }

    // Coefficient * something
    if is-type(l-expr, "num") {
      // -1 * x => -x
      if l-expr.val == -1 { return $-#right-w$ }
      // 1 * x => x
      if l-expr.val == 1 { return right-w }
      // num * num => use dot operator (otherwise 4*5 renders as 45)
      if is-type(r-expr, "num") { return $#left-w dot.op #right-w$ }
      // n * expr => nx (tight juxtaposition)
      return $#left-w#right-w$
    }
    return $#left-w dot.op #right-w$
  }

  // Division / fraction
  if is-type(expr, "div") {
    // Display (a*b)/n as a · (b/n) when numerator already contains
    // a fraction factor, so inputs like 2/3 * 9/10 render as 2/3 · 9/10.
    if is-type(expr.den, "num") and is-type(expr.num, "mul") {
      let factors = _flatten-mul-display(expr.num)
      if factors.len() >= 2 {
        let has-frac = false
        for f in factors {
          if is-type(f, "div") { has-frac = true }
        }
        if has-frac {
          let rebuilt = factors.at(0)
          let i = 1
          while i < factors.len() - 1 {
            rebuilt = mul(rebuilt, factors.at(i))
            i += 1
          }
          rebuilt = mul(rebuilt, cdiv(factors.at(factors.len() - 1), expr.den))
          return cas-display(rebuilt)
        }
      }
    }
    let n = cas-display(expr.num)
    let d = cas-display(expr.den)
    return $frac(#n, #d)$
  }

  // Power
  if is-type(expr, "pow") {
    let base = cas-display(expr.base)
    let exp = cas-display(expr.exp)
    // Check for sqrt: x^(1/2)
    if is-type(expr.exp, "div") {
      if is-type(expr.exp.num, "num") and expr.exp.num.val == 1 {
        if is-type(expr.exp.den, "num") and expr.exp.den.val == 2 {
          return $sqrt(#base)$
        }
      }
    }
    let base-w = _paren(base, expr.base, 71)
    return $#base-w^(#exp)$
  }

  // Named function
  if is-type(expr, "func") {
    let fname = expr.name
    let args = func-args(expr).map(cas-display)

    if fname.starts-with("diff_") {
      let v = fname.slice(5)
      let arg = if args.len() > 0 { args.at(0) } else { $?$ }
      return $d/(d #math.italic(v)) (#arg)$
    }

    let spec = fn-spec(fname)
    if spec != none and spec.display != none and spec.display.render != none and fn-arity-ok(spec, args.len()) {
      return (spec.display.render)(args)
    }

    return $op(#fname) lr((#_join-args(args)))$
  }

  // Integral node (unsolved integral)
  if is-type(expr, "integral") {
    let body = cas-display(expr.expr)
    let v = expr.var
    // Wrap in parens if integrand is a sum (so ∫(a+b) dx, not ∫a+b dx)
    if is-type(expr.expr, "add") {
      body = $lr((#body))$
    }
    return $integral #body thin #math.italic("d" + v)$
  }

  // Definite integral node (unsolved)
  if is-type(expr, "def-integral") {
    let body = cas-display(expr.expr)
    let v = expr.var
    let lo = cas-display(expr.lo)
    let hi = cas-display(expr.hi)
    return $integral_(#lo)^(#hi) #body thin #math.italic("d" + v)$
  }

  // Logarithm with base
  if is-type(expr, "log") {
    let b = cas-display(expr.base)
    let a = cas-display(expr.arg)
    return $log_(#b) lr((#a))$
  }


  // Summation
  if is-type(expr, "sum") {
    let body = cas-display(expr.body)
    let idx = expr.idx
    let lo = cas-display(expr.from)
    let hi = cas-display(expr.to)
    return $sum_(#math.italic(idx) = #lo)^(#hi) #body$
  }

  // Product notation
  if is-type(expr, "prod") {
    let body = cas-display(expr.body)
    let idx = expr.idx
    let lo = cas-display(expr.from)
    let hi = cas-display(expr.to)
    return $product_(#math.italic(idx) = #lo)^(#hi) #body$
  }

  // Matrix
  if is-type(expr, "matrix") {
    let rows = expr.rows.map(row => row.map(entry => cas-display(entry)))
    // Build the matrix using Typst's mat
    let args = ()
    for row in rows {
      args += row
    }
    let ncols = expr.rows.at(0).len()
    return math.mat(..rows)
  }

  // Limit
  if is-type(expr, "limit") {
    let body = cas-display(expr.expr)
    let v = expr.var
    let a = cas-display(expr.to)
    return $lim_(#math.italic(v) arrow.r #a) #body$
  }

  // Piecewise
  if is-type(expr, "piecewise") {
    let entries = ()
    for (case-expr, cond) in expr.cases {
      let displayed = cas-display(case-expr)
      if cond == none {
        entries.push($#displayed & "otherwise"$)
      } else {
        entries.push($#displayed & "if" #cond$)
      }
    }
    return math.cases(..entries)
  }

  // Fallback
  return $?$
}

/// Render an equation: `expr = result` in display math.
#let cas-equation(lhs, rhs) = {
  let l = cas-display(lhs)
  let r = cas-display(rhs)
  $#l = #r$
}
