// =========================================================================
// CAS Assumptions
// =========================================================================
// Lightweight assumption system for domain-aware simplification.
// Assumptions are dictionaries keyed by variable name:
//   (x: (real: true, positive: true, nonzero: true, domain: ...))
// =========================================================================

#import "expr.typ": *
#import "truths/function-registry.typ": fn-canonical
#import "domain.typ": parse-domain, domain-intersect, domain-status-rel, domain-normalize, domain-to-string

/// Internal helper `_assume-get`.
#let _assume-get(assumptions, var, key) = {
  let rec = assumptions.at(var, default: (:))
  rec.at(key, default: false)
}

/// Internal helper `_assume-domain-get`.
#let _assume-domain-get(assumptions, var) = {
  let rec = assumptions.at(var, default: (:))
  rec.at("domain", default: none)
}

/// Internal helper `_strip-spaces`.
#let _strip-spaces(s) = {
  let out = ()
  for c in s.clusters() {
    if c != " " and c != "\t" and c != "\n" and c != "\r" {
      out.push(c)
    }
  }
  out.join()
}

/// Internal helper `_domain-shortcut`.
/// Supports compact shorthand in addition to interval notation.
#let _domain-shortcut(raw) = {
  let s = _strip-spaces(raw)
  if s == "(0" { return "(0,inf)" }
  if s == "[0" { return "[0,inf)" }
  if s == ">0" { return "(0,inf)" }
  if s == ">=0" { return "[0,inf)" }
  if s == "0)" { return "(-inf,0)" }
  if s == "0]" { return "(-inf,0]" }
  if s == "<0" { return "(-inf,0)" }
  if s == "<=0" { return "(-inf,0]" }
  if s == "!=0" { return "(-inf,0)U(0,inf)" }
  s
}

/// Internal helper `_with-domain-flags`.
#let _with-domain-flags(rec) = {
  let d = rec.at("domain", default: none)
  if d == none { return rec }
  let pos = domain-status-rel(d, ">", 0) == "satisfied"
  let nonneg = domain-status-rel(d, ">=", 0) == "satisfied"
  let neg = domain-status-rel(d, "<", 0) == "satisfied"
  let nonzero = domain-status-rel(d, "!=", 0) == "satisfied"
  (
    real: rec.at("real", default: false) or true,
    positive: rec.at("positive", default: false) or pos,
    nonzero: rec.at("nonzero", default: false) or nonzero,
    nonnegative: rec.at("nonnegative", default: false) or nonneg,
    negative: rec.at("negative", default: false) or neg,
    domain: d,
  )
}

/// Public helper `assume`.
#let assume(var, real: false, positive: false, nonzero: false, nonnegative: false, negative: false) = {
  let out = (:)
  out.insert(var, _with-domain-flags((
    real: real,
    positive: positive,
    nonzero: nonzero,
    nonnegative: nonnegative,
    negative: negative,
    domain: none,
  )))
  out
}

/// Public helper `assume-domain`.
/// Accepts interval notation and compact shorthand (`(0`, `[0`, `>0`, etc.).
#let assume-domain(var, domain-str) = {
  let out = (:)
  let dom = parse-domain(_domain-shortcut(domain-str))
  out.insert(var, _with-domain-flags((
    real: false,
    positive: false,
    nonzero: false,
    nonnegative: false,
    negative: false,
    domain: dom,
  )))
  out
}

