// =========================================================================
// typcas v2 Task-Centric Builder API
// =========================================================================

#import "../core/ast.typ": *
#import "../core/runtime.typ": cas-parse, cas-display, cas-equation, simplify, simplify-meta-core, expand as expand-expr, eval-expr, substitute, diff, diff-n, integrate, definite-integral, taylor, limit, implicit-diff, solve, solve-meta, factor, assume, assume-domain, assume-string, merge-assumptions, apply-assumptions, parse-domain, variable-domain, display-variable-domain, collect-structural-restrictions, collect-function-restrictions, merge-restrictions, filter-restrictions-by-assumptions, build-restriction-panel, step-diff, step-integrate, step-simplify, step-solve, display-steps, normalize-detail, detail-mode, resolve-detail-depth, mat-add, mat-sub, mat-scale, mat-mul, mat-transpose, mat-det, mat-inv, mat-solve, mat-eigenvalues, mat-eigenvectors, solve-linear-system, solve-nonlinear-system, poly-coeffs, coeffs-to-expr, poly-div, partial-fractions
#import "result.typ": mk-result, mk-error

#let _normalize-field(field) = if field == "complex" { "complex" } else { "real" }
#let _as-tuple(x) = if x == none { () } else { x }
#let _detail-error(op, field, strict, detail) = mk-result(
  op,
  field,
  strict,
  ok: false,
  errors: (mk-error("invalid-detail", "detail must be an integer in the range 0..4.", details: (detail: detail)),),
)

#let _resolve-detail(op, field, strict, detail, default) = {
  let d = normalize-detail(detail, default: default)
  if d == none {
    return (
      ok: false,
      error: _detail-error(op, field, strict, detail),
    )
  }
  (
    ok: true,
    detail: d,
    mode: detail-mode(d),
  )
}

#let _detail-diagnostics(base, detail, mode, resolved-depth, explicit-depth) = (
  ..base,
  detail: detail,
  detail-mode: mode,
  depth: resolved-depth,
  depth-override: explicit-depth != none,
  depth-ignored: detail == 0 and explicit-depth != none,
)

#let _with-assumptions(expr, assumptions) = {
  if assumptions == none { return expr }
  simplify(apply-assumptions(expr, assumptions))
}

#let _is-expr-node(x) = type(x) == dictionary and "type" in x

#let _is-inf-token(s) = {
  let t = s.trim()
  t == "inf" or t == "+inf" or t == "infinity" or t == "+infinity" or t == "∞" or t == "+∞"
}

#let _is-neg-inf-token(s) = {
  let t = s.trim()
  t == "-inf" or t == "-infinity" or t == "-∞"
}

#let _coerce-point(x) = {
  if type(x) == int or type(x) == float { return num(x) }
  if _is-expr-node(x) { return x }
  cas-parse(x)
}

#let _parse-limit-target(to) = {
  if type(to) == dictionary and to.at("type", default: none) == "limit-target" {
    return (
      type: "limit-target",
      point: to.at("point", default: num(0)),
      side: to.at("side", default: "two-sided"),
      infinity: to.at("infinity", default: 0),
    )
  }

  if type(to) == str {
    let t = to.trim()
    if _is-inf-token(t) {
      return (type: "limit-target", point: const-expr("inf"), side: "two-sided", infinity: 1)
    }
    if _is-neg-inf-token(t) {
      return (type: "limit-target", point: neg(const-expr("inf")), side: "two-sided", infinity: -1)
    }
    if t.len() >= 2 {
      let last = t.slice(t.len() - 1, t.len())
      if last == "+" or last == "-" {
        let core = t.slice(0, t.len() - 1).trim()
        if core != "" {
          return (
            type: "limit-target",
            point: _coerce-point(core),
            side: if last == "+" { "right" } else { "left" },
            infinity: 0,
          )
        }
      }
    }
    return (type: "limit-target", point: _coerce-point(t), side: "two-sided", infinity: 0)
  }

  if _is-expr-node(to) and (is-type(to, "var") or is-type(to, "const")) and (to.name == "inf" or to.name == "infinity") {
    return (type: "limit-target", point: const-expr("inf"), side: "two-sided", infinity: 1)
  }
  if is-type(to, "neg") and _is-expr-node(to.arg) and (is-type(to.arg, "var") or is-type(to.arg, "const")) and (to.arg.name == "inf" or to.arg.name == "infinity") {
    return (type: "limit-target", point: neg(const-expr("inf")), side: "two-sided", infinity: -1)
  }

  (type: "limit-target", point: _coerce-point(to), side: "two-sided", infinity: 0)
}

