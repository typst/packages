// =========================================================================
// typcas v2 Step Tracing (Core-4)
// =========================================================================
// Deterministic equation-chain traces for:
// - simplify
// - diff
// - integrate
// - solve
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify, simplify-meta-core, expand as expand-expr
#import "../assumptions.typ": apply-assumptions
#import "../calculus/diff.typ": diff
#import "../calculus/integrate.typ": integrate, integral-c-last
#import "../calculus/integrate-methods.typ": analyze-integral
#import "../solve/engine.typ": solve-meta
#import "../poly.typ": poly-coeffs
#import "../truths/function-registry.typ": fn-spec
#import "../core/expr-walk.typ": contains-var as _contains-var-core, expr-complexity as _expr-complexity-core
#import "../restrictions.typ": build-restriction-panel, render-restriction-note
#import "detail.typ": normalize-detail, resolve-detail-depth
#import "model.typ": _s-header, _s-equation, _s-define, _s-note, _s-group, _s-branch, _s-apply

#let _contains-var(expr, v) = _contains-var-core(expr, v)
#let _expr-complexity(expr) = _expr-complexity-core(expr)
#let _is-pedagogical(detail) = detail >= 3

#let _next-depth(depth) = if depth == none { none } else { depth - 1 }
#let _can-recurse(depth) = depth == none or depth > 1

#let _v-diff(arg, var) = func("diff_" + var, arg)
#let _v-int(arg, var) = (type: "integral", expr: arg, var: var)

#let _is-helpful-simplify(before, after) = {
  if expr-eq(before, after) { return false }
  if _expr-complexity(after) < _expr-complexity(before) { return true }
  repr(after) != repr(before)
}

#let _describe-simplification(before, after) = {
  if expr-eq(before, after) { return "No-op simplify" }
  if _expr-complexity(after) < _expr-complexity(before) { return "Complexity reduced" }
  "Canonical rewrite"
}

#let _identity-label-list(events) = {
  if events.len() == 0 { return "" }
  let out = events.at(0).at("label", default: "identity")
  let i = 1
  while i < events.len() {
    out += "; " + events.at(i).at("label", default: "identity")
    i += 1
  }
  out
}

#let _simplify-identity-rule(meta, fallback) = {
  let ids = meta.at("identities-used", default: ())
  if ids.len() == 0 { return fallback }
  let idtext = if ids.len() == 1 {
    "Identity: " + ids.at(0).at("label", default: "identity")
  } else {
    "Identities: " + _identity-label-list(ids)
  }
  if fallback == none or fallback == "" { return idtext }
  fallback + " | " + idtext
}

#let _identity-summary-notes(events) = {
  if events.len() == 0 { return () }
  let out = ()
  out.push(_s-note("Identities used (ordered):", tone: "meta"))
  for (i, ev) in events.enumerate() {
    out.push(_s-note(str(i + 1) + ". " + ev.at("label", default: "identity"), tone: "meta"))
  }
  out
}

#let _is-one(expr) = is-type(expr, "num") and expr.val == 1
#let _as-text(v) = if type(v) == bool { if v { "true" } else { "false" } } else { str(v) }

#let _branch-pair(label-left, steps-left, label-right, steps-right) = {
  let out = ()
  if steps-left != none and steps-left.len() > 0 {
    out.push(_s-branch(label-left, steps-left))
  }
  if steps-right != none and steps-right.len() > 0 {
    out.push(_s-branch(label-right, steps-right))
  }
  out
}

#let _alloc-name(used) = {
  let i = 1
  while true {
    let n = "u_" + str(i)
    if not (n in used) {
      used.insert(n, true)
      return n
    }
    i += 1
  }
}

#let _restriction-row-note(row) = {
  let status = row.at("status", default: "active")
  let tone = if status == "conflict" { "error" } else if status == "active" { "warn" } else { "meta" }
  let stage = row.at("stage", default: "defined")
  let source = row.at("source", default: "")
  _s-note(
    [
      #render-restriction-note((lhs: row.lhs, rel: row.rel, rhs: row.rhs, note: row.note))
      #h(0.35em)
      #text(size: 0.82em, fill: luma(120))[[(#status, #stage, #source)]]
    ],
    tone: tone,
  )
}

