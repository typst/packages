// =========================================================================
// CAS Steps Trace Engine
// =========================================================================
// Tracing logic for diff/integrate/simplify/solve step-by-step output.
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../calculus.typ": diff, integrate
#import "../display.typ": cas-display
#import "../solve.typ": solve as _solve-fn, solve-meta as _solve-meta-fn
#import "../truths/calculus-rules.typ": calc-rules
#import "../truths/function-registry.typ": fn-square-power-integral-spec
#import "../helpers.typ": check-free-var as _check-free-var
#import "../core/int-math.typ": int-factors as _int-factors
#import "../core/expr-walk.typ": contains-var as _contains-var-core, expr-complexity as _expr-complexity-core
#import "../poly.typ": poly-coeffs, partial-fractions as _partial-fractions
#import "model.typ": _s-header, _s-note, _s-define, _s-apply
#import "render.typ": display-steps

// =========================================================================
// 3. HELPERS
// =========================================================================

/// Return whether `expr` contains variable `v`.
#let _contains-var(expr, v) = _contains-var-core(expr, v)

/// Heuristic structural complexity score for deciding whether a simplify
/// transition is worth showing as an explicit step.
#let _expr-complexity(expr) = _expr-complexity-core(expr)

/// Keep only simplify steps that make progress or keep parity on complexity.
#let _is-helpful-simplify(before, after) = {
  if expr-eq(before, after) { return false }
  let before-score = _expr-complexity(before)
  let after-score = _expr-complexity(after)
  if after-score < before-score { return true }
  if after-score > before-score { return false }
  true
}

/// Check whether numeric polynomial coefficients are effectively integers.
#let _coeffs-intish(coeffs) = {
  for c in coeffs {
    if calc.abs(c - calc.round(c)) > 1e-10 { return false }
  }
  true
}

/// Evaluate polynomial coefficients with Horner's method.
#let _poly-eval-coeffs(coeffs, x) = {
  let y = 0
  let i = coeffs.len() - 1
  while i >= 0 {
    y = y * x + coeffs.at(i)
    i -= 1
  }
  y
}

/// Enumerate Rational Root Theorem candidates `p/q`.
#let _candidate-rational-roots(coeffs) = {
  let deg = coeffs.len() - 1
  if deg < 1 { return () }

  let a0 = int(calc.round(coeffs.at(0)))
  let an = int(calc.round(coeffs.at(deg)))
  if an == 0 { return () }

  let p-factors = _int-factors(if a0 == 0 { 1 } else { a0 })
  let q-factors = _int-factors(an)
  let candidates = ()

  for p in p-factors {
    for q in q-factors {
      let g = calc.gcd(p, q)
      let pn = int(p / g)
      let qn = int(q / g)
      let pos = (pn, qn)
      let neg = (-pn, qn)
      if pos not in candidates { candidates.push(pos) }
      if neg not in candidates { candidates.push(neg) }
    }
  }

  candidates
}

/// Render a rational candidate `(p, q)` as text.
#let _cand-text(p, q) = {
  if q == 1 { str(p) } else { str(p) + "/" + str(q) }
}

/// Compact candidate-list formatter for step notes.
#let _format-candidate-list(candidates, limit: 14) = {
  if candidates.len() == 0 { return "none" }
  let shown = ()
  let n = calc.min(candidates.len(), limit)
  for i in range(n) {
    let (p, q) = candidates.at(i)
    shown.push(_cand-text(p, q))
  }
  if candidates.len() > limit {
    shown.push("...")
  }
  shown.join(", ")
}

/// Detect whether any solution is approximate (non-integer numeric literal).
#let _has-approx-solutions(solutions) = {
  for s in solutions {
    if is-type(s, "num") and calc.abs(s.val - calc.round(s.val)) > 1e-8 {
      return true
    }
  }
  false
}

/// Wrap each step expression with a context function.
/// Example: expand inner derivative steps into `c * ( ... )`.
#let _wrap-steps(steps, wrapper) = {
  steps.map(s => {
    if s.kind == "header" {
      let new-expr = wrapper(s.expr)
      return _s-header(new-expr, s.rule)
    }
    if s.kind == "note" and s.expr != none {
      let new-expr = wrapper(s.expr)
      return _s-note(s.text, expr: new-expr)
    }
    s
  })
}

/// Symbolic derivative placeholder `d(arg)/d(var)` used in displayed rules.
#let _v-diff(arg, var) = func("diff_" + var, arg)
/// Symbolic integral placeholder `∫ arg dvar` used in displayed rules.
#let _v-int(arg, var) = (type: "integral", expr: arg, var: var)
/// Left-hand side label for derivative apply rows.
#let _lhs-diff-name(name) = $#cas-display(cvar(name)) '$
/// Left-hand side label for integral apply rows.
#let _lhs-int-name(name, var) = $integral #cas-display(cvar(name)) thin #math.italic("d" + var)$

/// Flatten nested binary add nodes into a flat list of terms.
/// add(add(a, b), c) → (a, b, c)
#let _flatten-add(expr) = {
  if not is-type(expr, "add") { return (expr,) }
  let result = ()
  result += _flatten-add(expr.args.at(0))
  result += _flatten-add(expr.args.at(1))
  result
}

/// Whether an inner expression is simple enough to inline directly in
/// chain-rule / u-sub explanations without introducing a named placeholder.
#let _is-trivial-inner(expr, var) = {
  if is-type(expr, "num") or is-type(expr, "const") or is-type(expr, "var") { return true }

  // -x
  if is-type(expr, "neg") and is-type(expr.arg, "var") { return true }

  // x^n
  if is-type(expr, "pow") and is-type(expr.base, "var") and expr.base.name == var and is-type(expr.exp, "num") {
    return true
  }

  // c * x
  if (
    is-type(expr, "mul")
      and is-type(expr.args.at(0), "num")
      and is-type(expr.args.at(1), "var")
      and expr.args.at(1).name == var
  ) { return true }

  // x + c or c + x
  if is-type(expr, "add") {
    let (a, b) = (expr.args.at(0), expr.args.at(1))
    let a-simple = (
      (is-type(a, "var") and a.name == var)
        or (
          is-type(a, "mul")
            and is-type(a.args.at(0), "num")
            and is-type(a.args.at(1), "var")
            and a.args.at(1).name == var
        )
    )
    let b-simple = (
      (is-type(b, "var") and b.name == var)
        or (
          is-type(b, "mul")
            and is-type(b.args.at(0), "num")
            and is-type(b.args.at(1), "var")
            and b.args.at(1).name == var
        )
    )
    let a-const = not _contains-var(a, var)
    let b-const = not _contains-var(b, var)

    // x + c
    if a-simple and b-const { return true }
    // c + x
    if a-const and b-simple { return true }
  }

  // sin(x)
  if is-type(expr, "func") and func-arity(expr) == 1 and is-type(func-args(expr).at(0), "var") and func-args(expr).at(0).name == var { return true }

  false
}

// =========================================================================
// 4. TRACERS (Recursive Logic)
// =========================================================================

// --- Differentiation Tracer ---