/// Public helper `assume-string`.
/// Basic string assumptions for quick setup:
/// - "real,nonzero"
/// - "(0"  (shorthand for positive domain)
/// - "(0,inf)U(-inf,0)" (domain string)
#let assume-string(var, spec) = {
  if type(spec) != str {
    panic("assume-string: spec must be a string")
  }
  let raw = _strip-spaces(spec)
  if raw == "" { panic("assume-string: empty assumption string") }

  // Domain-like strings go straight to `assume-domain`.
  let first = raw.clusters().at(0)
  if (first == "(" or first == "[") and "," in raw and (")" in raw or "]" in raw) {
    return assume-domain(var, raw)
  }

  let rec = (
    real: false,
    positive: false,
    nonzero: false,
    nonnegative: false,
    negative: false,
    domain: none,
  )
  let tokens = raw.split(",")
  for tok in tokens {
    if tok == "" { continue }
    if tok == "real" {
      rec = (..rec, real: true)
      continue
    }
    if tok == "positive" or tok == ">0" {
      rec = (..rec, positive: true, nonzero: true)
      let dom = parse-domain("(0,inf)")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    if tok == "nonnegative" or tok == ">=0" or tok == "[0" {
      rec = (..rec, nonnegative: true)
      let dom = parse-domain("[0,inf)")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    if tok == "(0" {
      rec = (..rec, positive: true, nonzero: true)
      let dom = parse-domain("(0,inf)")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    if tok == "negative" or tok == "<0" {
      rec = (..rec, negative: true, nonzero: true)
      let dom = parse-domain("(-inf,0)")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    if tok == "<=0" or tok == "0)" or tok == "0]" {
      let dom = parse-domain("(-inf,0]")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    if tok == "nonzero" or tok == "!=0" {
      rec = (..rec, nonzero: true)
      let dom = parse-domain("(-inf,0)U(0,inf)")
      rec = (..rec, domain: if rec.domain == none { dom } else { domain-intersect(rec.domain, dom) })
      continue
    }
    panic("assume-string: unsupported token '" + tok + "'")
  }

  let out = (:)
  out.insert(var, _with-domain-flags(rec))
  out
}

/// Internal helper `_merge-rec`.
#let _merge-rec(a, b) = {
  let da = a.at("domain", default: none)
  let db = b.at("domain", default: none)
  let domain = if da == none {
    db
  } else if db == none {
    da
  } else {
    domain-intersect(da, db)
  }

  _with-domain-flags((
    real: a.at("real", default: false) or b.at("real", default: false),
    positive: a.at("positive", default: false) or b.at("positive", default: false),
    nonzero: a.at("nonzero", default: false) or b.at("nonzero", default: false),
    nonnegative: a.at("nonnegative", default: false) or b.at("nonnegative", default: false),
    negative: a.at("negative", default: false) or b.at("negative", default: false),
    domain: domain,
  ))
}

/// Public helper `merge-assumptions`.
#let merge-assumptions(..assumptions) = {
  let out = (:)
  for block in assumptions.pos() {
    for k in block.keys() {
      let incoming = block.at(k, default: (:))
      if k in out {
        out.insert(k, _merge-rec(out.at(k), incoming))
      } else {
        out.insert(k, _with-domain-flags((
          real: incoming.at("real", default: false),
          positive: incoming.at("positive", default: false),
          nonzero: incoming.at("nonzero", default: false),
          nonnegative: incoming.at("nonnegative", default: false),
          negative: incoming.at("negative", default: false),
          domain: incoming.at("domain", default: none),
        )))
      }
    }
  }
  out
}

/// Internal helper `_is-positive-var`.
#let _is-positive-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  let name = expr.name
  if _assume-get(assumptions, name, "positive") { return true }
  if _assume-get(assumptions, name, "nonnegative") { return true }
  let domain = _assume-domain-get(assumptions, name)
  if domain != none {
    if domain-status-rel(domain, ">", 0) == "satisfied" { return true }
    if domain-status-rel(domain, ">=", 0) == "satisfied" { return true }
  }
  false
}

/// Internal helper `_is-negative-var`.
#let _is-negative-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  let name = expr.name
  if _assume-get(assumptions, name, "negative") { return true }
  let domain = _assume-domain-get(assumptions, name)
  if domain != none {
    if domain-status-rel(domain, "<", 0) == "satisfied" { return true }
    if domain-status-rel(domain, "<=", 0) == "satisfied" { return true }
  }
  false
}

/// Internal helper `_is-real-var`.
#let _is-real-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  let name = expr.name
  if _assume-get(assumptions, name, "real") { return true }
  if _assume-get(assumptions, name, "positive") { return true }
  if _assume-get(assumptions, name, "nonnegative") { return true }
  if _assume-get(assumptions, name, "negative") { return true }
  if _assume-domain-get(assumptions, name) != none { return true }
  false
}

