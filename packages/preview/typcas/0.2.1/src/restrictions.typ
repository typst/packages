// =========================================================================
// typcas v2 Restriction Engine
// =========================================================================
// Collect, propagate, and classify domain restrictions.
// Canonical state is variable-domain metadata.
// =========================================================================

#import "expr.typ": *
#import "domain.typ": domain-intersect, domain-status-rel
#import "truths/function-registry.typ": fn-spec
#import "display.typ": cas-display

// -------------------------------------------------------------------------
// Basic restriction helpers
// -------------------------------------------------------------------------

#let mk-restriction(lhs, rel, rhs, source: "", stage: "defined", note: "") = (
  lhs: lhs,
  rel: rel,
  rhs: rhs,
  source: source,
  stage: stage,
  note: note,
)

#let restriction-key(r) = repr(r.lhs) + ":" + r.rel + ":" + repr(r.rhs)

#let merge-restrictions(a, b) = {
  let out = ()
  let seen = (:)
  for r in a {
    let k = restriction-key(r)
    if not (k in seen) {
      seen.insert(k, true)
      out.push(r)
    }
  }
  for r in b {
    let k = restriction-key(r)
    if not (k in seen) {
      seen.insert(k, true)
      out.push(r)
    }
  }
  out
}

// -------------------------------------------------------------------------
// Assumption readers (local, to avoid module cycles)
// -------------------------------------------------------------------------

#let _assume-get(assumptions, var, key) = {
  if assumptions == none { return false }
  let rec = assumptions.at(var, default: none)
  if rec == none { return false }
  rec.at(key, default: false)
}

#let _assume-domain(assumptions, var) = {
  if assumptions == none { return none }
  let rec = assumptions.at(var, default: none)
  if rec == none { return none }
  rec.at("domain", default: none)
}

// -------------------------------------------------------------------------
// Domain helpers for promoted affine constraints
// -------------------------------------------------------------------------

#let _domain-all = () => (
  intervals: (
    (lo: none, lo-closed: false, hi: none, hi-closed: false),
  ),
)

#let _domain-from-rel(rel, c) = {
  if rel == ">" {
    return (intervals: ((lo: c, lo-closed: false, hi: none, hi-closed: false),))
  }
  if rel == ">=" {
    return (intervals: ((lo: c, lo-closed: true, hi: none, hi-closed: false),))
  }
  if rel == "<" {
    return (intervals: ((lo: none, lo-closed: false, hi: c, hi-closed: false),))
  }
  if rel == "<=" {
    return (intervals: ((lo: none, lo-closed: false, hi: c, hi-closed: true),))
  }
  if rel == "!=" {
    return (
      intervals: (
        (lo: none, lo-closed: false, hi: c, hi-closed: false),
        (lo: c, lo-closed: false, hi: none, hi-closed: false),
      ),
    )
  }
  if rel == "=" {
    return (intervals: ((lo: c, lo-closed: true, hi: c, hi-closed: true),))
  }
  none
}

#let _domain-empty(d) = {
  if d == none { return true }
  d.at("intervals", default: ()).len() == 0
}

#let _seed-domain-from-assumption-record(rec) = {
  let out = _domain-all()
  let d = rec.at("domain", default: none)
  if d != none { out = domain-intersect(out, d) }
  if rec.at("positive", default: false) {
    out = domain-intersect(out, _domain-from-rel(">", 0))
  }
  if rec.at("nonnegative", default: false) {
    out = domain-intersect(out, _domain-from-rel(">=", 0))
  }
  if rec.at("negative", default: false) {
    out = domain-intersect(out, _domain-from-rel("<", 0))
  }
  if rec.at("nonzero", default: false) {
    out = domain-intersect(out, _domain-from-rel("!=", 0))
  }
  out
}

#let _effective-assumptions(assumptions, vars) = {
  let domains = (:)
  for v in vars {
    let rec = if assumptions == none { none } else { assumptions.at(v, default: none) }
    if rec == none {
      domains.insert(v, _domain-all())
    } else {
      domains.insert(v, _seed-domain-from-assumption-record(rec))
    }
  }
  domains
}

#let _merge-status(a, b) = {
  if a == "conflict" or b == "conflict" { return "conflict" }
  if a == "unknown" or b == "unknown" { return "unknown" }
  "satisfied"
}