#let _nonsmooth-boundary-hits(expr, var) = {
  if not _is-expr-node(expr) { return () }

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
    return out + _nonsmooth-boundary-hits(expr.arg, var)
  }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return out + _nonsmooth-boundary-hits(expr.args.at(0), var) + _nonsmooth-boundary-hits(expr.args.at(1), var)
  }
  if is-type(expr, "pow") {
    return out + _nonsmooth-boundary-hits(expr.base, var) + _nonsmooth-boundary-hits(expr.exp, var)
  }
  if is-type(expr, "div") {
    return out + _nonsmooth-boundary-hits(expr.num, var) + _nonsmooth-boundary-hits(expr.den, var)
  }
  if is-type(expr, "func") {
    let all = out
    for a in func-args(expr) { all += _nonsmooth-boundary-hits(a, var) }
    return all
  }
  if is-type(expr, "log") {
    return out + _nonsmooth-boundary-hits(expr.base, var) + _nonsmooth-boundary-hits(expr.arg, var)
  }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    return out + _nonsmooth-boundary-hits(expr.body, var) + _nonsmooth-boundary-hits(expr.from, var) + _nonsmooth-boundary-hits(expr.to, var)
  }
  if is-type(expr, "integral") {
    return out + _nonsmooth-boundary-hits(expr.expr, var)
  }
  if is-type(expr, "def-integral") {
    return out + _nonsmooth-boundary-hits(expr.expr, var) + _nonsmooth-boundary-hits(expr.lo, var) + _nonsmooth-boundary-hits(expr.hi, var)
  }
  if is-type(expr, "matrix") {
    let all = out
    for row in expr.rows {
      for item in row { all += _nonsmooth-boundary-hits(item, var) }
    }
    return all
  }
  if is-type(expr, "piecewise") {
    let all = out
    for c in expr.cases {
      all += _nonsmooth-boundary-hits(c.at(0), var)
      let cond = c.at(1)
      if _is-expr-node(cond) { all += _nonsmooth-boundary-hits(cond, var) }
    }
    return all
  }
  if is-type(expr, "cond-rel") {
    return out + _nonsmooth-boundary-hits(expr.lhs, var) + _nonsmooth-boundary-hits(expr.rhs, var)
  }
  if is-type(expr, "cond-and") {
    let all = out
    for c in expr.args { all += _nonsmooth-boundary-hits(c, var) }
    return all
  }
  if is-type(expr, "complex") {
    return out + _nonsmooth-boundary-hits(expr.re, var) + _nonsmooth-boundary-hits(expr.im, var)
  }

  out
}

#let _nonsmooth-boundary-warnings(expr, var) = {
  let hits = _nonsmooth-boundary-hits(expr, var)
  if hits.len() == 0 { return () }
  let out = ()
  let seen = (:)
  for h in hits {
    let key = h.fn + ":" + repr(h.expr)
    if key in seen { continue }
    seen.insert(key, true)
    out.push(mk-error(
      "nonsmooth-boundary",
      "Derivative includes symbolic fallback at a non-smooth boundary.",
      details: (function: h.fn, boundary: repr(h.expr)),
    ))
  }
  out
}