#let _restriction-notes(expr, stage, assumptions) = {
  let panel = build-restriction-panel(expr, stage: stage, assumptions: assumptions)
  let out = ()
  let counts = panel.counts
  out.push(_s-note(
    "Active assumptions panel: active="
      + str(counts.active)
      + ", satisfied="
      + str(counts.satisfied)
      + ", conflicts="
      + str(counts.conflicts)
      + ".",
    tone: "meta",
  ))
  for row in panel.rows {
    out.push(_restriction-row-note(row))
  }
  out
}

#let _collect-nonsmooth-boundary(expr, var) = {
  if not is-expr(expr) { return () }

  let out = ()
  if is-type(expr, "func") and expr.name == ("diff_" + var) {
    let args = func-args(expr)
    if args.len() == 1 and is-type(args.at(0), "func") {
      let n = args.at(0).name
      if n == "abs" or n == "sign" or n == "min" or n == "max" or n == "clamp" {
        out.push((fn: n, expr: args.at(0)))
      }
    }
  }

  if is-type(expr, "neg") {
    return out + _collect-nonsmooth-boundary(expr.arg, var)
  }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return out + _collect-nonsmooth-boundary(expr.args.at(0), var) + _collect-nonsmooth-boundary(expr.args.at(1), var)
  }
  if is-type(expr, "pow") {
    return out + _collect-nonsmooth-boundary(expr.base, var) + _collect-nonsmooth-boundary(expr.exp, var)
  }
  if is-type(expr, "div") {
    return out + _collect-nonsmooth-boundary(expr.num, var) + _collect-nonsmooth-boundary(expr.den, var)
  }
  if is-type(expr, "func") {
    let all = out
    for a in func-args(expr) { all += _collect-nonsmooth-boundary(a, var) }
    return all
  }
  if is-type(expr, "log") {
    return out + _collect-nonsmooth-boundary(expr.base, var) + _collect-nonsmooth-boundary(expr.arg, var)
  }
  if is-type(expr, "piecewise") {
    let all = out
    for c in expr.cases {
      all += _collect-nonsmooth-boundary(c.at(0), var)
      let cond = c.at(1)
      if is-expr(cond) { all += _collect-nonsmooth-boundary(cond, var) }
    }
    return all
  }
  if is-type(expr, "cond-rel") {
    return out + _collect-nonsmooth-boundary(expr.lhs, var) + _collect-nonsmooth-boundary(expr.rhs, var)
  }
  if is-type(expr, "cond-and") {
    let all = out
    for c in expr.args { all += _collect-nonsmooth-boundary(c, var) }
    return all
  }

  out
}

#let _diff-rule-form(src, var) = {
  if is-type(src, "add") {
    let a = src.args.at(0)
    let b = src.args.at(1)
    return (
      expr: add(_v-diff(a, var), _v-diff(b, var)),
      rule: "Apply sum rule",
    )
  }

  if is-type(src, "mul") {
    let a = src.args.at(0)
    let b = src.args.at(1)
    return (
      expr: add(mul(_v-diff(a, var), b), mul(a, _v-diff(b, var))),
      rule: "Apply product rule",
    )
  }

  if is-type(src, "div") {
    let n = src.num
    let d = src.den
    return (
      expr: cdiv(sub(mul(_v-diff(n, var), d), mul(n, _v-diff(d, var))), pow(d, num(2))),
      rule: "Apply quotient rule",
    )
  }

  if is-type(src, "pow") {
    let b = src.base
    let e = src.exp

    if is-type(e, "num") {
      return (
        expr: mul(mul(e, pow(b, sub(e, num(1)))), _v-diff(b, var)),
        rule: "Apply power rule",
      )
    }

    if is-type(b, "num") {
      return (
        expr: mul(mul(pow(b, e), ln-of(b)), _v-diff(e, var)),
        rule: "Apply exponential rule",
      )
    }

    return (
      expr: mul(pow(b, e), add(mul(_v-diff(e, var), ln-of(b)), mul(e, cdiv(_v-diff(b, var), b)))),
      rule: "Apply generalized power rule",
    )
  }

  if is-type(src, "func") and func-args(src).len() == 1 {
    let spec = fn-spec(src.name)
    if spec != none and spec.calculus != none and spec.calculus.diff != none {
      let u = src.arg
      let du = _v-diff(u, var)
      let outer = (spec.calculus.diff)(u)
      let split = if expr-eq(du, num(1)) { outer } else { mul(outer, du) }
      let rule = if spec.calculus.diff-step != none { spec.calculus.diff-step } else { "Apply chain rule" }
      return (expr: split, rule: rule)
    }
  }

  none
}