#let _status-var-num(var-name, rel, c, assumptions) = {
  let d = _assume-domain(assumptions, var-name)
  if d != none {
    return domain-status-rel(d, rel, c)
  }

  if c == 0 {
    if rel == ">" and _assume-get(assumptions, var-name, "positive") { return "satisfied" }
    if rel == ">=" and (_assume-get(assumptions, var-name, "positive") or _assume-get(assumptions, var-name, "nonnegative")) {
      return "satisfied"
    }
    if rel == "<" and _assume-get(assumptions, var-name, "negative") { return "satisfied" }
    if rel == "<=" and _assume-get(assumptions, var-name, "negative") { return "satisfied" }
    if rel == "!=" and _assume-get(assumptions, var-name, "nonzero") { return "satisfied" }
  }
  "unknown"
}

// -------------------------------------------------------------------------
// Expression analysis
// -------------------------------------------------------------------------

#let _vars-in-expr(expr) = {
  if is-type(expr, "var") { return (expr.name,) }
  if is-type(expr, "num") or is-type(expr, "const") { return () }
  if is-type(expr, "neg") { return _vars-in-expr(expr.arg) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return _vars-in-expr(expr.args.at(0)) + _vars-in-expr(expr.args.at(1))
  }
  if is-type(expr, "pow") { return _vars-in-expr(expr.base) + _vars-in-expr(expr.exp) }
  if is-type(expr, "div") { return _vars-in-expr(expr.num) + _vars-in-expr(expr.den) }
  if is-type(expr, "func") {
    let out = ()
    for a in func-args(expr) { out += _vars-in-expr(a) }
    return out
  }
  if is-type(expr, "log") { return _vars-in-expr(expr.base) + _vars-in-expr(expr.arg) }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return _vars-in-expr(expr.body) + _vars-in-expr(expr.from) + _vars-in-expr(expr.to)
  }
  if is-type(expr, "integral") {
    let xs = ()
    for v in _vars-in-expr(expr.expr) {
      if v != expr.var { xs.push(v) }
    }
    return xs
  }
  if is-type(expr, "def-integral") {
    let xs = ()
    for v in _vars-in-expr(expr.expr) {
      if v != expr.var { xs.push(v) }
    }
    return xs + _vars-in-expr(expr.lo) + _vars-in-expr(expr.hi)
  }
  if is-type(expr, "matrix") {
    let out = ()
    for row in expr.rows {
      for c in row { out += _vars-in-expr(c) }
    }
    return out
  }
  if is-type(expr, "piecewise") {
    let out = ()
    for case in expr.cases {
      out += _vars-in-expr(case.at(0))
      let cond = case.at(1)
      if is-expr(cond) { out += _vars-in-expr(cond) }
    }
    return out
  }
  if is-type(expr, "cond-rel") {
    return _vars-in-expr(expr.lhs) + _vars-in-expr(expr.rhs)
  }
  if is-type(expr, "cond-and") {
    let out = ()
    for c in expr.args { out += _vars-in-expr(c) }
    return out
  }
  if is-type(expr, "complex") { return _vars-in-expr(expr.re) + _vars-in-expr(expr.im) }
  ()
}

/// Read expression as `a*x + b` for one chosen variable.
#let _affine(expr, var) = {
  if is-type(expr, "num") { return (a: 0.0, b: expr.val + 0.0) }
  if is-type(expr, "var") {
    if expr.name == var { return (a: 1.0, b: 0.0) }
    return none
  }
  if is-type(expr, "neg") {
    let p = _affine(expr.arg, var)
    if p == none { return none }
    return (a: -p.a, b: -p.b)
  }
  if is-type(expr, "add") {
    let p = _affine(expr.args.at(0), var)
    let q = _affine(expr.args.at(1), var)
    if p == none or q == none { return none }
    return (a: p.a + q.a, b: p.b + q.b)
  }
  if is-type(expr, "mul") {
    let l = expr.args.at(0)
    let r = expr.args.at(1)
    if is-type(l, "num") {
      let p = _affine(r, var)
      if p == none { return none }
      return (a: l.val * p.a, b: l.val * p.b)
    }
    if is-type(r, "num") {
      let p = _affine(l, var)
      if p == none { return none }
      return (a: r.val * p.a, b: r.val * p.b)
    }
    return none
  }
  if is-type(expr, "div") {
    if is-type(expr.den, "num") and expr.den.val != 0 {
      let p = _affine(expr.num, var)
      if p == none { return none }
      return (a: p.a / expr.den.val, b: p.b / expr.den.val)
    }
    return none
  }
  none
}