/// Allocate a temporary placeholder symbol (`u`, `v`, ...) not present in
/// `used`, and return `(name, updated-used)`.
#let _alloc-name(used) = {
  let candidates = ("u", "v", "w", "z", "p", "q", "h", "k", "a", "b", "c", "s", "t")
  let found = none
  for c in candidates {
    if c not in used {
      found = c
      break
    }
  }
  // Fallback if all letters used
  if found == none {
    let i = 1
    while true {
      let name = "u_" + str(i)
      if name not in used {
        found = name
        break
      }
      i = i + 1
    }
  }
  (found, used + (found,))
}

/// Recursive differentiation tracer.
/// Returns `(result-expr, step-list, used-var-names)`.
#let _trace-diff(expr, var, depth, used_vars) = {
  // --- Base Cases ---
  if is-type(expr, "num") or is-type(expr, "const") {
    return (num(0), (_s-note("Constant rule", expr: num(0)),), used_vars)
  }
  if is-type(expr, "var") {
    if expr.name == var {
      return (num(1), (_s-note("Power rule (x¹ -> 1)", expr: num(1)),), used_vars)
    } else {
      return (num(0), (_s-note("Constant (variable)", expr: num(0)),), used_vars)
    }
  }

  // --- Recursive Rules ---

  // Sum Rule (n-ary: flatten nested adds, split all at once)
  if is-type(expr, "add") {
    // Flatten nested add tree into a list of terms
    let terms = _flatten-add(expr)

    // Differentiate each term
    let derivs = ()
    let all-steps = ()
    let current_uv = used_vars
    for t in terms {
      let (dt, dsteps, uv1) = _trace-diff(t, var, depth + 1, current_uv)
      current_uv = uv1
      derivs.push(dt)
      all-steps.push(dsteps)
    }

    // Build raw result: sum of all derivatives
    let raw_res = derivs.at(0)
    for i in range(1, derivs.len()) {
      raw_res = add(raw_res, derivs.at(i))
    }
    let res = simplify(raw_res)
    let steps = ()

    // Allocate names for all terms up front
    let term-names = ()
    for t in terms {
      let (t-name, next_uv) = _alloc-name(current_uv)
      current_uv = next_uv
      term-names.push(t-name)
    }

    // Build symbolic header: d/dx(u+v+w) = u' + v' + w'
    let lhs-sum = cvar(term-names.at(0))
    for i in range(1, term-names.len()) {
      lhs-sum = add(lhs-sum, cvar(term-names.at(i)))
    }
    let rhs-parts = term-names.map(n => _v-diff(cvar(n), var))
    let rhs-sum = rhs-parts.at(0)
    for i in range(1, rhs-parts.len()) {
      rhs-sum = add(rhs-sum, rhs-parts.at(i))
    }

    steps.push(_s-header(_v-diff(lhs-sum, var), "Sum rule"))

    // Define each term
    for (i, t) in terms.enumerate() {
      steps.push(_s-define(term-names.at(i), t))
    }

    // Show: = u' + v' + w'
    steps.push(_s-header(rhs-sum, "Differentiate each term"))

    // Show derivative of each term
    for (i, t) in terms.enumerate() {
      let dsteps = all-steps.at(i)
      let dt = derivs.at(i)
      let name = term-names.at(i)
      // Extract rule name from sub-steps
      let rule-text = {
        let primary = dsteps.find(s => {
          let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
          let label = s.at("rule", default: s.at("text", default: ""))
          is-step and label != "Simplify"
        })
        if primary != none {
          if primary.kind == "header" { primary.rule } else { primary.text }
        } else if dsteps.len() > 0 {
          let s = dsteps.at(0)
          if s.kind == "header" { s.rule } else if s.kind == "note" { s.text } else { "Differentiate" }
        } else { "Differentiate" }
      }
      let complex = dsteps.len() > 2
      if complex {
        steps.push(_s-apply(_lhs-diff-name(name), dt, "Differentiate " + name, sub-steps: dsteps))
      } else {
        steps.push(_s-apply(_lhs-diff-name(name), dt, rule-text))
      }
    }

    // Substitute derivatives (show simplified form directly)
    steps.push(_s-header(res, "Substitute derivatives"))

    return (res, steps, current_uv)
  }

  // Negation
  if is-type(expr, "neg") {
    let (du, steps-u, uv1) = _trace-diff(expr.arg, var, depth, used_vars)
    let res = simplify(neg(du))

    let steps = ()
    steps.push(_s-header(neg(_v-diff(expr.arg, var)), "Constant multiple (-1)"))
    steps += _wrap-steps(steps-u, x => neg(x))

    if _is-helpful-simplify(neg(du), res) {
      steps.push(_s-note("Simplify", expr: res))
    }
    return (res, steps, uv1)
  }

  // Product Rule
  if is-type(expr, "mul") {
    let (u, v_expr) = (expr.args.at(0), expr.args.at(1))

    // Constant multiple
    if not _contains-var(u, var) {
      let (dv, steps-v, uv1) = _trace-diff(v_expr, var, depth, used_vars)
      let res = simplify(mul(u, dv))

      let steps = ()
      steps.push(_s-header(mul(u, _v-diff(v_expr, var)), "Constant multiple rule"))
      steps += _wrap-steps(steps-v, x => mul(u, x))

      if _is-helpful-simplify(mul(u, dv), res) {
        steps.push(_s-note("Simplify", expr: res))
      }
      return (res, steps, uv1)
    }

    if not _contains-var(v_expr, var) {
      let (du, steps-u, uv1) = _trace-diff(u, var, depth, used_vars)
      let res = simplify(mul(du, v_expr))

      let steps = ()
      steps.push(_s-header(mul(_v-diff(u, var), v_expr), "Constant multiple rule"))
      steps += _wrap-steps(steps-u, x => mul(x, v_expr))

      if _is-helpful-simplify(mul(du, v_expr), res) {
        steps.push(_s-note("Simplify", expr: res))
      }
      return (res, steps, uv1)
    }

    // Full Product Rule
    let (du, steps-u, uv1) = _trace-diff(u, var, depth + 1, used_vars)
    let (dv, steps-v, uv2) = _trace-diff(v_expr, var, depth + 1, uv1)

    let term1 = mul(du, v_expr)
    let term2 = mul(u, dv)
    let raw_res = add(term1, term2)
    let res = simplify(raw_res)

    let steps = ()
    let current_uv = uv2

    // Allocate names
    let (u-n, next_uv) = _alloc-name(current_uv)
    current_uv = next_uv
    let (v-n, next_uv2) = _alloc-name(current_uv)
    current_uv = next_uv2

    // 1. Show symbolic form: d/dx(u · v)
    steps.push(_s-header(_v-diff(mul(cvar(u-n), cvar(v-n)), var), "Product rule"))

    // 2. Define u and v
    steps.push(_s-define(u-n, u))
    steps.push(_s-define(v-n, v_expr))

    // 3. Show expansion with named vars: u'v + uv'
    let symbolic-expansion = add(
      mul(_v-diff(cvar(u-n), var), cvar(v-n)),
      mul(cvar(u-n), _v-diff(cvar(v-n), var)),
    )
    steps.push(_s-header(symbolic-expansion, "(" + u-n + v-n + ")' = " + u-n + "'" + v-n + " + " + u-n + v-n + "'"))

    // 4. Show derivatives of each
    let u-rule = {
      let primary = steps-u.find(s => {
        let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
        let label = s.at("rule", default: s.at("text", default: ""))
        is-step and label != "Simplify"
      })
      if primary != none {
        if primary.kind == "header" { primary.rule } else { primary.text }
      } else { "Differentiate" }
    }
    let v-rule = {
      let primary = steps-v.find(s => {
        let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
        let label = s.at("rule", default: s.at("text", default: ""))
        is-step and label != "Simplify"
      })
      if primary != none {
        if primary.kind == "header" { primary.rule } else { primary.text }
      } else { "Differentiate" }
    }

    if steps-u.len() > 2 {
      steps.push(_s-apply(_lhs-diff-name(u-n), du, "Differentiate " + u-n, sub-steps: steps-u))
    } else {
      steps.push(_s-apply(_lhs-diff-name(u-n), du, u-rule))
    }
    if steps-v.len() > 2 {
      steps.push(_s-apply(_lhs-diff-name(v-n), dv, "Differentiate " + v-n, sub-steps: steps-v))
    } else {
      steps.push(_s-apply(_lhs-diff-name(v-n), dv, v-rule))
    }

    // 5. Substitute
    steps.push(_s-header(res, "Substitute derivatives"))

    return (res, steps, current_uv)
  }

  // Quotient Rule
  if is-type(expr, "div") {
    let (u, v_expr) = (expr.num, expr.den)

    // Constant quotient
    if not _contains-var(u, var) and not _contains-var(v_expr, var) {
      return (num(0), (_s-note("Constant rule", expr: num(0)),), used_vars)
    }

    // Reciprocal rule
    if not _contains-var(u, var) and is-type(u, "num") and u.val == 1 {
      let (dv, steps-v, uv1) = _trace-diff(v_expr, var, depth + 1, used_vars)
      let res = simplify(cdiv(neg(dv), pow(v_expr, num(2))))
      let steps = ()
      let current_uv = uv1

      let (v-n, next_uv) = _alloc-name(current_uv)
      current_uv = next_uv

      // 1. Symbolic form
      steps.push(_s-header(_v-diff(cdiv(num(1), cvar(v-n)), var), "Reciprocal rule"))
      steps.push(_s-define(v-n, v_expr))

      // 2. Expansion: -v'/v²
      let symbolic-expansion = cdiv(neg(_v-diff(cvar(v-n), var)), pow(cvar(v-n), num(2)))
      steps.push(_s-header(symbolic-expansion, "(1/" + v-n + ")' = -" + v-n + "'/" + v-n + "²"))

      // 3. Derivative
      let v-rule = {
        let primary = steps-v.find(s => {
          let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
          let label = s.at("rule", default: s.at("text", default: ""))
          is-step and label != "Simplify"
        })
        if primary != none {
          if primary.kind == "header" { primary.rule } else { primary.text }
        } else { "Differentiate" }
      }
      if steps-v.len() > 2 {
        steps.push(_s-apply(_lhs-diff-name(v-n), dv, "Differentiate " + v-n, sub-steps: steps-v))
      } else {
        steps.push(_s-apply(_lhs-diff-name(v-n), dv, v-rule))
      }

      steps.push(_s-header(res, "Substitute derivative"))
      return (res, steps, current_uv)
    }

    // Full Quotient Rule
    let (du, steps-u, uv1) = _trace-diff(u, var, depth + 1, used_vars)
    let (dv, steps-v, uv2) = _trace-diff(v_expr, var, depth + 1, uv1)

    let num_raw = sub(mul(du, v_expr), mul(u, dv))
    let den_raw = pow(v_expr, num(2))
    let raw_res = cdiv(num_raw, den_raw)
    let res = simplify(raw_res)

    let steps = ()
    let current_uv = uv2

    let (u-n, next_uv) = _alloc-name(current_uv)
    current_uv = next_uv
    let (v-n, next_uv2) = _alloc-name(current_uv)
    current_uv = next_uv2

    // 1. Symbolic form: d/dx(u/v)
    steps.push(_s-header(_v-diff(cdiv(cvar(u-n), cvar(v-n)), var), "Quotient rule"))
    steps.push(_s-define(u-n, u))
    steps.push(_s-define(v-n, v_expr))

    // 2. Expansion: (u'v - uv') / v²
    let symbolic_num = sub(
      mul(_v-diff(cvar(u-n), var), cvar(v-n)),
      mul(cvar(u-n), _v-diff(cvar(v-n), var)),
    )
    let symbolic-expansion = cdiv(symbolic_num, pow(cvar(v-n), num(2)))
    let rule-desc = "(" + u-n + "/" + v-n + ")' = (" + u-n + "'" + v-n + " − " + u-n + v-n + "') / " + v-n + "²"
    steps.push(_s-header(symbolic-expansion, rule-desc))

    // 3. Derivatives — extract rule names
    let u-rule = {
      let primary = steps-u.find(s => {
        let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
        let label = s.at("rule", default: s.at("text", default: ""))
        is-step and label != "Simplify"
      })
      if primary != none {
        if primary.kind == "header" { primary.rule } else { primary.text }
      } else { "Differentiate" }
    }
    let v-rule = {
      let primary = steps-v.find(s => {
        let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
        let label = s.at("rule", default: s.at("text", default: ""))
        is-step and label != "Simplify"
      })
      if primary != none {
        if primary.kind == "header" { primary.rule } else { primary.text }
      } else { "Differentiate" }
    }

    if steps-u.len() > 2 {
      steps.push(_s-apply(_lhs-diff-name(u-n), du, "Differentiate " + u-n, sub-steps: steps-u))
    } else {
      steps.push(_s-apply(_lhs-diff-name(u-n), du, u-rule))
    }
    if steps-v.len() > 2 {
      steps.push(_s-apply(_lhs-diff-name(v-n), dv, "Differentiate " + v-n, sub-steps: steps-v))
    } else {
      steps.push(_s-apply(_lhs-diff-name(v-n), dv, v-rule))
    }

    // 4. Substitute
    steps.push(_s-header(res, "Substitute derivatives"))

    return (res, steps, current_uv)
  }

  // Power Rule & Chain Rule
  if is-type(expr, "pow") {
    let (b, e) = (expr.base, expr.exp)

    // x^n (simple)
    if is-type(b, "var") and b.name == var and is-type(e, "num") {
      let n = e.val
      let res = simplify(mul(e, pow(b, num(n - 1))))
      return (res, (_s-header(res, "Power rule"),), used_vars)
    }

    // u^c (Chain rule), where c is constant wrt differentiation variable.
    if not _contains-var(e, var) {
      let exp-minus-one = sub(e, num(1))
      let (db, steps-b, uv1) = _trace-diff(b, var, depth + 1, used_vars)
      let outer_deriv = mul(e, pow(b, exp-minus-one))
      let chain-head = mul(outer_deriv, _v-diff(b, var))
      let raw_res = mul(outer_deriv, db)
      let res = simplify(raw_res)

      let steps = ()
      let current_uv = uv1

      // Use structural check for triviality
      let is-trivial = _is-trivial-inner(b, var)

      if is-trivial {
        steps.push(_s-header(chain-head, "Chain rule (Power): c u^(c-1) u'"))
        steps += _wrap-steps(steps-b, x => mul(outer_deriv, x))
      } else {
        let (u-n, next_uv) = _alloc-name(current_uv)
        current_uv = next_uv

        let rule-desc = "Chain rule (Power): c " + u-n + "^(c-1) " + u-n + "'"
        steps.push(_s-header(chain-head, rule-desc))

        steps.push(_s-define(u-n, b))
        steps.push(_s-apply(_lhs-diff-name(u-n), db, "Inner derivative", sub-steps: steps-b))
        steps.push(_s-header(raw_res, "Substitute " + u-n + "'"))
      }

      if _is-helpful-simplify(raw_res, res) {
        steps.push(_s-note("Simplify", expr: res))
      }
      return (res, steps, current_uv)
    }

    // a^x (Exponential)
    if not _contains-var(b, var) {
      let (de, steps-e, uv1) = _trace-diff(e, var, depth + 1, used_vars)
      let factor = func("ln", b)
      let raw_res = mul(mul(expr, factor), de)
      let res = simplify(raw_res)

      let steps = ()
      let current_uv = uv1

      let is-trivial = _is-trivial-inner(e, var)

      if is-trivial {
        steps.push(_s-header(mul(mul(expr, factor), _v-diff(e, var)), "Exponential rule"))
        steps += _wrap-steps(steps-e, x => mul(mul(expr, factor), x))
      } else {
        let (u-n, next_uv) = _alloc-name(current_uv)
        current_uv = next_uv

        let rule-desc = "Exponential rule: (a^" + u-n + ")' = a^" + u-n + " ln(a) " + u-n + "'"
        steps.push(_s-header(mul(mul(expr, factor), _v-diff(e, var)), rule-desc))

        steps.push(_s-define(u-n, e))
        steps.push(_s-apply(_lhs-diff-name(u-n), de, "Diff exponent", sub-steps: steps-e))
      }
      return (res, steps, current_uv)
    }

    // General case f(x)^g(x): use logarithmic differentiation via
    // f^g = exp(g * ln(f)), then trace that derivative.
    let rewritten = func("exp", mul(e, ln-of(b)))
    let (drew, rewsteps, uv1) = _trace-diff(rewritten, var, depth + 1, used_vars)
    let res = simplify(drew)

    let steps = ()
    steps.push(_s-header(_v-diff(expr, var), "Logarithmic differentiation"))
    steps.push(_s-header(_v-diff(rewritten, var), "Rewrite u^v as exp(v·ln(u))"))
    if rewsteps.len() > 0 {
      let lhs = $d/(d #math.italic(var)) #cas-display(rewritten)$
      steps.push(_s-apply(lhs, drew, "Differentiate rewritten form", sub-steps: rewsteps))
    }
    if _is-helpful-simplify(drew, res) {
      steps.push(_s-note("Simplify", expr: res))
    }
    return (res, steps, uv1)
  }

  // Functions (Chain Rule) — table-driven
  if is-type(expr, "func") {
    if func-arity(expr) != 1 {
      return (diff(expr, var), (_s-note("Function arity not supported by step tracer", expr: expr),), used_vars)
    }
    let u = func-args(expr).at(0)

    let is-chain = not (is-type(u, "var") and u.name == var)
    let (du, steps-u, uv1) = if is-chain { _trace-diff(u, var, depth + 1, used_vars) } else { (num(1), (), used_vars) }

    let fname = expr.name
    let rule = calc-rules.at(fname, default: none)
    let deriv_outer = if rule != none { (rule.diff)(u) } else { num(1) }
    let rule_pat = if rule != none { rule.diff-step } else { "Unknown function" }

    let raw_res = if is-chain { mul(deriv_outer, du) } else { deriv_outer }
    let res = simplify(raw_res)

    let steps = ()
    let current_uv = uv1

    if is-chain {
      let is-trivial = _is-trivial-inner(u, var)

      if is-trivial {
        let rule-name = rule_pat.replace("@", "u")
        steps.push(_s-header(mul(deriv_outer, _v-diff(u, var)), "Chain rule: " + rule-name))
        steps += _wrap-steps(steps-u, x => mul(deriv_outer, x))
      } else {
        let (u-n, next_uv) = _alloc-name(current_uv)
        current_uv = next_uv

        let rule-name = rule_pat.replace("@", u-n)
        steps.push(_s-header(mul(deriv_outer, _v-diff(u, var)), "Chain rule: " + rule-name))

        steps.push(_s-define(u-n, u))
        steps.push(_s-apply(_lhs-diff-name(u-n), du, "Inner derivative", sub-steps: steps-u))
        steps.push(_s-header(raw_res, "Substitute " + u-n + "'"))
      }
    } else {
      steps.push(_s-header(res, "Standard derivative"))
    }

    if _is-helpful-simplify(raw_res, res) {
      steps.push(_s-note("Simplify", expr: res))
    }
    if rule != none {
      let dnote = rule.at("domain-note", default: none)
      if dnote != none and type(dnote) == str {
        steps.push(_s-note("Domain note: " + dnote.replace("@", "u")))
      }
    }

    return (res, steps, current_uv)
  }

  return (num(0), (_s-note("Unknown form", expr: expr),), used_vars)
}

