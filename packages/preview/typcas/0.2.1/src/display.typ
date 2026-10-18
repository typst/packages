// =========================================================================
// typcas v2 Display Engine
// =========================================================================

#import "expr.typ": *
#import "truths/function-registry.typ": fn-spec, fn-arity-ok

#let _prec(e) = {
  if is-type(e, "num") or is-type(e, "var") or is-type(e, "const") { return 100 }
  if is-type(e, "func") or is-type(e, "log") { return 90 }
  if is-type(e, "pow") { return 80 }
  if is-type(e, "neg") { return 70 }
  if is-type(e, "mul") or is-type(e, "div") { return 60 }
  if is-type(e, "add") { return 50 }
  0
}

#let _is-neg(e) = {
  if is-type(e, "neg") { return true }
  if is-type(e, "num") and e.val < 0 { return true }
  if is-type(e, "mul") and is-type(e.args.at(0), "num") and e.args.at(0).val < 0 { return true }
  false
}

#let _abs-expr(e) = {
  if is-type(e, "neg") { return e.arg }
  if is-type(e, "num") and e.val < 0 { return num(calc.abs(e.val)) }
  if is-type(e, "mul") and is-type(e.args.at(0), "num") and e.args.at(0).val < 0 {
    let c = calc.abs(e.args.at(0).val)
    let right = e.args.at(1)
    if c == 1 { return right }
    return mul(num(c), right)
  }
  e
}

#let _flatten-mul(e) = {
  if is-type(e, "mul") {
    return _flatten-mul(e.args.at(0)) + _flatten-mul(e.args.at(1))
  }
  (e,)
}

#let display-symbol(name) = {
  if "_" in name {
    let parts = name.split("_")
    if parts.len() == 2 and parts.at(0) != "" and parts.at(1) != "" {
      return math.attach(
        math.italic(parts.at(0)),
        b: math.italic(parts.at(1)),
      )
    }
  }
  math.italic(name)
}

#let _display-var(name) = $#display-symbol(name)$

#let _join(args) = {
  if args.len() == 0 { return [] }
  let out = args.at(0)
  for i in range(1, args.len()) {
    out = $#out, #args.at(i)$
  }
  out
}

#let _rel-symbol(rel) = {
  if rel == "!=" { return sym.eq.not }
  if rel == ">=" { return sym.gt.eq }
  if rel == "<=" { return sym.lt.eq }
  if rel == ">" { return ">" }
  if rel == "<" { return "<" }
  if rel == "=" or rel == "==" { return "=" }
  rel
}