#let _flip-rel(rel) = {
  if rel == ">" { return "<" }
  if rel == ">=" { return "<=" }
  if rel == "<" { return ">" }
  if rel == "<=" { return ">=" }
  rel
}

/// Normalize `lhs rel rhs` to `x rel c` when affine and univariate.
#let _normalize-affine-rel(lhs, rel, rhs) = {
  let vars = ()
  let seen = (:)
  for v in _vars-in-expr(lhs) {
    if not (v in seen) {
      seen.insert(v, true)
      vars.push(v)
    }
  }
  for v in _vars-in-expr(rhs) {
    if not (v in seen) {
      seen.insert(v, true)
      vars.push(v)
    }
  }
  if vars.len() != 1 { return none }
  let var = vars.at(0)

  let l = _affine(lhs, var)
  let r = _affine(rhs, var)
  if l == none or r == none { return none }

  let a = l.a - r.a
  let b = l.b - r.b
  if calc.abs(a) < 1e-14 { return none }

  let rr = rel
  let c = (-b) / a
  if a < 0 { rr = _flip-rel(rr) }
  (var: var, rel: rr, c: c)
}

#let _promote-constraint(r) = {
  let n = _normalize-affine-rel(r.lhs, r.rel, r.rhs)
  if n == none { return none }
  let d = _domain-from-rel(n.rel, n.c)
  if d == none { return none }
  (var: n.var, rel: n.rel, c: n.c, domain: d)
}

#let _num-rel-status(a, rel, b) = {
  if rel == ">" { return if a > b { "satisfied" } else { "conflict" } }
  if rel == ">=" { return if a >= b { "satisfied" } else { "conflict" } }
  if rel == "<" { return if a < b { "satisfied" } else { "conflict" } }
  if rel == "<=" { return if a <= b { "satisfied" } else { "conflict" } }
  if rel == "!=" { return if a != b { "satisfied" } else { "conflict" } }
  if rel == "=" or rel == "==" { return if a == b { "satisfied" } else { "conflict" } }
  "unknown"
}

#let _expr-sign-class(expr) = {
  if is-type(expr, "num") {
    if expr.val > 0 { return "positive" }
    if expr.val < 0 { return "negative" }
    return "zero"
  }

  if is-type(expr, "func") and func-args(expr).len() == 1 {
    let spec = fn-spec(expr.name)
    if spec != none {
      let analysis = spec.at("analysis", default: none)
      if analysis != none {
        if analysis.at("always-positive", default: false) { return "positive" }
        if analysis.at("nonnegative", default: false) { return "nonnegative" }
      }
    }
  }

  // Structural fallback for e^u positivity when written as a power node.
  if is-type(expr, "pow") and is-type(expr.base, "const") and expr.base.name == "e" {
    return "positive"
  }

  "unknown"
}

#let _status-from-sign(rel, sign) = {
  if sign == "positive" {
    if rel == ">" or rel == ">=" or rel == "!=" { return "satisfied" }
    if rel == "<" or rel == "<=" or rel == "=" or rel == "==" { return "conflict" }
    return "unknown"
  }

  if sign == "nonnegative" {
    if rel == ">=" { return "satisfied" }
    if rel == "<" { return "conflict" }
    return "unknown"
  }

  if sign == "zero" {
    if rel == ">" or rel == "<" or rel == "!=" { return "conflict" }
    if rel == ">=" or rel == "<=" or rel == "=" or rel == "==" { return "satisfied" }
    return "unknown"
  }

  if sign == "negative" {
    if rel == "<" or rel == "<=" or rel == "!=" { return "satisfied" }
    if rel == ">" or rel == ">=" or rel == "=" or rel == "==" { return "conflict" }
    return "unknown"
  }

  "unknown"
}