// --- Integration Tracer ---
/// Recursive integration tracer.
/// Returns `(result-expr, step-list, used-var-names)`.

#let _trace-integrate(expr, var, depth, used_vars) = {
  // --- Base Cases ---
  if is-type(expr, "num") or is-type(expr, "const") {
    let res = mul(expr, cvar(var))
    return (res, (_s-header(res, "Constant rule"),), used_vars)
  }
  if is-type(expr, "var") {
    if expr.name == var {
      let res = cdiv(pow(cvar(var), num(2)), num(2))
      return (res, (_s-header(res, "Power rule (n = 1)"),), used_vars)
    }
    let res = mul(expr, cvar(var))
    return (res, (_s-header(res, "Constant rule"),), used_vars)
  }

  // --- Negation ---
  if is-type(expr, "neg") {
    let (ires, isteps, uv1) = _trace-integrate(expr.arg, var, depth, used_vars)
    let raw_res = neg(ires)
    let res = simplify(raw_res)
    let steps = ()
    let current_uv = uv1

    steps.push(_s-header(neg(_v-int(expr.arg, var)), "Negation: ∫(-f) dx = -(∫f dx)"))
    if isteps.len() > 1 {
      let (f-name, next_uv) = _alloc-name(current_uv)
      current_uv = next_uv
      steps.push(_s-define(f-name, expr.arg))
      steps.push(_s-apply(_lhs-int-name(f-name, var), ires, "Integrate", sub-steps: isteps))
      steps.push(_s-header(raw_res, "Substitute results"))
    }
    if _is-helpful-simplify(raw_res, res) {
      steps.push(_s-note("Simplify", expr: res))
    }
    return (res, steps, current_uv)
  }

  // --- Sum Rule (n-ary: flatten nested adds, split all at once) ---
  if is-type(expr, "add") {
    // Flatten nested add tree into a list of terms
    let terms = _flatten-add(expr)

    // Integrate each term
    let results = ()
    let all-steps = ()
    let current_uv = used_vars
    for t in terms {
      let (ires, isteps, uv1) = _trace-integrate(t, var, depth + 1, current_uv)
      current_uv = uv1
      results.push(ires)
      all-steps.push(isteps)
    }

    // Build raw result: sum of all integrated terms
    let raw_res = results.at(0)
    for i in range(1, results.len()) {
      raw_res = add(raw_res, results.at(i))
    }
    let res = simplify(raw_res)
    let steps = ()

    // Allocate names for all terms up front
    let term-names = ()
    for t in terms {
      let (t-name, next_uv) = _alloc-name(current_uv)
      current_uv = next_uv
      term-names.push(t-name)
    }

    // Build symbolic header: ∫(a+b+c) dx = ∫a dx + ∫b dx + ∫c dx
    let lhs-sum = cvar(term-names.at(0))
    for i in range(1, term-names.len()) {
      lhs-sum = add(lhs-sum, cvar(term-names.at(i)))
    }
    let rhs-parts = term-names.map(n => _v-int(cvar(n), var))
    let rhs-sum = rhs-parts.at(0)
    for i in range(1, rhs-parts.len()) {
      rhs-sum = add(rhs-sum, rhs-parts.at(i))
    }

    steps.push(_s-header(_v-int(lhs-sum, var), "Sum rule"))

    // Define each term
    for (i, t) in terms.enumerate() {
      steps.push(_s-define(term-names.at(i), t))
    }

    // Show: = ∫a dx + ∫b dx + ∫c dx
    steps.push(_s-header(rhs-sum, "Split into " + str(terms.len()) + " integrals"))

    // Show integration of each term
    for (i, t) in terms.enumerate() {
      let isteps = all-steps.at(i)
      let ires = results.at(i)
      let name = term-names.at(i)
      // Extract a compact rule description from the sub-steps
      let rule-text = {
        // Find the primary rule (first header or note, skip "Simplify")
        let primary = isteps.find(s => {
          let is-step = s.kind == "header" or (s.kind == "note" and s.expr != none)
          let label = s.at("rule", default: s.at("text", default: ""))
          is-step and label != "Simplify"
        })
        if primary != none {
          if primary.kind == "header" { primary.rule } else { primary.text }
        } else if isteps.len() > 0 {
          let s = isteps.at(0)
          if s.kind == "header" { s.rule } else if s.kind == "note" { s.text } else { "Integrate" }
        } else { "Integrate" }
      }
      // For sum rule terms, show each as a one-liner with the rule name.
      // Only expand sub-steps for truly complex cases (u-sub, nested sums).
      let complex = isteps.len() > 2
      if complex {
        steps.push(_s-apply(_lhs-int-name(name, var), ires, "Integrate " + name, sub-steps: isteps))
      } else {
        steps.push(_s-apply(_lhs-int-name(name, var), ires, rule-text))
      }
    }

    // Substitute results (show simplified form directly)
    steps.push(_s-header(res, "Substitute results"))

    return (res, steps, current_uv)
  }

  // --- Constant Multiple ---
  if is-type(expr, "mul") {
    let (a, b) = (expr.args.at(0), expr.args.at(1))
    if not _contains-var(a, var) {
      let (ires, isteps, uv1) = _trace-integrate(b, var, depth, used_vars)
      let raw_res = mul(a, ires)
      let res = simplify(raw_res)
      let steps = ()
      let current_uv = uv1

      let symbolic = mul(a, _v-int(b, var))
      if isteps.len() > 1 {
        // Complex inner: name it and show sub-steps
        let (f-name, next_uv) = _alloc-name(current_uv)
        current_uv = next_uv
        steps.push(_s-header(symbolic, "Constant multiple: ∫c·f dx = c·∫f dx"))
        steps.push(_s-define(f-name, b))
        steps.push(_s-apply(_lhs-int-name(f-name, var), ires, "Integrate", sub-steps: isteps))
        steps.push(_s-header(raw_res, "Substitute results"))
      } else {
        // Trivial inner: combine rule names (abbreviate inner rule)
        let inner-rule = if isteps.len() == 1 {
          let s = isteps.at(0)
          let full = if s.kind == "header" { s.rule } else if s.kind == "note" { s.text } else { "" }
          // Trim to short form: "Power rule: ∫x^n..." → "Power rule"
          if ":" in full { full.split(":").at(0) } else { full }
        } else { "" }
        let rule-name = if inner-rule != "" { "Constant multiple + " + inner-rule } else { "Constant multiple" }
        steps.push(_s-header(res, rule-name))
      }

      if _is-helpful-simplify(raw_res, res) {
        steps.push(_s-note("Simplify", expr: res))
      }
      return (res, steps, current_uv)
    }
    if not _contains-var(b, var) {
      let (ires, isteps, uv1) = _trace-integrate(a, var, depth, used_vars)
      let raw_res = mul(b, ires)
      let res = simplify(raw_res)
      let steps = ()
      let current_uv = uv1

      let symbolic = mul(b, _v-int(a, var))
      if isteps.len() > 1 {
        let (f-name, next_uv) = _alloc-name(current_uv)
        current_uv = next_uv
        steps.push(_s-header(symbolic, "Constant multiple: ∫c·f dx = c·∫f dx"))
        steps.push(_s-define(f-name, a))
        steps.push(_s-apply(_lhs-int-name(f-name, var), ires, "Integrate", sub-steps: isteps))
        steps.push(_s-header(raw_res, "Substitute results"))
      } else {
        let inner-rule = if isteps.len() == 1 {
          let s = isteps.at(0)
          if s.kind == "header" { s.rule } else if s.kind == "note" { s.text } else { "" }
        } else { "" }
        let rule-name = if inner-rule != "" { "Constant multiple + " + inner-rule } else { "Constant multiple" }
        steps.push(_s-header(res, rule-name))
      }

      if _is-helpful-simplify(raw_res, res) {
        steps.push(_s-note("Simplify", expr: res))
      }
      return (res, steps, current_uv)
    }
  }

  // --- Power Rule ---
  if is-type(expr, "pow") and is-type(expr.exp, "num") and expr.exp.val == 2 and is-type(expr.base, "func") {
    let fname = expr.base.name
    let square-rule = fn-square-power-integral-spec(fname)
    if square-rule != none {
      if func-arity(expr.base) != 1 {
        return (integrate(expr, var), (_s-note("Function arity not supported by step tracer", expr: expr),), used_vars)
      }
      let u = func-args(expr.base).at(0)
      let du = simplify(diff(u, var))
      if not _contains-var(du, var) and not expr-eq(du, num(0)) {
        let antideriv = (square-rule.antideriv)(u)
        let raw = if is-type(du, "num") and du.val == 1 {
          antideriv
        } else {
          cdiv(antideriv, du)
        }
        let res = simplify(raw)
        return (res, (_s-header(res, square-rule.rule),), used_vars)
      }
    }
  }

  if is-type(expr, "pow") and is-type(expr.base, "var") and expr.base.name == var and is-type(expr.exp, "num") {
    let n = expr.exp.val
    if n == -1 {
      let res = ln-of(abs-of(cvar(var)))
      return (res, (_s-header(res, "Special case: ∫x⁻¹ dx = ln|x|"),), used_vars)
    }
    let np1 = n + 1
    let res = simplify(cdiv(pow(cvar(var), num(np1)), num(np1)))
    return (res, (_s-header(res, "Power rule: ∫x^n dx = x^(n+1)/(n+1)"),), used_vars)
  }

  // --- Division: c/x and c/u(x) ---
  if is-type(expr, "div") {
    if is-type(expr.den, "var") and expr.den.name == var and is-type(expr.num, "num") {
      if expr.num.val == 1 {
        let res = ln-of(abs-of(cvar(var)))
        return (res, (_s-header(res, "∫1/x dx = ln|x|"),), used_vars)
      }
      let res = mul(expr.num, ln-of(abs-of(cvar(var))))
      return (res, (_s-header(res, "∫c/x dx = c·ln|x|"),), used_vars)
    }

    if not _contains-var(expr.num, var) {
      let du = simplify(diff(expr.den, var))
      if not _contains-var(du, var) and not expr-eq(du, num(0)) {
        let raw = cdiv(mul(expr.num, ln-of(abs-of(expr.den))), du)
        let res = simplify(raw)
        return (res, (_s-header(res, "u-sub: ∫c/u(x) dx = c·ln|u|/u'"),), used_vars)
      }
    }
  }

  // --- Functions: table-driven with u-sub ---
  if is-type(expr, "func") {
    let fname = expr.name
    if func-arity(expr) != 1 {
      return (integrate(expr, var), (_s-note("Function arity not supported by step tracer", expr: expr),), used_vars)
    }
    let u = func-args(expr).at(0)
    let rule = calc-rules.at(fname, default: none)
    if rule != none and rule.integ != none {
      let du = simplify(diff(u, var))
      if not _contains-var(du, var) {
        let antideriv = (rule.integ)(u)
        let steps = ()
        let current_uv = used_vars

        if is-type(du, "num") and du.val == 1 {
          // Direct: ∫f(x) dx — argument is exactly the variable
          let res = simplify(antideriv)
          steps.push(_s-header(res, "Standard integral: ∫" + fname))
          return (res, steps, current_uv)
        } else {
          // U-substitution: inner derivative is constant
          let raw_res = cdiv(antideriv, du)
          let res = simplify(raw_res)

          let (u-name, next_uv) = _alloc-name(current_uv)
          current_uv = next_uv

          steps.push(_s-header(res, "u-substitution"))
          steps.push(_s-define(u-name, u))
          steps.push(_s-apply(
            _lhs-diff-name(u-name),
            du,
            "Inner derivative (constant w.r.t. " + var + ")",
          ))
          steps.push(_s-note(
            "Table: ∫" + fname + "(" + u-name + ") d" + u-name,
            expr: antideriv,
          ))
          steps.push(_s-header(res, "Divide by d" + u-name + "/d" + var))
          return (res, steps, current_uv)
        }
      }
    }
  }

  // --- Fallback: delegate to CAS engine ---
  if is-type(expr, "div") {
    let decomp = simplify(_partial-fractions(expr, var))
    if not expr-eq(decomp, expr) {
      let (dres, dsteps, uv1) = _trace-integrate(decomp, var, depth + 1, used_vars)
      let steps = ()
      steps.push(_s-note("Partial-fraction decomposition", expr: decomp))
      if dsteps.len() > 0 {
        steps += dsteps
      }
      return (simplify(dres), steps, uv1)
    }
  }

  let res = simplify(integrate(expr, var))
  if is-type(res, "integral") {
    return (res, (_s-note("No closed form found", expr: res),), used_vars)
  }
  return (res, (_s-note("Computed by CAS engine", expr: res),), used_vars)
}

