// =========================================================================
// CAS Identity Rewrite Engine
// =========================================================================
// Applies declarative identity rules from `src/truths/identities.typ`.
// Rewrites are bottom-up and reduce-only to keep simplification stable.
// =========================================================================

#import "expr.typ": *
#import "truths/identities.typ": identity-rules
#import "truths/function-registry.typ": fn-canonical

/// Public helper `wild`.
#let wild(name) = (type: "wild", name: name)

/// Internal helper `_flatten-op`.
#let _flatten-op(expr, op) = {
  if is-type(expr, op) {
    return _flatten-op(expr.args.at(0), op) + _flatten-op(expr.args.at(1), op)
  }
  (expr,)
}

/// Internal helper `_rebuild-op`.
#let _rebuild-op(terms, op) = {
  if terms.len() == 0 { return none }
  if terms.len() == 1 { return terms.at(0) }
  let out = terms.at(terms.len() - 1)
  let i = terms.len() - 2
  while i >= 0 {
    out = if op == "add" { add(terms.at(i), out) } else { mul(terms.at(i), out) }
    i -= 1
  }
  out
}

/// Internal helper `_identity-complexity`.
#let _identity-complexity(expr) = {
  if is-type(expr, "wild") { return 1 }
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return 1 }
  if is-type(expr, "neg") { return 1 + _identity-complexity(expr.arg) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return 2 + _identity-complexity(expr.args.at(0)) + _identity-complexity(expr.args.at(1))
  }
  if is-type(expr, "div") {
    return 3 + _identity-complexity(expr.num) + _identity-complexity(expr.den)
  }
  if is-type(expr, "pow") {
    return 3 + _identity-complexity(expr.base) + _identity-complexity(expr.exp)
  }
  if is-type(expr, "log") {
    return 4 + _identity-complexity(expr.base) + _identity-complexity(expr.arg)
  }
  if is-type(expr, "func") {
    // Keep ln of structured arguments "expensive" so ln identities remain active.
    let args = func-args(expr)
    if args.len() == 1 and fn-canonical(expr.name) == "ln" and (is-type(args.at(0), "mul") or is-type(args.at(0), "div") or is-type(args.at(0), "pow")) {
      return 8 + _identity-complexity(args.at(0))
    }
    let c = 3
    for a in args {
      c += _identity-complexity(a)
    }
    return c
  }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return 5 + _identity-complexity(expr.body) + _identity-complexity(expr.from) + _identity-complexity(expr.to)
  }
  if is-type(expr, "matrix") {
    let c = 5
    for row in expr.rows {
      for it in row {
        c += _identity-complexity(it)
      }
    }
    return c
  }
  if is-type(expr, "piecewise") {
    let c = 5
    for (e, _) in expr.cases {
      c += _identity-complexity(e)
    }
    return c
  }
  10
}