#let _restriction-status-late(r, assumptions) = {
  if is-type(r.lhs, "num") and is-type(r.rhs, "num") {
    return _num-rel-status(r.lhs.val + 0.0, r.rel, r.rhs.val + 0.0)
  }

  if is-type(r.rhs, "num") and r.rhs.val == 0 {
    let lhs-sign = _expr-sign-class(r.lhs)
    if lhs-sign != "unknown" { return _status-from-sign(r.rel, lhs-sign) }
  }
  if is-type(r.lhs, "num") and r.lhs.val == 0 {
    let rhs-sign = _expr-sign-class(r.rhs)
    if rhs-sign != "unknown" { return _status-from-sign(_flip-rel(r.rel), rhs-sign) }
  }

  if is-type(r.lhs, "var") and is-type(r.rhs, "num") {
    return _status-var-num(r.lhs.name, r.rel, r.rhs.val + 0.0, assumptions)
  }
  if is-type(r.rhs, "var") and is-type(r.lhs, "num") {
    return _status-var-num(r.rhs.name, _flip-rel(r.rel), r.lhs.val + 0.0, assumptions)
  }

  let p = _promote-constraint(r)
  if p != none {
    return _status-var-num(p.var, p.rel, p.c, assumptions)
  }
  "unknown"
}

// -------------------------------------------------------------------------
// Variable-domain propagation
// -------------------------------------------------------------------------

#let propagate-variable-domains(constraints, assumptions: none) = {
  let vars = ()
  let seen = (:)

  if assumptions != none {
    for v in assumptions.keys() {
      if not (v in seen) {
        seen.insert(v, true)
        vars.push(v)
      }
    }
  }

  for r in constraints {
    for v in _vars-in-expr(r.lhs) {
      if not (v in seen) {
        seen.insert(v, true)
        vars.push(v)
      }
    }
    for v in _vars-in-expr(r.rhs) {
      if not (v in seen) {
        seen.insert(v, true)
        vars.push(v)
      }
    }
  }

  let domains = _effective-assumptions(assumptions, vars)
  let residual = ()
  let conflicts = ()

  for r in constraints {
    let p = _promote-constraint(r)
    if p == none {
      residual.push(r)
      continue
    }

    let cur = domains.at(p.var, default: _domain-all())
    let nxt = domain-intersect(cur, p.domain)
    domains.insert(p.var, nxt)

    if _domain-empty(nxt) {
      conflicts.push(r)
    }
  }

  (
    vars: domains,
    residual: residual,
    conflicts: conflicts,
  )
}

#let _restriction-status(r, assumptions) = _restriction-status-late(r, assumptions)

// -------------------------------------------------------------------------
// Restriction filtering/classification
// -------------------------------------------------------------------------

#let _assumptions-with-domains(assumptions, domains) = {
  let out = (:)
  if assumptions != none {
    for v in assumptions.keys() { out.insert(v, assumptions.at(v)) }
  }
  for v in domains.keys() {
    let old = out.at(v, default: (
      real: true,
      positive: false,
      nonzero: false,
      nonnegative: false,
      negative: false,
      domain: none,
    ))
    out.insert(v, (
      real: old.at("real", default: true),
      positive: old.at("positive", default: false),
      nonzero: old.at("nonzero", default: false),
      nonnegative: old.at("nonnegative", default: false),
      negative: old.at("negative", default: false),
      domain: domains.at(v),
    ))
  }
  out
}

#let filter-restrictions-by-assumptions(restrictions, assumptions) = {
  let state = propagate-variable-domains(restrictions, assumptions: assumptions)
  let eff = _assumptions-with-domains(assumptions, state.vars)

  let unresolved = ()
  let satisfied = ()
  let conflicts = ()

  for r in restrictions {
    let st = _restriction-status(r, eff)
    if st == "satisfied" {
      satisfied.push(r)
    } else if st == "conflict" {
      conflicts.push(r)
    } else {
      unresolved.push(r)
    }
  }

  (
    restrictions: unresolved,
    satisfied: satisfied,
    conflicts: merge-restrictions(conflicts, state.conflicts),
    residual: state.residual,
    variable-domains: state.vars,
  )
}

// -------------------------------------------------------------------------
// Constraint collection
// -------------------------------------------------------------------------