// --- Simplification Tracer ---
/// Heuristic label for a simplification transition shown to users.

#let _describe-simplification(before, after) = {
  if is-type(before, "add") {
    let (l, r) = (before.args.at(0), before.args.at(1))
    if (is-type(l, "num") and l.val == 0) or (is-type(r, "num") and r.val == 0) {
      return "Identity: f + 0 = f"
    }
    if is-type(l, "num") and is-type(r, "num") { return "Constant folding" }
    // neg cancellation: x + (-x) = 0
    if is-type(after, "num") and after.val == 0 { return "Cancellation" }
    return "Collect like terms"
  }
  if is-type(before, "mul") {
    let (l, r) = (before.args.at(0), before.args.at(1))
    if (is-type(l, "num") and l.val == 0) or (is-type(r, "num") and r.val == 0) {
      return "Annihilation: f · 0 = 0"
    }
    if (is-type(l, "num") and l.val == 1) or (is-type(r, "num") and r.val == 1) {
      return "Identity: f · 1 = f"
    }
    if is-type(l, "num") and is-type(r, "num") { return "Constant folding" }
    return "Simplify product"
  }
  if is-type(before, "pow") {
    if is-type(before.exp, "num") and before.exp.val == 0 { return "x⁰ = 1" }
    if is-type(before.exp, "num") and before.exp.val == 1 { return "x¹ = x" }
    if is-type(before.base, "num") and is-type(before.exp, "num") { return "Constant folding" }
    return "Simplify power"
  }
  if is-type(before, "neg") {
    if is-type(before.arg, "neg") { return "Double negation: −(−x) = x" }
    if is-type(before.arg, "num") { return "Evaluate negation" }
    return "Simplify negation"
  }
  if is-type(before, "div") {
    if is-type(before.num, "num") and is-type(before.den, "num") { return "Constant folding" }
    return "Simplify fraction"
  }
  if is-type(before, "func") { return "Function identity" }
  return "Simplify"
}