#let _trace-diff-core(expr, var, depth, used-vars, detail: 1, memo: none) = {
  let cache = if memo == none { (:)} else { memo }
  let src = simplify(expr)
  let key = "diff|" + repr(src) + "|" + var + "|" + repr(depth) + "|" + str(detail)
  if key in cache { return cache.at(key) }
  let out = simplify(diff(src, var))
  let lhs = _v-diff(src, var)

  if not _can-recurse(depth) {
    let shallow = _diff-rule-form(src, var)
    if shallow == none {
      let built = (_s-equation(lhs, out, rule: "Differentiate", kind: "transform"),)
      cache.insert(key, built)
      return built
    }
    if expr-eq(shallow.expr, out) {
      let built = (_s-equation(lhs, out, rule: shallow.rule, kind: "transform"),)
      cache.insert(key, built)
      return built
    }
    let built = (
      _s-equation(lhs, shallow.expr, rule: shallow.rule, kind: "transform"),
      _s-equation(shallow.expr, out, rule: "Simplify derivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if is-type(src, "add") {
    let a = src.args.at(0)
    let b = src.args.at(1)
    let split = add(_v-diff(a, var), _v-diff(b, var))
    let left-steps = _trace-diff-core(a, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let right-steps = _trace-diff-core(b, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let branches = _branch-pair("Branch 1", left-steps, "Branch 2", right-steps)
    let built = (
      _s-equation(lhs, split, rule: "Apply sum rule", kind: "transform"),
    ) + branches + (
      _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if is-type(src, "mul") {
    let a = src.args.at(0)
    let b = src.args.at(1)
    let split = add(mul(_v-diff(a, var), b), mul(a, _v-diff(b, var)))
    let left-steps = _trace-diff-core(a, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let right-steps = _trace-diff-core(b, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let branches = _branch-pair("Branch 1", left-steps, "Branch 2", right-steps)
    let built = (
      _s-equation(lhs, split, rule: "Apply product rule", kind: "transform"),
    ) + branches + (
      _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if is-type(src, "div") {
    let n = src.num
    let d = src.den
    let split = cdiv(sub(mul(_v-diff(n, var), d), mul(n, _v-diff(d, var))), pow(d, num(2)))
    let left-steps = _trace-diff-core(n, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let right-steps = _trace-diff-core(d, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let branches = _branch-pair("Numerator branch", left-steps, "Denominator branch", right-steps)
    let built = (
      _s-equation(lhs, split, rule: "Apply quotient rule", kind: "transform"),
    ) + branches + (
      _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if is-type(src, "pow") {
    let b = src.base
    let e = src.exp

    if is-type(e, "num") {
      let split = mul(mul(e, pow(b, sub(e, num(1)))), _v-diff(b, var))
      let children = if _contains-var(b, var) {
        _trace-diff-core(b, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
      } else {
        ()
      }
      let built = (
        _s-equation(lhs, split, rule: "Apply power rule", kind: "transform"),
        _s-group(children),
        _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
      )
      cache.insert(key, built)
      return built
    }

    if is-type(b, "num") {
      let split = mul(mul(pow(b, e), ln-of(b)), _v-diff(e, var))
      let children = if _contains-var(e, var) {
        _trace-diff-core(e, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
      } else {
        ()
      }
      let built = (
        _s-equation(lhs, split, rule: "Apply exponential rule", kind: "transform"),
        _s-group(children),
        _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
      )
      cache.insert(key, built)
      return built
    }

    let split = mul(pow(b, e), add(mul(_v-diff(e, var), ln-of(b)), mul(e, cdiv(_v-diff(b, var), b))))
    let e-var = _contains-var(e, var)
    let b-var = _contains-var(b, var)
    let e-steps = if e-var { _trace-diff-core(e, var, _next-depth(depth), used-vars, detail: detail, memo: cache) } else { () }
    let b-steps = if b-var { _trace-diff-core(b, var, _next-depth(depth), used-vars, detail: detail, memo: cache) } else { () }

    if e-var and b-var {
      let branches = _branch-pair("Exponent branch", e-steps, "Base branch", b-steps)
      let built = (
        _s-equation(lhs, split, rule: "Apply generalized power rule", kind: "transform"),
      ) + branches + (
        _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
      )
      cache.insert(key, built)
      return built
    }

    let children = if e-var { e-steps } else { b-steps }
    let built = (
      _s-equation(lhs, split, rule: "Apply generalized power rule", kind: "transform"),
      _s-group(children),
      _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if is-type(src, "func") and func-args(src).len() == 1 {
    let spec = fn-spec(src.name)
    if spec != none and spec.calculus != none and spec.calculus.diff != none {
      let u = src.arg
      let du = _v-diff(u, var)
      let outer = (spec.calculus.diff)(u)
      let split = if expr-eq(du, num(1)) { outer } else { mul(outer, du) }
      let local = ()

      if _contains-var(u, var) and not (is-type(u, "var") and u.name == var) {
        let uname = _alloc-name(used-vars)
        local.push(_s-define(uname, u, prefix: "set"))
        local.push(_s-note("Inner derivative for " + uname + ":", expr: simplify(diff(u, var)), tone: "meta"))
      }

      let children = if _contains-var(u, var) and not (is-type(u, "var") and u.name == var) {
        _trace-diff-core(u, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
      } else {
        ()
      }

      let rule = if spec.calculus.diff-step != none { spec.calculus.diff-step } else { "Apply chain rule" }
      let built = (
        _s-equation(lhs, split, rule: rule, kind: "transform"),
        _s-group(local + children),
        _s-equation(split, out, rule: "Simplify derivative", kind: "sub"),
      )
      cache.insert(key, built)
      return built
    }
  }

  let built = (_s-equation(lhs, out, rule: "Differentiate", kind: "transform"),)
  cache.insert(key, built)
  built
}

#let _trace-integrate-core(expr, var, depth, used-vars, detail: 1, memo: none) = {
  let cache = if memo == none { (:)} else { memo }
  let method = analyze-integral(expr, var)
  let src = method.expr
  let key = "integ|" + repr(src) + "|" + var + "|" + repr(depth) + "|" + str(detail)
  if key in cache { return cache.at(key) }
  let out = integral-c-last(simplify(integrate(src, var)))
  let lhs = _v-int(src, var)
  let recurse = _can-recurse(depth)

  if method.kind == "add" {
    let a = method.data.left
    let b = method.data.right
    let split = add(_v-int(a, var), _v-int(b, var))
    if not recurse {
      let built = (_s-equation(lhs, split, rule: "Apply linearity", kind: "transform"),)
      cache.insert(key, built)
      return built
    }
    let left-steps = _trace-integrate-core(a, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let right-steps = _trace-integrate-core(b, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let branches = _branch-pair("Branch 1", left-steps, "Branch 2", right-steps)
    let built = (
      _s-equation(lhs, split, rule: "Apply linearity", kind: "transform"),
    ) + branches + (
      _s-equation(split, out, rule: "Simplify antiderivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if method.kind == "neg" {
    let inner = method.data.inner
    let split = neg(_v-int(inner, var))
    if not recurse {
      let built = (_s-equation(lhs, split, rule: "Pull out -1", kind: "transform"),)
      cache.insert(key, built)
      return built
    }
    let children = _trace-integrate-core(inner, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let built = (
      _s-equation(lhs, split, rule: "Pull out -1", kind: "transform"),
      _s-group(children),
      _s-equation(split, out, rule: "Simplify antiderivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if method.kind == "const-factor" {
    let split = mul(method.data.const, _v-int(method.data.inner, var))
    if not recurse {
      let built = (_s-equation(lhs, split, rule: "Pull out constant", kind: "transform"),)
      cache.insert(key, built)
      return built
    }
    let children = _trace-integrate-core(method.data.inner, var, _next-depth(depth), used-vars, detail: detail, memo: cache)
    let built = (
      _s-equation(lhs, split, rule: "Pull out constant", kind: "transform"),
      _s-group(children),
      _s-equation(split, out, rule: "Simplify antiderivative", kind: "sub"),
    )
    cache.insert(key, built)
    return built
  }

  if method.kind == "u-sub" {
    let coeff = simplify(method.data.coeff)
    let uname = _alloc-name(used-vars)
    let uvar = cvar(uname)
    let duvar = cvar("d" + uname)

    let transformed-integrand = if _is-one(coeff) {
      func(method.data.outer-name, uvar)
    } else {
      mul(coeff, func(method.data.outer-name, uvar))
    }
    let transformed = (type: "integral", expr: transformed-integrand, var: uname)
    let primitive-u-core = if _is-one(coeff) {
      (method.data.antideriv)(uvar)
    } else {
      mul(coeff, (method.data.antideriv)(uvar))
    }
    let primitive-u = integral-c-last(simplify(add(primitive-u-core, const-expr("C"))))

    if not recurse {
      let built = (_s-equation(lhs, transformed, rule: "Apply u-substitution", kind: "transform"),)
      cache.insert(key, built)
      return built
    }

    let built = (
      _s-define(uname, method.data.u, prefix: "set"),
      _s-define(duvar, method.data.du, label: "derive"),
      _s-equation(lhs, transformed, rule: "Apply u-substitution", kind: "transform"),
      _s-equation(transformed, primitive-u, rule: "Integrate in " + uname, kind: "sub"),
      _s-equation(primitive-u, out, rule: "Back-substitute", kind: "meta"),
    )
    cache.insert(key, built)
    return built
  }

  if method.kind == "by-parts" {
    if recurse {
      let built = (
        _s-note("Integration by parts pattern detected.", tone: "meta"),
        _s-equation(lhs, out, rule: "Apply integration by parts", kind: "transform"),
      )
      cache.insert(key, built)
      return built
    }
    let built = (_s-equation(lhs, out, rule: "Apply integration by parts", kind: "transform"),)
    cache.insert(key, built)
    return built
  }

  if method.kind == "partial-fraction" {
    if recurse {
      let built = (
        _s-note("Partial fraction pattern detected.", tone: "meta"),
        _s-equation(lhs, out, rule: "Integrate via partial fractions", kind: "transform"),
      )
      cache.insert(key, built)
      return built
    }
    let built = (_s-equation(lhs, out, rule: "Integrate via partial fractions", kind: "transform"),)
    cache.insert(key, built)
    return built
  }

  if method.kind == "const" {
    let built = (_s-equation(lhs, out, rule: "Integrate constant", kind: "transform"),)
    cache.insert(key, built)
    return built
  }
  if method.kind == "var" or method.kind == "power" {
    let built = (_s-equation(lhs, out, rule: "Apply power rule", kind: "transform"),)
    cache.insert(key, built)
    return built
  }
  if method.kind == "reciprocal" {
    let built = (_s-equation(lhs, out, rule: "Apply ln rule", kind: "transform"),)
    cache.insert(key, built)
    return built
  }
  if method.kind == "func-primitive" {
    let built = (_s-equation(lhs, out, rule: "Apply primitive rule", kind: "transform"),)
    cache.insert(key, built)
    return built
  }
  if method.kind == "square-family" {
    let built = (_s-equation(lhs, out, rule: "Apply square-family primitive", kind: "transform"),)
    cache.insert(key, built)
    return built
  }

  let built = (_s-equation(lhs, out, rule: "Integrate", kind: "transform"),)
  cache.insert(key, built)
  built
}

#let _trace-simplify-core(expr, assumptions, depth, detail: 1, memo: none) = {
  let cache = if memo == none { (:)} else { memo }
  let key = "simp|" + repr(expr) + "|" + repr(depth) + "|" + str(detail) + "|" + repr(assumptions)
  if key in cache { return cache.at(key) }
  let cur = expr
  let out = ()
  let used-identities = ()
  let i = 0
  let cap = if depth == none { 8 } else { calc.max(depth, 1) }

  while i < cap {
    let direct-meta = simplify-meta-core(cur, allow-domain-sensitive: true, assumptions: assumptions)
    let expanded-meta = simplify-meta-core(expand-expr(cur), allow-domain-sensitive: true, assumptions: assumptions)
    let direct = direct-meta.expr
    let expanded = expanded-meta.expr

    let direct-helpful = _is-helpful-simplify(cur, direct)
    let expanded-helpful = _is-helpful-simplify(cur, expanded)

    if not direct-helpful and not expanded-helpful { break }

    let use-expanded = expanded-helpful and (
      not direct-helpful
        or _expr-complexity(expanded) < _expr-complexity(direct)
        or (_expr-complexity(expanded) == _expr-complexity(direct) and repr(expanded) < repr(direct))
    )

    // When expansion is selected but a helpful direct simplification exists,
    // show both stages to avoid a large readability jump in one line.
    if (use-expanded and direct-helpful and not expr-eq(direct, expanded)) and (
      _is-pedagogical(detail) or direct-meta.at("identity-count", default: 0) > 0
    ) {
      let direct-rule = _simplify-identity-rule(direct-meta, _describe-simplification(cur, direct))
      out.push(_s-equation(cur, direct, rule: direct-rule, kind: "transform"))
      used-identities += direct-meta.identities-used

      let from-direct-meta = simplify-meta-core(expand-expr(direct), allow-domain-sensitive: true, assumptions: assumptions)
      let from-direct = from-direct-meta.expr
      if _is-helpful-simplify(direct, from-direct) {
        let expanded-rule = _simplify-identity-rule(from-direct-meta, "Expand then simplify")
        out.push(_s-equation(direct, from-direct, rule: expanded-rule, kind: "transform"))
        used-identities += from-direct-meta.identities-used
        cur = from-direct
      } else {
        cur = direct
      }
      i += 1
      continue
    }

    let chosen-meta = if use-expanded { expanded-meta } else { direct-meta }
    let nxt = chosen-meta.expr
    let fallback = if use-expanded { "Expand then simplify" } else { _describe-simplification(cur, nxt) }
    let rule = _simplify-identity-rule(chosen-meta, fallback)
    out.push(_s-equation(cur, nxt, rule: rule, kind: "transform"))
    used-identities += chosen-meta.identities-used
    cur = nxt
    i += 1
  }

  if out.len() == 0 {
    let built = (_s-note("No further simplification found.", tone: "meta"),)
    cache.insert(key, built)
    return built
  }
  if used-identities.len() == 0 {
    let fallback = simplify-meta-core(expr, allow-domain-sensitive: true, assumptions: assumptions)
    let built = out + _identity-summary-notes(fallback.at("identities-used", default: ()))
    cache.insert(key, built)
    return built
  }
  let built = out + _identity-summary-notes(used-identities)
  cache.insert(key, built)
  built
}

#let _quadratic-discriminant(expr, v) = {
  let c = poly-coeffs(expr, v)
  if c == none or c.len() != 3 { return none }
  let a = num(c.at(2))
  let b = num(c.at(1))
  let d = num(c.at(0))
  (
    a: a,
    b: b,
    c: d,
    delta: simplify(sub(pow(b, num(2)), mul(num(4), mul(a, d)))),
  )
}

#let _trace-solve-core(lhs, rhs, var, depth, detail: 1) = {
  let meta = solve-meta(lhs, rhs, var)
  if meta == none {
    return (_s-note("No solver path available for this equation.", tone: "error"),)
  }

  let combined = simplify(sub(lhs, rhs))
  let out = ()
  out.push(_s-equation(sub(lhs, rhs), combined, rule: "Normalize to zero form", kind: "transform"))

  let method = meta.at("method", default: "unknown")
  out.push(_s-note("Method: " + method, tone: "meta"))
  let degree = meta.at("degree", default: none)
  if degree != none {
    out.push(_s-note("Detected polynomial degree: " + str(degree), tone: "meta"))
  }

  if _can-recurse(depth) {
    let sqfg = meta.at("square-free-gcd", default: none)
    let sqfp = meta.at("square-free-part", default: none)
    if sqfg != none and not expr-eq(sqfg, num(1)) {
      out.push(_s-note("Square-free GCD:", expr: sqfg, tone: "meta"))
    }
    if sqfp != none and sqfp != none {
      out.push(_s-note("Square-free part:", expr: sqfp, tone: "meta"))
    }

    if degree == 2 {
      let q = _quadratic-discriminant(combined, var)
      if q != none {
        out.push(_s-define("a", q.a, prefix: "where"))
        out.push(_s-define("b", q.b, prefix: "where"))
        out.push(_s-define("c", q.c, prefix: "where"))
        out.push(_s-note("Discriminant Δ:", expr: q.delta, tone: "meta"))
      }
    }

    let ff = meta.at("factor-form", default: none)
    if ff != none and not expr-eq(ff, combined) {
      out.push(_s-equation(combined, ff, rule: "Factor form", kind: "sub"))
    }
  }

  let roots = meta.at("roots", default: ())
  if roots.len() == 0 {
    out.push(_s-note("No solutions found.", tone: "warn"))
    return out
  }

  for (i, r) in roots.enumerate() {
    let root-name = "r_" + str(i + 1)
    out.push(_s-define(root-name, r.expr, prefix: none))
    out.push(_s-note(
      "mult=" + _as-text(r.at("multiplicity", default: 1))
        + ", exact=" + _as-text(r.at("exact", default: false))
        + ", complex=" + _as-text(r.at("complex", default: false)),
      tone: "meta",
    ))
  }
  out
}

// -------------------------------------------------------------------------
// Public API
// -------------------------------------------------------------------------

#let _step-detail(detail, default: 1) = {
  let d = normalize-detail(detail, default: default)
  if d == none { return default }
  d
}

#let step-diff(expr, var, depth: none, assumptions: none, detail: 1) = {
  let d = _step-detail(detail, default: 1)
  if d == 0 { return () }
  let used-depth = resolve-detail-depth(d, depth: depth)
  let src = simplify(apply-assumptions(expr, assumptions))
  let core = _trace-diff-core(src, var, used-depth, (:), detail: d, memo: (:))
  let out = core
  let boundary = _collect-nonsmooth-boundary(simplify(diff(src, var)), var)
  if boundary.len() > 0 {
    out.push(_s-note("Non-smooth boundary fallback remains symbolic in one or more branches.", tone: "warn"))
  }
  out + _restriction-notes(src, "diff", assumptions)
}

#let step-integrate(expr, var, depth: none, assumptions: none, detail: 1) = {
  let d = _step-detail(detail, default: 1)
  if d == 0 { return () }
  let used-depth = resolve-detail-depth(d, depth: depth)
  let src = apply-assumptions(expr, assumptions)
  let core = _trace-integrate-core(src, var, used-depth, (:), detail: d, memo: (:))
  core + _restriction-notes(src, "integ", assumptions)
}

#let step-simplify(expr, depth: none, assumptions: none, detail: 1) = {
  let d = _step-detail(detail, default: 1)
  if d == 0 { return () }
  let used-depth = resolve-detail-depth(d, depth: depth)
  let src = apply-assumptions(expr, assumptions)
  let core = _trace-simplify-core(src, assumptions, used-depth, detail: d, memo: (:))
  core + _restriction-notes(src, "defined", assumptions)
}

#let step-solve(lhs, rhs, var, depth: none, detail: 1) = {
  let d = _step-detail(detail, default: 1)
  if d == 0 { return () }
  let used-depth = resolve-detail-depth(d, depth: depth)
  _trace-solve-core(lhs, rhs, var, used-depth, detail: d)
}