#let _collect-structural(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return () }

  if is-type(expr, "neg") { return _collect-structural(expr.arg) }

  if is-type(expr, "add") or is-type(expr, "mul") {
    return merge-restrictions(
      _collect-structural(expr.args.at(0)),
      _collect-structural(expr.args.at(1)),
    )
  }

  if is-type(expr, "pow") {
    let out = merge-restrictions(
      _collect-structural(expr.base),
      _collect-structural(expr.exp),
    )
    let even-root = (
      is-type(expr.exp, "div")
        and is-type(expr.exp.den, "num")
        and type(expr.exp.den.val) == int
        and calc.rem(calc.abs(expr.exp.den.val), 2) == 0
    )
    if even-root {
      out = merge-restrictions(out, (
        mk-restriction(
          expr.base,
          ">=",
          num(0),
          source: "op:pow",
          stage: "defined",
          note: "Even-root real-domain requires base >= 0.",
        ),
      ))
    }
    return out
  }

  if is-type(expr, "div") {
    return merge-restrictions(
      merge-restrictions(
        _collect-structural(expr.num),
        _collect-structural(expr.den),
      ),
      (
        mk-restriction(
          expr.den,
          "!=",
          num(0),
          source: "op:div",
          stage: "defined",
          note: "Division requires non-zero denominator.",
        ),
      ),
    )
  }

  if is-type(expr, "log") {
    return merge-restrictions(
      merge-restrictions(_collect-structural(expr.base), _collect-structural(expr.arg)),
      (
        mk-restriction(expr.base, ">", num(0), source: "op:log", stage: "defined", note: "Log base must be positive."),
        mk-restriction(expr.base, "!=", num(1), source: "op:log", stage: "defined", note: "Log base cannot equal 1."),
        mk-restriction(expr.arg, ">", num(0), source: "op:log", stage: "defined", note: "Log argument must be positive."),
      ),
    )
  }

  if is-type(expr, "func") {
    let out = ()
    for a in func-args(expr) {
      out = merge-restrictions(out, _collect-structural(a))
    }
    return out
  }

  if is-type(expr, "sum") or is-type(expr, "prod") {
    return merge-restrictions(
      _collect-structural(expr.body),
      merge-restrictions(_collect-structural(expr.from), _collect-structural(expr.to)),
    )
  }

  if is-type(expr, "integral") { return _collect-structural(expr.expr) }

  if is-type(expr, "def-integral") {
    return merge-restrictions(
      _collect-structural(expr.expr),
      merge-restrictions(_collect-structural(expr.lo), _collect-structural(expr.hi)),
    )
  }

  if is-type(expr, "matrix") {
    let out = ()
    for row in expr.rows {
      for c in row {
        out = merge-restrictions(out, _collect-structural(c))
      }
    }
    return out
  }

  if is-type(expr, "piecewise") {
    let out = ()
    for case in expr.cases {
      out = merge-restrictions(out, _collect-structural(case.at(0)))
      let cond = case.at(1)
      if is-expr(cond) { out = merge-restrictions(out, _collect-structural(cond)) }
    }
    return out
  }

  if is-type(expr, "cond-rel") {
    return merge-restrictions(_collect-structural(expr.lhs), _collect-structural(expr.rhs))
  }
  if is-type(expr, "cond-and") {
    let out = ()
    for c in expr.args { out = merge-restrictions(out, _collect-structural(c)) }
    return out
  }

  if is-type(expr, "complex") {
    return merge-restrictions(_collect-structural(expr.re), _collect-structural(expr.im))
  }

  ()
}

#let collect-structural-restrictions(expr) = _collect-structural(expr)