/// Recursive simplification tracer.
/// Simplifies child nodes first, then emits parent-level simplification steps.
#let _trace-simplify(expr, depth, used_vars) = {
  // Returns (result_expr, list_of_steps, used_vars)
  let result = simplify(expr)

  // Already simplified
  if expr-eq(result, expr) {
    return (result, (), used_vars)
  }

  // Leaf nodes — direct evaluation
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return (result, (_s-header(result, "Evaluate"),), used_vars)
  }

  // Depth limit to avoid excessive detail
  if depth > 3 {
    let desc = _describe-simplification(expr, result)
    return (result, (_s-header(result, desc),), used_vars)
  }

  let steps = ()
  let current_uv = used_vars

  // --- Negation ---
  if is-type(expr, "neg") {
    let (sr, sub-steps, uv1) = _trace-simplify(expr.arg, depth + 1, used_vars)
    current_uv = uv1
    let after-sub = neg(sr)
    let final = simplify(after-sub)

    if sub-steps.len() > 0 {
      steps += _wrap-steps(sub-steps, x => neg(x))
    }
    if not expr-eq(final, after-sub) or (sub-steps.len() == 0 and not expr-eq(final, expr)) {
      let desc = _describe-simplification(expr, final)
      steps.push(_s-header(final, desc))
    }
    return (final, steps, current_uv)
  }

  // --- Addition ---
  if is-type(expr, "add") {
    let (l, r) = (expr.args.at(0), expr.args.at(1))
    let (sl, lsteps, uv1) = _trace-simplify(l, depth + 1, used_vars)
    let (sr, rsteps, uv2) = _trace-simplify(r, depth + 1, uv1)
    current_uv = uv2
    let after-sub = add(sl, sr)
    let final = simplify(after-sub)

    // Show sub-expression simplifications in context
    if lsteps.len() > 0 {
      steps += _wrap-steps(lsteps, x => add(x, r))
    }
    if rsteps.len() > 0 {
      let left-to-use = if lsteps.len() > 0 { sl } else { l }
      steps += _wrap-steps(rsteps, x => add(left-to-use, x))
    }
    // Show combination step if the recombined result differs
    if not expr-eq(final, after-sub) {
      let desc = _describe-simplification(after-sub, final)
      steps.push(_s-header(final, desc))
    } else if lsteps.len() == 0 and rsteps.len() == 0 {
      // Nothing changed in sub-expressions, but the whole did
      let desc = _describe-simplification(expr, final)
      steps.push(_s-header(final, desc))
    }
    return (final, steps, current_uv)
  }

  // --- Multiplication ---
  if is-type(expr, "mul") {
    let (l, r) = (expr.args.at(0), expr.args.at(1))
    let (sl, lsteps, uv1) = _trace-simplify(l, depth + 1, used_vars)
    let (sr, rsteps, uv2) = _trace-simplify(r, depth + 1, uv1)
    current_uv = uv2
    let after-sub = mul(sl, sr)
    let final = simplify(after-sub)

    if lsteps.len() > 0 {
      steps += _wrap-steps(lsteps, x => mul(x, r))
    }
    if rsteps.len() > 0 {
      let left-to-use = if lsteps.len() > 0 { sl } else { l }
      steps += _wrap-steps(rsteps, x => mul(left-to-use, x))
    }
    if not expr-eq(final, after-sub) {
      let desc = _describe-simplification(after-sub, final)
      steps.push(_s-header(final, desc))
    } else if lsteps.len() == 0 and rsteps.len() == 0 {
      let desc = _describe-simplification(expr, final)
      steps.push(_s-header(final, desc))
    }
    return (final, steps, current_uv)
  }

  // --- Division ---
  if is-type(expr, "div") {
    let (n, d) = (expr.num, expr.den)
    let (sn, nsteps, uv1) = _trace-simplify(n, depth + 1, used_vars)
    let (sd, dsteps, uv2) = _trace-simplify(d, depth + 1, uv1)
    current_uv = uv2
    let after-sub = cdiv(sn, sd)
    let final = simplify(after-sub)

    if nsteps.len() > 0 {
      steps += _wrap-steps(nsteps, x => cdiv(x, d))
    }
    if dsteps.len() > 0 {
      let num-to-use = if nsteps.len() > 0 { sn } else { n }
      steps += _wrap-steps(dsteps, x => cdiv(num-to-use, x))
    }
    if not expr-eq(final, after-sub) {
      let desc = _describe-simplification(after-sub, final)
      steps.push(_s-header(final, desc))
    } else if nsteps.len() == 0 and dsteps.len() == 0 {
      let desc = _describe-simplification(expr, final)
      steps.push(_s-header(final, desc))
    }
    return (final, steps, current_uv)
  }

  // --- Power ---
  if is-type(expr, "pow") {
    let (b, e) = (expr.base, expr.exp)
    let (sb, bsteps, uv1) = _trace-simplify(b, depth + 1, used_vars)
    let (se, esteps, uv2) = _trace-simplify(e, depth + 1, uv1)
    current_uv = uv2
    let after-sub = pow(sb, se)
    let final = simplify(after-sub)

    if bsteps.len() > 0 {
      steps += _wrap-steps(bsteps, x => pow(x, e))
    }
    if esteps.len() > 0 {
      let base-to-use = if bsteps.len() > 0 { sb } else { b }
      steps += _wrap-steps(esteps, x => pow(base-to-use, x))
    }
    if not expr-eq(final, after-sub) {
      let desc = _describe-simplification(after-sub, final)
      steps.push(_s-header(final, desc))
    } else if bsteps.len() == 0 and esteps.len() == 0 {
      let desc = _describe-simplification(expr, final)
      steps.push(_s-header(final, desc))
    }
    return (final, steps, current_uv)
  }

  // --- Function ---
  if is-type(expr, "func") {
    let args = func-args(expr)
    if args.len() != 1 {
      let sargs = ()
      let all = ()
      let current_uv = used_vars
      let changed = false
      for (i, a) in args.enumerate() {
        let (sa, asteps, uv1) = _trace-simplify(a, depth + 1, current_uv)
        current_uv = uv1
        sargs.push(sa)
        if not expr-eq(sa, a) { changed = true }
        if asteps.len() > 0 { all += asteps }
      }
      let after-sub = func(expr.name, ..sargs)
      let final = simplify(after-sub)
      let steps = ()
      if all.len() > 0 {
        steps += all
      }
      if changed or not expr-eq(final, after-sub) {
        steps.push(_s-header(final, "Function identity"))
      }
      return (final, steps, current_uv)
    }
    let (sa, asteps, uv1) = _trace-simplify(args.at(0), depth + 1, used_vars)
    current_uv = uv1
    let after-sub = func(expr.name, sa)
    let final = simplify(after-sub)

    if asteps.len() > 0 {
      steps += _wrap-steps(asteps, x => func(expr.name, x))
    }
    if not expr-eq(final, after-sub) {
      steps.push(_s-header(final, "Function identity"))
    } else if asteps.len() == 0 {
      steps.push(_s-header(final, _describe-simplification(expr, final)))
    }
    return (final, steps, current_uv)
  }

  // --- Default fallback ---
  let desc = _describe-simplification(expr, result)
  return (result, (_s-header(result, desc),), used_vars)
}