#let cas-display(expr) = {
  let wrap = (child, parent-level) => {
    let rendered = cas-display(child)
    if _prec(child) < parent-level { return $lr((#rendered))$ }
    rendered
  }

  if expr == none { return $nothing$ }

  if is-type(expr, "num") {
    if expr.val < 0 { return $-#calc.abs(expr.val)$ }
    return $#expr.val$
  }

  if is-type(expr, "var") { return _display-var(expr.name) }

  if is-type(expr, "const") {
    // Philosophy exception: foundational constants and integration constant C
    // are structural symbols with dedicated rendering.
    if expr.name == "e" { return $e$ }
    if expr.name == "pi" { return $pi$ }
    if expr.name == "i" { return $i$ }
    if expr.name == "C" { return _display-var("C") }
    return $upright(#expr.name)$
  }

  if is-type(expr, "neg") {
    return $-#wrap(expr.arg, 70)$
  }

  if is-type(expr, "add") {
    let a = expr.args.at(0)
    let b = expr.args.at(1)
    if _is-neg(b) {
      return $#cas-display(a) - #wrap(_abs-expr(b), 51)$
    }
    return $#cas-display(a) + #cas-display(b)$
  }

  if is-type(expr, "mul") {
    let a = expr.args.at(0)
    let b = expr.args.at(1)

    if is-type(a, "num") {
      if a.val == 1 { return cas-display(b) }
      if a.val == -1 { return $-#wrap(b, 61)$ }
      if is-type(b, "num") { return $#cas-display(a) dot.op #cas-display(b)$ }
      return $#cas-display(a)#wrap(b, 61)$
    }

    return $#wrap(a, 60) dot.op #wrap(b, 61)$
  }

  if is-type(expr, "div") {
    if is-type(expr.den, "num") and is-type(expr.num, "mul") {
      let factors = _flatten-mul(expr.num)
      let has-div = false
      for f in factors {
        if is-type(f, "div") { has-div = true }
      }
      if has-div and factors.len() >= 2 {
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
    return $frac(#cas-display(expr.num), #cas-display(expr.den))$
  }

  if is-type(expr, "pow") {
    if is-type(expr.exp, "div") and is-type(expr.exp.num, "num") and is-type(expr.exp.den, "num") {
      if expr.exp.num.val == 1 and expr.exp.den.val == 2 {
        return $sqrt(#cas-display(expr.base))$
      }
    }
    return $#wrap(expr.base, 81)^(#cas-display(expr.exp))$
  }

  if is-type(expr, "func") {
    let fname = expr.name
    let args = func-args(expr).map(a => cas-display(a))

    if fname.starts-with("diff_") {
      let v = fname.slice(5)
      let a = if args.len() > 0 { args.at(0) } else { $?$ }
      return $dif/(dif #display-symbol(v)) (#a)$
    }

    let spec = fn-spec(fname)
    if spec != none and spec.display != none and spec.display.render != none and fn-arity-ok(spec, args.len()) {
      return (spec.display.render)(args)
    }

    return $op(#fname) lr((#_join(args)))$
  }

  if is-type(expr, "log") {
    return $log_(#cas-display(expr.base)) lr((#cas-display(expr.arg)))$
  }

  if is-type(expr, "integral") {
    let body = if is-type(expr.expr, "add") { $lr((#cas-display(expr.expr)))$ } else { cas-display(expr.expr) }
    return $integral #body thin dif #display-symbol(expr.var)$
  }

  if is-type(expr, "def-integral") {
    return $integral_(#cas-display(expr.lo))^(#cas-display(expr.hi)) #cas-display(expr.expr) thin dif #display-symbol(expr.var)$
  }

  if is-type(expr, "sum") {
    return $sum_(#display-symbol(expr.idx) = #cas-display(expr.from))^(#cas-display(expr.to)) #cas-display(expr.body)$
  }

  if is-type(expr, "prod") {
    return $product_(#display-symbol(expr.idx) = #cas-display(expr.from))^(#cas-display(expr.to)) #cas-display(expr.body)$
  }

  if is-type(expr, "matrix") {
    return math.mat(..expr.rows.map(r => r.map(cas-display)))
  }

  if is-type(expr, "limit") {
    let side = expr.at("side", default: "two-sided")
    let to = cas-display(expr.to)
    let to-side = if side == "left" {
      $#to^(-)$
    } else if side == "right" {
      $#to^(+)$
    } else {
      to
    }
    return $lim_(#display-symbol(expr.var) arrow.r #to-side) #cas-display(expr.expr)$
  }

  if is-type(expr, "piecewise") {
    let entries = ()
    for (body, cond) in expr.cases {
      if cond == none {
        entries.push($#cas-display(body) & "otherwise"$)
      } else {
        let shown = if is-expr(cond) { cas-display(cond) } else { cond }
        entries.push($#cas-display(body) & "if" #shown$)
      }
    }
    return math.cases(..entries)
  }

  if is-type(expr, "cond-rel") {
    return $#cas-display(expr.lhs) #_rel-symbol(expr.rel) #cas-display(expr.rhs)$
  }

  if is-type(expr, "cond-and") {
    if expr.args.len() == 0 { return $\"true\"$ }
    let out = cas-display(expr.args.at(0))
    for i in range(1, expr.args.len()) {
      out = $#out and #cas-display(expr.args.at(i))$
    }
    return out
  }

  if is-type(expr, "complex") {
    if is-type(expr.im, "num") and expr.im.val == 0 { return cas-display(expr.re) }
    if is-type(expr.re, "num") and expr.re.val == 0 { return $#cas-display(expr.im) dot.op i$ }
    return $#cas-display(expr.re) + #cas-display(expr.im) dot.op i$
  }

  $?$
}

#let cas-equation(lhs, rhs) = $#cas-display(lhs) = #cas-display(rhs)$