#let _collect-function(expr, stage) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") { return () }

  if is-type(expr, "neg") { return _collect-function(expr.arg, stage) }

  if is-type(expr, "add") or is-type(expr, "mul") {
    return merge-restrictions(
      _collect-function(expr.args.at(0), stage),
      _collect-function(expr.args.at(1), stage),
    )
  }

  if is-type(expr, "pow") {
    return merge-restrictions(
      _collect-function(expr.base, stage),
      _collect-function(expr.exp, stage),
    )
  }

  if is-type(expr, "div") {
    return merge-restrictions(
      _collect-function(expr.num, stage),
      _collect-function(expr.den, stage),
    )
  }

  if is-type(expr, "log") {
    return merge-restrictions(
      _collect-function(expr.base, stage),
      _collect-function(expr.arg, stage),
    )
  }

  if is-type(expr, "func") {
    let out = ()
    for a in func-args(expr) {
      out = merge-restrictions(out, _collect-function(a, stage))
    }

    let spec = fn-spec(expr.name)
    let spec-restrictions = if spec == none { none } else { spec.at("restrictions", default: none) }
    if spec-restrictions != none {
      let emitter = spec-restrictions.at(stage, default: none)
      if emitter != none {
        let produced = emitter(func-args(expr))
        if produced != none {
          out = merge-restrictions(out, produced)
        }
      }
    }
    return out
  }

  if is-type(expr, "sum") or is-type(expr, "prod") {
    return merge-restrictions(
      _collect-function(expr.body, stage),
      merge-restrictions(_collect-function(expr.from, stage), _collect-function(expr.to, stage)),
    )
  }

  if is-type(expr, "integral") { return _collect-function(expr.expr, stage) }
  if is-type(expr, "def-integral") {
    return merge-restrictions(
      _collect-function(expr.expr, stage),
      merge-restrictions(_collect-function(expr.lo, stage), _collect-function(expr.hi, stage)),
    )
  }

  if is-type(expr, "matrix") {
    let out = ()
    for row in expr.rows {
      for c in row {
        out = merge-restrictions(out, _collect-function(c, stage))
      }
    }
    return out
  }

  if is-type(expr, "piecewise") {
    let out = ()
    for case in expr.cases {
      out = merge-restrictions(out, _collect-function(case.at(0), stage))
      let cond = case.at(1)
      if is-expr(cond) { out = merge-restrictions(out, _collect-function(cond, stage)) }
    }
    return out
  }

  if is-type(expr, "cond-rel") {
    return merge-restrictions(_collect-function(expr.lhs, stage), _collect-function(expr.rhs, stage))
  }
  if is-type(expr, "cond-and") {
    let out = ()
    for c in expr.args { out = merge-restrictions(out, _collect-function(c, stage)) }
    return out
  }

  if is-type(expr, "complex") {
    return merge-restrictions(_collect-function(expr.re, stage), _collect-function(expr.im, stage))
  }

  ()
}

#let collect-function-restrictions(expr, stage: "defined") = _collect-function(expr, stage)

// -------------------------------------------------------------------------
// Rendering
// -------------------------------------------------------------------------

#let _restriction-op(rel) = {
  if rel == "!=" { return sym.eq.not }
  rel
}

#let _restriction-math(r) = $ #cas-display(r.lhs) #h(0.25em) #_restriction-op(r.rel) #h(0.25em) #cas-display(r.rhs) $

#let render-restriction-note(r) = {
  let body = _restriction-math(r)
  if r.note == none or r.note == "" { return body }
  [#body #h(0.35em) #text(size: 0.84em, fill: luma(105))[#r.note]]
}

/// Build compact restriction panel data for diagnostics and trace rendering.
#let build-restriction-panel(expr, stage: "defined", assumptions: none) = {
  let restrictions = merge-restrictions(
    merge-restrictions(
      collect-structural-restrictions(expr),
      collect-function-restrictions(expr, stage: "defined"),
    ),
    collect-function-restrictions(expr, stage: stage),
  )
  let filtered = filter-restrictions-by-assumptions(restrictions, assumptions)

  let rows = ()
  for r in filtered.conflicts {
    rows.push((
      status: "conflict",
      lhs: r.lhs,
      rel: r.rel,
      rhs: r.rhs,
      source: r.source,
      stage: r.stage,
      note: r.note,
      math: _restriction-math(r),
    ))
  }
  for r in filtered.restrictions {
    rows.push((
      status: "active",
      lhs: r.lhs,
      rel: r.rel,
      rhs: r.rhs,
      source: r.source,
      stage: r.stage,
      note: r.note,
      math: _restriction-math(r),
    ))
  }
  for r in filtered.satisfied {
    rows.push((
      status: "satisfied",
      lhs: r.lhs,
      rel: r.rel,
      rhs: r.rhs,
      source: r.source,
      stage: r.stage,
      note: r.note,
      math: _restriction-math(r),
    ))
  }

  (
    rows: rows,
    counts: (
      active: filtered.restrictions.len(),
      satisfied: filtered.satisfied.len(),
      conflicts: filtered.conflicts.len(),
    ),
    restrictions: filtered.restrictions,
    satisfied: filtered.satisfied,
    conflicts: filtered.conflicts,
    residual: filtered.residual,
    variable-domains: filtered.variable-domains,
  )
}