#let _raw-restrictions(src, stage) = {
  if not _is-expr-node(src) { return () }
  merge-restrictions(
    merge-restrictions(
      collect-structural-restrictions(src),
      collect-function-restrictions(src, stage: "defined"),
    ),
    collect-function-restrictions(src, stage: stage),
  )
}

#let _meta-restrictions(src, stage, assumptions) = {
  let restrictions = _raw-restrictions(src, stage)
  filter-restrictions-by-assumptions(restrictions, assumptions)
}

#let _meta-restrictions-many(sources, stage, assumptions) = {
  let merged = ()
  for src in sources {
    merged = merge-restrictions(merged, _raw-restrictions(src, stage))
  }
  filter-restrictions-by-assumptions(merged, assumptions)
}

#let _strict-domain-guard(op, field, strict, meta, expr: none, value: none, roots: none, steps: none, warnings: (), diagnostics: (:)) = {
  if strict and meta.conflicts.len() > 0 {
    return mk-result(
      op,
      field,
      strict,
      ok: false,
      expr: none,
      value: none,
      roots: none,
      steps: none,
      restrictions: meta.restrictions,
      satisfied: meta.satisfied,
      conflicts: meta.conflicts,
      residual: meta.residual,
      variable-domains: meta.variable-domains,
      warnings: warnings,
      errors: (mk-error("domain-conflict", "Domain restrictions conflict with current assumptions.", details: meta.conflicts),),
      diagnostics: diagnostics,
    )
  }

  mk-result(
    op,
    field,
    strict,
    ok: true,
    expr: expr,
    value: value,
    roots: roots,
    steps: steps,
    restrictions: meta.restrictions,
    satisfied: meta.satisfied,
    conflicts: meta.conflicts,
    residual: meta.residual,
    variable-domains: meta.variable-domains,
    warnings: warnings,
    diagnostics: diagnostics,
  )
}

#let _normalize-linear-system-equations(equations) = {
  let out = ()
  for eq in equations {
    if type(eq) == array and eq.len() == 2 {
      out.push((cas-parse(eq.at(0)), cas-parse(eq.at(1))))
    } else {
      out.push((cas-parse(eq), num(0)))
    }
  }
  out
}