/// Internal helper `_match-pattern`.
#let _match-pattern(pattern, expr, bindings) = {
  if is-type(pattern, "wild") {
    let key = pattern.name
    let bound = bindings.at(key, default: none)
    if bound == none {
      let nb = bindings
      nb.insert(key, expr)
      return nb
    }
    if expr-eq(bound, expr) { return bindings }
    return none
  }

  if not is-expr(pattern) or not is-expr(expr) {
    if pattern == expr { return bindings }
    return none
  }
  if pattern.type != expr.type { return none }

  if is-type(pattern, "num") { return if pattern.val == expr.val { bindings } else { none } }
  if is-type(pattern, "var") { return if pattern.name == expr.name { bindings } else { none } }
  if is-type(pattern, "const") { return if pattern.name == expr.name { bindings } else { none } }

  if is-type(pattern, "neg") {
    return _match-pattern(pattern.arg, expr.arg, bindings)
  }

  if is-type(pattern, "add") or is-type(pattern, "mul") {
    // Direct order
    let d1 = _match-pattern(pattern.args.at(0), expr.args.at(0), bindings)
    if d1 != none {
      let d2 = _match-pattern(pattern.args.at(1), expr.args.at(1), d1)
      if d2 != none { return d2 }
    }
    // Swapped order (commutative matching)
    let s1 = _match-pattern(pattern.args.at(0), expr.args.at(1), bindings)
    if s1 != none {
      let s2 = _match-pattern(pattern.args.at(1), expr.args.at(0), s1)
      if s2 != none { return s2 }
    }

    // Associative fallback for patterns with one wildcard side:
    // allow that wildcard to capture the "rest" of a flattened sum/product.
    let op = pattern.type
    let terms = _flatten-op(expr, op)
    if terms.len() >= 3 {
      // pattern.left concrete vs one selected term; pattern.right wildcard captures rest
      if is-type(pattern.args.at(1), "wild") {
        for i in range(terms.len()) {
          let b1 = _match-pattern(pattern.args.at(0), terms.at(i), bindings)
          if b1 == none { continue }
          let rest = ()
          for j in range(terms.len()) {
            if j != i { rest.push(terms.at(j)) }
          }
          let rest-expr = _rebuild-op(rest, op)
          let b2 = _match-pattern(pattern.args.at(1), rest-expr, b1)
          if b2 != none { return b2 }
        }
      }
      // pattern.right concrete vs one selected term; pattern.left wildcard captures rest
      if is-type(pattern.args.at(0), "wild") {
        for i in range(terms.len()) {
          let b1 = _match-pattern(pattern.args.at(1), terms.at(i), bindings)
          if b1 == none { continue }
          let rest = ()
          for j in range(terms.len()) {
            if j != i { rest.push(terms.at(j)) }
          }
          let rest-expr = _rebuild-op(rest, op)
          let b2 = _match-pattern(pattern.args.at(0), rest-expr, b1)
          if b2 != none { return b2 }
        }
      }
    }
    return none
  }

  if is-type(pattern, "pow") {
    let b1 = _match-pattern(pattern.base, expr.base, bindings)
    if b1 == none { return none }
    return _match-pattern(pattern.exp, expr.exp, b1)
  }

  if is-type(pattern, "div") {
    let n1 = _match-pattern(pattern.num, expr.num, bindings)
    if n1 == none { return none }
    return _match-pattern(pattern.den, expr.den, n1)
  }

  if is-type(pattern, "func") {
    if pattern.name != expr.name { return none }
    let pa = func-args(pattern)
    let ea = func-args(expr)
    if pa.len() != ea.len() { return none }
    let b = bindings
    for i in range(pa.len()) {
      b = _match-pattern(pa.at(i), ea.at(i), b)
      if b == none { return none }
    }
    return b
  }

  if is-type(pattern, "log") {
    let b1 = _match-pattern(pattern.base, expr.base, bindings)
    if b1 == none { return none }
    return _match-pattern(pattern.arg, expr.arg, b1)
  }

  if is-type(pattern, "sum") or is-type(pattern, "prod") {
    if pattern.idx != expr.idx { return none }
    let b1 = _match-pattern(pattern.body, expr.body, bindings)
    if b1 == none { return none }
    let f1 = _match-pattern(pattern.from, expr.from, b1)
    if f1 == none { return none }
    return _match-pattern(pattern.to, expr.to, f1)
  }

  if is-type(pattern, "matrix") {
    if pattern.rows.len() != expr.rows.len() { return none }
    let b = bindings
    for i in range(pattern.rows.len()) {
      let pr = pattern.rows.at(i)
      let er = expr.rows.at(i)
      if pr.len() != er.len() { return none }
      for j in range(pr.len()) {
        b = _match-pattern(pr.at(j), er.at(j), b)
        if b == none { return none }
      }
    }
    return b
  }

  if is-type(pattern, "piecewise") {
    if pattern.cases.len() != expr.cases.len() { return none }
    let b = bindings
    for i in range(pattern.cases.len()) {
      let pc = pattern.cases.at(i)
      let ec = expr.cases.at(i)
      b = _match-pattern(pc.at(0), ec.at(0), b)
      if b == none { return none }
      if pc.at(1) != ec.at(1) { return none }
    }
    return b
  }

  bindings
}

/// Internal helper `_instantiate-template`.
#let _instantiate-template(t, bindings) = {
  if is-type(t, "wild") {
    return bindings.at(t.name, default: none)
  }
  if is-type(t, "num") or is-type(t, "var") or is-type(t, "const") { return t }

  if is-type(t, "neg") {
    return neg(_instantiate-template(t.arg, bindings))
  }
  if is-type(t, "add") {
    return add(_instantiate-template(t.args.at(0), bindings), _instantiate-template(t.args.at(1), bindings))
  }
  if is-type(t, "mul") {
    return mul(_instantiate-template(t.args.at(0), bindings), _instantiate-template(t.args.at(1), bindings))
  }
  if is-type(t, "pow") {
    return pow(_instantiate-template(t.base, bindings), _instantiate-template(t.exp, bindings))
  }
  if is-type(t, "div") {
    return cdiv(_instantiate-template(t.num, bindings), _instantiate-template(t.den, bindings))
  }
  if is-type(t, "func") {
    let args = func-args(t).map(a => _instantiate-template(a, bindings))
    return func(t.name, ..args)
  }
  if is-type(t, "log") {
    return (type: "log", base: _instantiate-template(t.base, bindings), arg: _instantiate-template(t.arg, bindings))
  }
  if is-type(t, "sum") {
    return csum(
      _instantiate-template(t.body, bindings),
      t.idx,
      _instantiate-template(t.from, bindings),
      _instantiate-template(t.to, bindings),
    )
  }
  if is-type(t, "prod") {
    return cprod(
      _instantiate-template(t.body, bindings),
      t.idx,
      _instantiate-template(t.from, bindings),
      _instantiate-template(t.to, bindings),
    )
  }
  if is-type(t, "matrix") {
    return (type: "matrix", rows: t.rows.map(row => row.map(item => _instantiate-template(item, bindings))))
  }
  if is-type(t, "piecewise") {
    return (type: "piecewise", cases: t.cases.map(((e, c)) => (_instantiate-template(e, bindings), c)))
  }
  t
}