// --- Solve Tracer ---
// Shows algebraic method: identifies linear/quadratic, displays formula and steps.


// =========================================================================
// 5. PUBLIC API
// =========================================================================

/// Produce step-by-step differentiation trace for `expr` with respect to `var`.
#let step-diff(expr, var, depth: none) = {
  _check-free-var(var)
  // Initialize with the variable of integration to prevent shadowing it
  let used_init = (var, "f", "g", "h")
  let (_, steps, _) = _trace-diff(expr, var, 0, used_init)
  steps
}

/// Produce step-by-step integration trace and append `+ C` when solved.
#let step-integrate(expr, var, depth: none) = {
  _check-free-var(var)
  let used_init = (var, "f", "g", "h")
  let (res, steps, _) = _trace-integrate(expr, var, 0, used_init)

  if not is-type(res, "integral") {
    let with-c = simplify(add(res, cvar("C")))
    steps.push(_s-note("Add constant of integration", expr: with-c))
  }

  steps
}

/// Produce step-by-step simplification trace.
#let step-simplify(expr, depth: none) = {
  let used_init = ("f", "g", "h")
  let (result, steps, _) = _trace-simplify(expr, 0, used_init)

  if steps.len() == 0 {
    steps.push(_s-note("Already simplified", expr: result))
  }

  // Verify against full simplify — if recursive decomposition missed something,
  // run additional passes.
  let target = simplify(expr)
  let current = result
  for i in range(5) {
    if expr-eq(current, target) { break }
    let next = simplify(current)
    if expr-eq(next, current) { break }
    if _is-helpful-simplify(current, next) {
      steps.push(_s-note("Simplify further", expr: next))
    }
    current = next
  }

  steps
}