#let _query(input, assumptions: none, field: "real", strict: true) = {
  let field = _normalize-field(field)
  let _panel = (src, stage) => build-restriction-panel(src, stage: stage, assumptions: assumptions)

  let parse = () => cas-parse(input)
  let _no-expr-chain = op => mk-result(
    op,
    field,
    strict,
    ok: false,
    errors: (mk-error("no-expr-chain", "This result has no expression to continue chaining."),),
  )
  let chainify = res => {
    let src = res.expr
    if src == none {
      return (
        ..res,
        as-query: () => none,
        simplify: (expand: false, allow-domain-sensitive: false, detail: 0, depth: none) => _no-expr-chain("simplify"),
        diff: (var, order: 1, detail: 0, depth: none) => _no-expr-chain("diff"),
        integrate: (var, definite: none, detail: 0, depth: none) => _no-expr-chain("integrate"),
        implicit-diff: (x, y) => _no-expr-chain("implicit-diff"),
        solve: (rhs: 0, var: "x", detail: 0, depth: none) => _no-expr-chain("solve"),
        factor: var => _no-expr-chain("factor"),
        limit: (var, to) => _no-expr-chain("limit"),
        taylor: (var, x0, order) => _no-expr-chain("taylor"),
        eval: (bindings: (:)) => _no-expr-chain("eval"),
        substitute: (var, repl) => _no-expr-chain("substitute"),
        trace: (op, var: "x", rhs: 0, depth: none, detail: 2) => _no-expr-chain("trace"),
        domain: var => _no-expr-chain("domain"),
      )
    }
    let next = _query(src, assumptions: assumptions, field: field, strict: strict)
    (
      ..res,
      as-query: () => next,
      with: (assumptions: assumptions, field: field, strict: strict) => _query(
        src,
        assumptions: assumptions,
        field: field,
        strict: strict,
      ),
      parsed: () => (next.parsed)(),
      domain: var => (next.domain)(var),
      simplify: (expand: false, allow-domain-sensitive: false, detail: 0, depth: none) => (next.simplify)(
        expand: expand,
        allow-domain-sensitive: allow-domain-sensitive,
        detail: detail,
        depth: depth,
      ),
      diff: (var, order: 1, detail: 0, depth: none) => (next.diff)(var, order: order, detail: detail, depth: depth),
      integrate: (var, definite: none, detail: 0, depth: none) => (next.integrate)(var, definite: definite, detail: detail, depth: depth),
      implicit-diff: (x, y) => (next.implicit-diff)(x, y),
      solve: (rhs: 0, var: "x", detail: 0, depth: none) => (next.solve)(rhs: rhs, var: var, detail: detail, depth: depth),
      factor: var => (next.factor)(var),
      limit: (var, to) => (next.limit)(var, to),
      taylor: (var, x0, order) => (next.taylor)(var, x0, order),
      eval: (bindings: (:)) => (next.eval)(bindings: bindings),
      substitute: (var, repl) => (next.substitute)(var, repl),
      trace: (op, var: "x", rhs: 0, depth: none, detail: 2) => (next.trace)(
        op,
        var: var,
        rhs: rhs,
        depth: depth,
        detail: detail,
      ),
    )
  }

  (
    input: input,
    assumptions: assumptions,
    field: field,
    strict: strict,

    with: (assumptions: assumptions, field: field, strict: strict) => _query(
      input,
      assumptions: assumptions,
      field: field,
      strict: strict,
    ),

    parsed: () => {
      let e = parse()
      chainify(mk-result("parse", field, strict, expr: e))
    },

    render: (expr: none) => {
      let e = if expr == none { parse() } else { cas-parse(expr) }
      cas-display(e)
    },

    domain: var => {
      if type(var) != str {
        return chainify(mk-result("domain", field, strict, ok: false, errors: (mk-error("invalid-var", "Domain variable must be a string."),)))
      }
      let dom = variable-domain(var, assumptions: assumptions)
      let shown = display-variable-domain(var, assumptions: assumptions)
      chainify(mk-result("domain", field, strict, value: shown, diagnostics: (var: var, domain: dom)))
    },

    simplify: (expand: false, allow-domain-sensitive: false, detail: 0, depth: none) => {
      let detail-info = _resolve-detail("simplify", field, strict, detail, 0)
      if not detail-info.ok { return chainify(detail-info.error) }
      let d = detail-info.detail
      let used-depth = if d == 0 { none } else { resolve-detail-depth(d, depth: depth) }

      let src = parse()
      let do-expand = expand
      let work = if do-expand { (expand-expr)(src) } else { src }
      let meta = simplify-meta-core(work, allow-domain-sensitive: allow-domain-sensitive, assumptions: assumptions)
      let out = _with-assumptions(meta.expr, assumptions)
      let base = _strict-domain-guard(
        "simplify",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (
          expanded: expand,
          domain-sensitive: allow-domain-sensitive,
          identity-events: meta.identities-used,
          identity-count: meta.identity-count,
          identity-unique: meta.identity-unique,
          restriction-panel: _panel(work, "defined"),
        ),
      )
      if not base.ok { return chainify(base) }

      let steps = if d > 0 {
        step-simplify(work, depth: used-depth, assumptions: assumptions, detail: d)
      } else {
        none
      }
      chainify((
        ..base,
        steps: steps,
        diagnostics: _detail-diagnostics(base.diagnostics, d, detail-info.mode, used-depth, depth),
      ))
    },

    diff: (var, order: 1, detail: 0, depth: none) => {
      if type(var) != str {
        return chainify(mk-result("diff", field, strict, ok: false, errors: (mk-error("invalid-var", "Differentiation variable must be a string."),)))
      }
      let detail-info = _resolve-detail("diff", field, strict, detail, 0)
      if not detail-info.ok { return chainify(detail-info.error) }
      let d = detail-info.detail
      let used-depth = if d == 0 { none } else { resolve-detail-depth(d, depth: depth) }

      let src = _with-assumptions(parse(), assumptions)
      let raw = if order <= 1 { diff(src, var) } else { diff-n(src, var, order) }
      let out = _with-assumptions(raw, assumptions)
      let meta = _meta-restrictions(src, "diff", assumptions)
      let ns-warnings = _nonsmooth-boundary-warnings(out, var)
      let base = _strict-domain-guard(
        "diff",
        field,
        strict,
        meta,
        expr: out,
        warnings: ns-warnings,
        diagnostics: (
          var: var,
          order: order,
          restriction-panel: _panel(src, "diff"),
        ),
      )
      if not base.ok { return chainify(base) }

      let steps = if d > 0 {
        step-diff(src, var, depth: used-depth, assumptions: none, detail: d)
      } else {
        none
      }
      chainify((
        ..base,
        steps: steps,
        diagnostics: _detail-diagnostics(base.diagnostics, d, detail-info.mode, used-depth, depth),
      ))
    },

    integrate: (var, definite: none, detail: 0, depth: none) => {
      if type(var) != str {
        return chainify(mk-result("integrate", field, strict, ok: false, errors: (mk-error("invalid-var", "Integration variable must be a string."),)))
      }
      let detail-info = _resolve-detail("integrate", field, strict, detail, 0)
      if not detail-info.ok { return chainify(detail-info.error) }
      let d = detail-info.detail
      let used-depth = if d == 0 { none } else { resolve-detail-depth(d, depth: depth) }

      let src = _with-assumptions(parse(), assumptions)
      let raw = if definite == none {
        integrate(src, var)
      } else {
        definite-integral(src, var, definite.at(0), definite.at(1))
      }
      let out = _with-assumptions(raw, assumptions)
      let meta = _meta-restrictions(src, "integ", assumptions)
      let base = _strict-domain-guard(
        "integrate",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (
          var: var,
          definite: definite,
          restriction-panel: _panel(src, "integ"),
        ),
      )
      if not base.ok { return chainify(base) }

      let steps = if d > 0 and definite == none {
        step-integrate(src, var, depth: used-depth, assumptions: none, detail: d)
      } else {
        none
      }
      chainify((
        ..base,
        steps: steps,
        diagnostics: _detail-diagnostics(base.diagnostics, d, detail-info.mode, used-depth, depth),
      ))
    },

    implicit-diff: (x, y) => {
      if type(x) != str or type(y) != str {
        return chainify(mk-result(
          "implicit-diff",
          field,
          strict,
          ok: false,
          errors: (mk-error("invalid-var", "Implicit differentiation variables must be strings."),),
        ))
      }
      let src = _with-assumptions(parse(), assumptions)
      let raw = implicit-diff(src, x, y)
      let out = _with-assumptions(raw, assumptions)
      let meta = _meta-restrictions(src, "diff", assumptions)
      chainify(_strict-domain-guard(
        "implicit-diff",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (
          x: x,
          y: y,
          restriction-panel: _panel(src, "diff"),
        ),
      ))
    },

    solve: (rhs: 0, var: "x", detail: 0, depth: none) => {
      if type(var) != str {
        return chainify(mk-result("solve", field, strict, ok: false, errors: (mk-error("invalid-var", "Solve variable must be a string."),)))
      }
      let detail-info = _resolve-detail("solve", field, strict, detail, 0)
      if not detail-info.ok { return chainify(detail-info.error) }
      let d = detail-info.detail
      let used-depth = if d == 0 { none } else { resolve-detail-depth(d, depth: depth) }

      let lhs = parse()
      let meta-solve = solve-meta(lhs, cas-parse(rhs), var)
      let roots = if meta-solve == none { () } else { meta-solve.at("roots", default: ()) }
      let exprs = solve(lhs, cas-parse(rhs), var)
      let meta = _meta-restrictions(lhs, "defined", assumptions)
      let base = _strict-domain-guard(
        "solve",
        field,
        strict,
        meta,
        expr: none,
        roots: roots,
        diagnostics: (
          var: var,
          rhs: cas-parse(rhs),
          solutions: exprs,
          solve-meta: meta-solve,
          restriction-panel: _panel(lhs, "defined"),
        ),
      )
      if not base.ok { return chainify(base) }

      let steps = if d > 0 {
        step-solve(lhs, cas-parse(rhs), var, depth: used-depth, detail: d)
      } else {
        none
      }
      chainify((
        ..base,
        steps: steps,
        diagnostics: _detail-diagnostics(base.diagnostics, d, detail-info.mode, used-depth, depth),
      ))
    },

    factor: (var) => {
      if type(var) != str {
        return chainify(mk-result("factor", field, strict, ok: false, errors: (mk-error("invalid-var", "Factor variable must be a string."),)))
      }
      let src = parse()
      let out = factor(src, var)
      let meta = _meta-restrictions(src, "defined", assumptions)
      chainify(_strict-domain-guard(
        "factor",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (var: var, restriction-panel: _panel(src, "defined")),
      ))
    },

    limit: (var, to) => {
      if type(var) != str {
        return chainify(mk-result("limit", field, strict, ok: false, errors: (mk-error("invalid-var", "Limit variable must be a string."),)))
      }
      let src = parse()
      let target = _parse-limit-target(to)
      let out = limit(src, var, target)
      let meta = _meta-restrictions(src, "defined", assumptions)
      chainify(_strict-domain-guard(
        "limit",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (
          var: var,
          to: target.point,
          side: target.side,
          infinity: target.infinity,
          restriction-panel: _panel(src, "defined"),
        ),
      ))
    },

    taylor: (var, x0, order) => {
      if type(var) != str {
        return chainify(mk-result("taylor", field, strict, ok: false, errors: (mk-error("invalid-var", "Taylor variable must be a string."),)))
      }
      let src = parse()
      let out = taylor(src, var, cas-parse(x0), order)
      let meta = _meta-restrictions(src, "defined", assumptions)
      chainify(_strict-domain-guard(
        "taylor",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (var: var, x0: cas-parse(x0), order: order, restriction-panel: _panel(src, "defined")),
      ))
    },

    eval: (bindings: (:)) => {
      let src = parse()
      let value = eval-expr(src, bindings)
      let meta = _meta-restrictions(src, "defined", assumptions)
      chainify(_strict-domain-guard(
        "eval",
        field,
        strict,
        meta,
        value: value,
        diagnostics: (bindings: bindings, restriction-panel: _panel(src, "defined")),
      ))
    },

    substitute: (var, repl) => {
      if type(var) != str {
        return chainify(mk-result("substitute", field, strict, ok: false, errors: (mk-error("invalid-var", "Substitution variable must be a string."),)))
      }
      let src = parse()
      let out = substitute(src, var, cas-parse(repl))
      let meta = _meta-restrictions(src, "defined", assumptions)
      chainify(_strict-domain-guard(
        "substitute",
        field,
        strict,
        meta,
        expr: out,
        diagnostics: (var: var, restriction-panel: _panel(src, "defined")),
      ))
    },

    trace: (op, var: "x", rhs: 0, depth: none, detail: 2) => {
      let detail-info = _resolve-detail("trace", field, strict, detail, 2)
      if not detail-info.ok { return chainify(detail-info.error) }
      let d = detail-info.detail
      let used-depth = if d == 0 { none } else { resolve-detail-depth(d, depth: depth) }

      let src = parse()
      let valid-op = op == "simplify" or op == "diff" or op == "integrate" or op == "solve"
      if not valid-op {
        return chainify(mk-result(
          "trace",
          field,
          strict,
          ok: false,
          errors: (mk-error("invalid-op", "trace(op, ...) expects one of: simplify, diff, integrate, solve."),),
        ))
      }
      if d == 0 {
        return chainify(mk-result(
          "trace",
          field,
          strict,
          steps: (),
          diagnostics: _detail-diagnostics((op: op), d, detail-info.mode, used-depth, depth),
          expr: none,
        ))
      }
      if op == "simplify" {
        let steps = step-simplify(src, depth: used-depth, assumptions: assumptions, detail: d)
        return chainify(mk-result("trace", field, strict, steps: steps, diagnostics: _detail-diagnostics((op: op), d, detail-info.mode, used-depth, depth), expr: none))
      }
      if op == "diff" {
        let steps = step-diff(src, var, depth: used-depth, assumptions: assumptions, detail: d)
        return chainify(mk-result("trace", field, strict, steps: steps, diagnostics: _detail-diagnostics((op: op, var: var), d, detail-info.mode, used-depth, depth), expr: none))
      }
      if op == "integrate" {
        let steps = step-integrate(src, var, depth: used-depth, assumptions: assumptions, detail: d)
        return chainify(mk-result("trace", field, strict, steps: steps, diagnostics: _detail-diagnostics((op: op, var: var), d, detail-info.mode, used-depth, depth), expr: none))
      }
      if op == "solve" {
        let steps = step-solve(src, cas-parse(rhs), var, depth: used-depth, detail: d)
        return chainify(mk-result("trace", field, strict, steps: steps, diagnostics: _detail-diagnostics((op: op, var: var, rhs: cas-parse(rhs)), d, detail-info.mode, used-depth, depth), expr: none))
      }
      chainify(mk-result(
        "trace",
        field,
        strict,
        ok: false,
        errors: (mk-error("invalid-op", "trace(op, ...) expects one of: simplify, diff, integrate, solve."),),
      ))
    },

    render-steps: (steps, operation: none, var: none, rhs: none) => display-steps(input, steps, operation: operation, var: var, rhs: rhs),

    // Extended operation helpers (kept task-centric and structured)
    matrix: (
      add: (a, b) => {
        let aa = cas-parse(a)
        let bb = cas-parse(b)
        let out = mat-add(aa, bb)
        let meta = _meta-restrictions-many((aa, bb), "defined", assumptions)
        _strict-domain-guard("matrix.add", field, strict, meta, expr: out)
      },
      sub: (a, b) => {
        let aa = cas-parse(a)
        let bb = cas-parse(b)
        let out = mat-sub(aa, bb)
        let meta = _meta-restrictions-many((aa, bb), "defined", assumptions)
        _strict-domain-guard("matrix.sub", field, strict, meta, expr: out)
      },
      scale: (c, m) => {
        let cc = cas-parse(c)
        let mm = cas-parse(m)
        let out = mat-scale(cc, mm)
        let meta = _meta-restrictions-many((cc, mm), "defined", assumptions)
        _strict-domain-guard("matrix.scale", field, strict, meta, expr: out)
      },
      mul: (a, b) => {
        let aa = cas-parse(a)
        let bb = cas-parse(b)
        let out = mat-mul(aa, bb)
        let meta = _meta-restrictions-many((aa, bb), "defined", assumptions)
        _strict-domain-guard("matrix.mul", field, strict, meta, expr: out)
      },
      transpose: m => {
        let mm = cas-parse(m)
        let out = mat-transpose(mm)
        let meta = _meta-restrictions(mm, "defined", assumptions)
        _strict-domain-guard("matrix.transpose", field, strict, meta, expr: out)
      },
      det: m => {
        let mm = cas-parse(m)
        let out = mat-det(mm)
        let meta = _meta-restrictions(mm, "defined", assumptions)
        _strict-domain-guard("matrix.det", field, strict, meta, expr: out)
      },
      inv: m => {
        let mm = cas-parse(m)
        let out = mat-inv(mm)
        let meta = _meta-restrictions-many((mm,), "defined", assumptions)
        _strict-domain-guard("matrix.inv", field, strict, meta, expr: out)
      },
      solve: (a, b) => {
        let aa = cas-parse(a)
        let bb = b.map(cas-parse)
        let out = mat-solve(aa, bb)
        let sources = (aa,) + bb
        for s in out { sources.push(s) }
        let meta = _meta-restrictions-many(sources, "defined", assumptions)
        _strict-domain-guard("matrix.solve", field, strict, meta, expr: out)
      },
      eigenvalues: m => {
        let mm = cas-parse(m)
        let out = mat-eigenvalues(mm)
        let sources = (mm,) + out
        let meta = _meta-restrictions-many(sources, "defined", assumptions)
        _strict-domain-guard("matrix.eigenvalues", field, strict, meta, value: out)
      },
      eigenvectors: m => {
        let mm = cas-parse(m)
        let out = mat-eigenvectors(mm)
        let sources = (mm,)
        for pair in out {
          if type(pair) == array and pair.len() == 2 {
            sources.push(pair.at(0))
            let vec = pair.at(1)
            if type(vec) == array {
              for c in vec { sources.push(c) }
            }
          }
        }
        let meta = _meta-restrictions-many(sources, "defined", assumptions)
        _strict-domain-guard("matrix.eigenvectors", field, strict, meta, value: out)
      },
    ),

    systems: (
      linear: (equations, vars) => {
        let eqs = _normalize-linear-system-equations(equations)
        let out = solve-linear-system(eqs, vars)
        let sources = ()
        for eq in eqs {
          if type(eq) == array and eq.len() == 2 {
            sources.push(sub(eq.at(0), eq.at(1)))
          }
        }
        let meta = _meta-restrictions-many(sources, "defined", assumptions)
        _strict-domain-guard("systems.linear", field, strict, meta, value: out)
      },
      nonlinear: (equations, vars, initial, max-iters: 40, tol: 1e-10) => {
        let eqs = equations.map(cas-parse)
        let out = solve-nonlinear-system(eqs, vars, initial, max-iters: max-iters, tol: tol)
        let meta = _meta-restrictions-many(eqs, "defined", assumptions)
        _strict-domain-guard("systems.nonlinear", field, strict, meta, value: out)
      },
    ),

    poly: (
      coeffs: (expr, var) => {
        let src = cas-parse(expr)
        let meta = _meta-restrictions(src, "defined", assumptions)
        let out = poly-coeffs(src, var)
        _strict-domain-guard(
          "poly.coeffs",
          field,
          strict,
          meta,
          value: out,
          diagnostics: (var: var),
        )
      },
      from-coeffs: (coeffs, var) => {
        let out = coeffs-to-expr(coeffs, var)
        let meta = _meta-restrictions(out, "defined", assumptions)
        _strict-domain-guard(
          "poly.from-coeffs",
          field,
          strict,
          meta,
          expr: out,
          diagnostics: (var: var),
        )
      },
      div: (p, d, var) => {
        let pp = cas-parse(p)
        let dd = cas-parse(d)
        // Carry rational-domain restriction from formal P(x)/D(x): D(x) != 0.
        let meta = _meta-restrictions(cdiv(pp, dd), "defined", assumptions)
        let out = poly-div(pp, dd, var)
        _strict-domain-guard(
          "poly.div",
          field,
          strict,
          meta,
          value: out,
          diagnostics: (var: var),
        )
      },
      partial-fractions: (expr, var) => {
        let src = cas-parse(expr)
        let out = partial-fractions(src, var)
        let meta = _meta-restrictions(src, "defined", assumptions)
        _strict-domain-guard(
          "poly.partial-fractions",
          field,
          strict,
          meta,
          expr: out,
          diagnostics: (var: var),
        )
      },
    ),
  )
}

#let make-query(input, assumptions: none, field: "real", strict: true) = _query(
  input,
  assumptions: assumptions,
  field: field,
  strict: strict,
)