/// Internal helper `_accept-rewrite`.
#let _accept-rewrite(before, after) = {
  if after == none { return false }
  if expr-eq(before, after) { return false }
  let cb = _identity-complexity(before)
  let ca = _identity-complexity(after)
  if ca < cb { return true }
  if ca > cb { return false }
  repr(after) < repr(before)
}

/// Internal helper `_rewrite-current-node`.
#let _rewrite-current-node(expr, allow-domain-sensitive: false) = {
  let out = expr
  let changed = true
  while changed {
    changed = false
    for rule in identity-rules {
      if rule.at("domain-sensitive", default: false) and not allow-domain-sensitive {
        continue
      }
      let bindings = _match-pattern(rule.lhs, out, (:))
      if bindings == none { continue }
      let cand = _instantiate-template(rule.rhs, bindings)
      if _accept-rewrite(out, cand) {
        out = cand
        changed = true
        break
      }
    }
  }
  out
}

/// Internal helper `_rewrite-bottom-up`.
#let _rewrite-bottom-up(expr, allow-domain-sensitive: false) = {
  let cur = expr
  if is-type(cur, "neg") {
    cur = neg(_rewrite-bottom-up(cur.arg, allow-domain-sensitive: allow-domain-sensitive))
  } else if is-type(cur, "add") {
    cur = add(
      _rewrite-bottom-up(cur.args.at(0), allow-domain-sensitive: allow-domain-sensitive),
      _rewrite-bottom-up(cur.args.at(1), allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "mul") {
    cur = mul(
      _rewrite-bottom-up(cur.args.at(0), allow-domain-sensitive: allow-domain-sensitive),
      _rewrite-bottom-up(cur.args.at(1), allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "pow") {
    cur = pow(
      _rewrite-bottom-up(cur.base, allow-domain-sensitive: allow-domain-sensitive),
      _rewrite-bottom-up(cur.exp, allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "div") {
    cur = cdiv(
      _rewrite-bottom-up(cur.num, allow-domain-sensitive: allow-domain-sensitive),
      _rewrite-bottom-up(cur.den, allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "func") {
    let args = func-args(cur).map(a => _rewrite-bottom-up(a, allow-domain-sensitive: allow-domain-sensitive))
    cur = func(cur.name, ..args)
  } else if is-type(cur, "log") {
    cur = (
      type: "log",
      base: _rewrite-bottom-up(cur.base, allow-domain-sensitive: allow-domain-sensitive),
      arg: _rewrite-bottom-up(cur.arg, allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "sum") {
    cur = (
      type: "sum",
      body: _rewrite-bottom-up(cur.body, allow-domain-sensitive: allow-domain-sensitive),
      idx: cur.idx,
      from: _rewrite-bottom-up(cur.from, allow-domain-sensitive: allow-domain-sensitive),
      to: _rewrite-bottom-up(cur.to, allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "prod") {
    cur = (
      type: "prod",
      body: _rewrite-bottom-up(cur.body, allow-domain-sensitive: allow-domain-sensitive),
      idx: cur.idx,
      from: _rewrite-bottom-up(cur.from, allow-domain-sensitive: allow-domain-sensitive),
      to: _rewrite-bottom-up(cur.to, allow-domain-sensitive: allow-domain-sensitive),
    )
  } else if is-type(cur, "matrix") {
    cur = (
      type: "matrix",
      rows: cur.rows.map(row => row.map(item => _rewrite-bottom-up(item, allow-domain-sensitive: allow-domain-sensitive))),
    )
  } else if is-type(cur, "piecewise") {
    cur = (
      type: "piecewise",
      cases: cur.cases.map(((e, c)) => (_rewrite-bottom-up(e, allow-domain-sensitive: allow-domain-sensitive), c)),
    )
  }
  _rewrite-current-node(cur, allow-domain-sensitive: allow-domain-sensitive)
}

/// Public helper `apply-identities-once`.
#let apply-identities-once(expr, allow-domain-sensitive: false) = {
  _rewrite-bottom-up(expr, allow-domain-sensitive: allow-domain-sensitive)
}