/// Produce step-by-step equation solving trace.
/// Handles linear/quadratic structured paths and falls back to metadata-driven
/// root reporting for higher-degree or non-standard forms.
#let step-solve(lhs, rhs, var, depth: none) = {
  _check-free-var(var)
  let steps = ()

  // Move everything to one side
  let eq = if expr-eq(rhs, num(0)) { lhs } else { simplify(sub(lhs, rhs)) }
  if not expr-eq(rhs, num(0)) {
    steps.push(_s-note("Move all terms to one side: f(" + var + ") = 0", expr: eq))
  }

  let meta = _solve-meta-fn(lhs, rhs, var)
  let meta-roots = if meta != none { meta.roots } else { () }

  // Try to extract polynomial coefficients
  let coeffs = poly-coeffs(eq, var)

  // Linear: ax + b = 0
  if coeffs != none and coeffs.len() == 2 {
    let (b-val, a-val) = (coeffs.at(0), coeffs.at(1))
    if a-val != 0 {
      steps.push(_s-note("Linear equation: a·" + var + " + b = 0"))
      steps.push(_s-define("a", num(a-val), prefix: none))
      steps.push(_s-define("b", num(b-val), prefix: none))
      steps.push(_s-note($#cas-display(cvar(var)) = #cas-display(cdiv(neg(cvar("b")), cvar("a")))$))

      let sol = simplify(cdiv(neg(num(b-val)), num(a-val)))
      steps.push(_s-define(var, sol, prefix: none))
      return steps
    }
  }

  // Quadratic: ax² + bx + c = 0
  if coeffs != none and coeffs.len() == 3 {
    let (c-val, b-val, a-val) = (coeffs.at(0), coeffs.at(1), coeffs.at(2))
    if a-val != 0 {
      let a-expr = num(a-val)
      let b-expr = num(b-val)
      let c-expr = num(c-val)

      steps.push(_s-note("Quadratic equation: a·" + var + "² + b·" + var + " + c = 0"))
      steps.push(_s-define("a", a-expr, prefix: none))
      steps.push(_s-define("b", b-expr, prefix: none))
      steps.push(_s-define("c", c-expr, prefix: none))

      // Discriminant
      let disc = simplify(sub(pow(b-expr, num(2)), mul(num(4), mul(a-expr, c-expr))))
      steps.push(_s-note("Discriminant: Δ = b² − 4ac"))
      steps.push(_s-define("Δ", disc, prefix: none))

      // Formula
      steps.push(_s-note(
        $#math.italic(var) = frac(-#math.italic("b") ± sqrt(#math.italic("Δ")), 2#math.italic("a"))$
      ))

      // Solutions
      if meta-roots.len() == 0 {
        steps.push(_s-note("No real solutions (Δ < 0)"))
      } else {
        for (i, r) in meta-roots.enumerate() {
          steps.push(_s-define(var + "_" + str(i + 1), r.expr, prefix: none))
          let tags = ()
          if r.multiplicity > 1 { tags.push("multiplicity " + str(r.multiplicity)) }
          if r.exact { tags.push("exact") } else { tags.push("numeric") }
          if r.complex { tags.push("complex") } else { tags.push("real") }
          steps.push(_s-note("Root " + str(i + 1) + ": " + tags.join(", ")))
        }
      }
      return steps
    }
  }

  // Fallback: higher-degree or non-standard case.
  if coeffs != none and coeffs.len() >= 4 {
    let deg = coeffs.len() - 1
    steps.push(_s-note("Polynomial equation (degree " + str(deg) + ")"))

    if meta != none and meta.has-repeated-roots {
      steps.push(_s-note("Square-free preprocessing: repeated-root factor detected"))
      if meta.square-free-gcd != none and not expr-eq(simplify(meta.square-free-gcd), num(1)) {
        steps.push(_s-note("gcd(f, f')", expr: meta.square-free-gcd))
      }
      if meta.square-free-part != none {
        steps.push(_s-note("Square-free part", expr: meta.square-free-part))
      }
    }

    if _coeffs-intish(coeffs) {
      let candidates = _candidate-rational-roots(coeffs)
      steps.push(_s-note("Rational Root Theorem"))
      steps.push(_s-note(
        $#math.italic("r") = frac(#math.italic("p"), #math.italic("q")), #math.italic("p") | #math.italic("a")_0, #math.italic("q") | #math.italic("a")_(#math.italic("n"))$
      ))
      steps.push(_s-note("Candidate roots: " + _format-candidate-list(candidates)))

      let found-rational = ()
      for (p, q) in candidates {
        let r = p / q
        if calc.abs(_poly-eval-coeffs(coeffs, r)) < 1e-8 {
          let txt = _cand-text(p, q)
          if txt not in found-rational { found-rational.push(txt) }
        }
      }

      if found-rational.len() > 0 {
        steps.push(_s-note("Rational roots found: " + found-rational.join(", ")))
      } else {
        steps.push(_s-note("No rational root found; switch to numeric real-root search"))
      }
    } else {
      steps.push(_s-note("Non-integer coefficients; skip Rational Root Theorem"))
      steps.push(_s-note("Use numeric real-root search"))
    }
  }

  let roots = if meta != none and meta.roots.len() > 0 { meta.roots } else {
    _solve-fn(lhs, rhs, var).map(sol => (expr: sol, multiplicity: 1, exact: false, numeric: true, complex: false))
  }
  if roots.len() == 0 {
    steps.push(_s-note("No solutions found"))
  } else {
    let solutions = roots.map(r => r.expr)
    if _has-approx-solutions(solutions) {
      steps.push(_s-note("Approximate real roots (numeric method)"))
    }
    for (i, r) in roots.enumerate() {
      if roots.len() == 1 {
        steps.push(_s-define(var, r.expr, prefix: none))
      } else {
        steps.push(_s-define(var + "_" + str(i + 1), r.expr, prefix: none))
      }
      let tags = ()
      if r.multiplicity > 1 { tags.push("multiplicity " + str(r.multiplicity)) }
      if r.exact { tags.push("exact") } else { tags.push("numeric") }
      if r.complex { tags.push("complex") } else { tags.push("real") }
      if tags.len() > 0 {
        steps.push(_s-note("Root " + str(i + 1) + ": " + tags.join(", ")))
      }
    }
  }

  steps
}