/// Internal helper `_apply`.
#let _apply(expr, assumptions) = {
  if assumptions == none { return expr }

  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  if is-type(expr, "neg") {
    return neg(_apply(expr.arg, assumptions))
  }

  if is-type(expr, "add") {
    return add(_apply(expr.args.at(0), assumptions), _apply(expr.args.at(1), assumptions))
  }

  if is-type(expr, "mul") {
    return mul(_apply(expr.args.at(0), assumptions), _apply(expr.args.at(1), assumptions))
  }

  if is-type(expr, "div") {
    return cdiv(_apply(expr.num, assumptions), _apply(expr.den, assumptions))
  }

  if is-type(expr, "pow") {
    let base = _apply(expr.base, assumptions)
    let exp = _apply(expr.exp, assumptions)

    // sqrt(x^2) simplification under assumptions.
    if is-type(exp, "div") and is-type(exp.num, "num") and is-type(exp.den, "num") {
      if exp.num.val == 1 and exp.den.val == 2 and is-type(base, "pow") and is-type(base.exp, "num") and base.exp.val == 2 {
        let inner = base.base
        if _is-positive-var(inner, assumptions) {
          return inner
        }
        if _is-real-var(inner, assumptions) {
          return func("abs", inner)
        }
      }
    }

    return pow(base, exp)
  }

  if is-type(expr, "func") {
    let args = func-args(expr).map(a => _apply(a, assumptions))
    let unary = args.len() == 1
    let cname = fn-canonical(expr.name)

    if unary and cname == "abs" {
      let arg = args.at(0)
      if _is-positive-var(arg, assumptions) {
        return arg
      }
      if _is-negative-var(arg, assumptions) {
        return neg(arg)
      }
    }

    return func(expr.name, ..args)
  }

  if is-type(expr, "log") {
    return (type: "log", base: _apply(expr.base, assumptions), arg: _apply(expr.arg, assumptions))
  }

  if is-type(expr, "sum") {
    return (
      type: "sum",
      body: _apply(expr.body, assumptions),
      idx: expr.idx,
      from: _apply(expr.from, assumptions),
      to: _apply(expr.to, assumptions),
    )
  }

  if is-type(expr, "prod") {
    return (
      type: "prod",
      body: _apply(expr.body, assumptions),
      idx: expr.idx,
      from: _apply(expr.from, assumptions),
      to: _apply(expr.to, assumptions),
    )
  }

  expr
}

/// Public helper `apply-assumptions`.
#let apply-assumptions(expr, assumptions) = _apply(expr, assumptions)

/// Internal helper `_all-real-domain`.
#let _all-real-domain() = (intervals: ((lo: none, lo-closed: false, hi: none, hi-closed: false),))

/// Internal helper `_effective-domain-from-record`.
#let _effective-domain-from-record(rec) = {
  let out = rec.at("domain", default: none)
  if rec.at("positive", default: false) {
    let d = parse-domain("(0,inf)")
    out = if out == none { d } else { domain-intersect(out, d) }
  }
  if rec.at("nonnegative", default: false) {
    let d = parse-domain("[0,inf)")
    out = if out == none { d } else { domain-intersect(out, d) }
  }
  if rec.at("negative", default: false) {
    let d = parse-domain("(-inf,0)")
    out = if out == none { d } else { domain-intersect(out, d) }
  }
  if rec.at("nonzero", default: false) {
    let d = parse-domain("(-inf,0)U(0,inf)")
    out = if out == none { d } else { domain-intersect(out, d) }
  }

  if rec.at("real", default: false) {
    if out == none { return domain-normalize(_all-real-domain()) }
  }

  if out == none { return domain-normalize(_all-real-domain()) }
  domain-normalize(out)
}

/// Public helper `variable-domain`.
/// Returns the effective canonical domain for a variable under assumptions.
#let variable-domain(var, assumptions: none) = {
  if type(var) != str {
    panic("variable-domain: variable name must be a string")
  }
  if assumptions == none or not (var in assumptions) {
    return domain-normalize(_all-real-domain())
  }
  let rec = assumptions.at(var, default: (:))
  _effective-domain-from-record(rec)
}

/// Public helper `display-variable-domain`.
/// Renders a variable domain as canonical interval-union text.
#let display-variable-domain(var, assumptions: none) = domain-to-string(variable-domain(var, assumptions: assumptions))
