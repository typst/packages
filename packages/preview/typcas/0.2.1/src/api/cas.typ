// =========================================================================
// typcas v2 Namespace Module
// =========================================================================

#import "builder.typ": make-query
#import "../core/ast.typ": *
#import "../display/index.typ": cas-display, cas-equation
#import "../parse/index.typ": cas-parse
#import "../core/runtime.typ": assume as assume-core, assume-domain as assume-domain-core, assume-string as assume-string-core, merge-assumptions as merge-assumptions-core, parse-domain as parse-domain-core, variable-domain as variable-domain-core, display-variable-domain as display-variable-domain-core, display-steps as display-steps-core, set-step-style as set-step-style-core, get-step-style as get-step-style-core

/// Create a query object from input expression/content/string.
#let expr(input, assumptions: none, field: "real", strict: true) = make-query(
  input,
  assumptions: assumptions,
  field: field,
  strict: strict,
)

/// Internal helper `_is-query`.
#let _is-query(x) = type(x) == dictionary and "input" in x and "parsed" in x and "with" in x

/// Internal helper `_to-expr`.
/// Coerces common public API inputs into expression AST:
/// - query objects
/// - result objects with `.expr`
/// - raw string/content inputs
/// - plain numbers
#let _to-expr(v) = {
  if type(v) == dictionary and "expr" in v and v.expr != none { return normalize-int-constant(v.expr) }
  if type(v) == dictionary and "type" in v { return normalize-int-constant(v) }
  if _is-query(v) { return cas-parse(v.input) }
  if type(v) == str or type(v) == content { return cas-parse(v) }
  if type(v) == int or type(v) == float { return num(v) }
  v
}

/// Internal helper `_as-query`.
/// Accepts query objects, result objects with `.expr`, raw expr AST, or parseable input.
#let _as-query(x, assumptions: none, field: none, strict: none) = {
  if _is-query(x) { return x }

  let f = if field != none {
    field
  } else if type(x) == dictionary and "field" in x {
    x.field
  } else {
    "real"
  }
  let s = if strict != none {
    strict
  } else if type(x) == dictionary and "strict" in x {
    x.strict
  } else {
    true
  }

  if type(x) == dictionary and "expr" in x and x.expr != none {
    return expr(x.expr, assumptions: assumptions, field: f, strict: s)
  }
  expr(x, assumptions: assumptions, field: f, strict: s)
}

/// Parse input into canonical CAS expression AST.
#let parse(input) = cas-parse(_to-expr(input))
/// Render CAS expression/content for Typst output.
#let display(input) = cas-display(_to-expr(input))
/// Render a left-right equation block.
#let equation(lhs, rhs) = cas-equation(_to-expr(lhs), _to-expr(rhs))

/// Create boolean-flag assumptions for a variable.
#let assume = assume-core
/// Create interval-domain assumptions for a variable.
#let assume-domain = assume-domain-core
/// Create assumptions from compact string syntax.
#let assume-string = assume-string-core
/// Merge multiple assumption dictionaries.
#let merge-assumptions = merge-assumptions-core
/// Parse a domain string into normalized interval-set data.
#let parse-domain = parse-domain-core
/// Get effective domain-set record for a variable under assumptions.
#let variable-domain = variable-domain-core
/// Get human-readable domain string for a variable under assumptions.
#let display-domain = display-variable-domain-core
/// Set global document step-style configuration.
#let set-step-style = set-step-style-core
/// Get current global document step-style configuration.
#let get-step-style = get-step-style-core

/// Render step nodes (or trace result) for an original expression.
#let render-steps(original, trace-or-steps, operation: none, var: none, rhs: none) = {
  let source = _to-expr(original)

  let steps = if type(trace-or-steps) == dictionary and "steps" in trace-or-steps {
    trace-or-steps.steps
  } else {
    trace-or-steps
  }

  display-steps-core(source, steps, operation: operation, var: var, rhs: if rhs == none { none } else { _to-expr(rhs) })
}

// Ergonomic task-first API to avoid dictionary function-field call parens.
/// Parse input via query entrypoint and return structured parse result.
#let parsed(input, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).parsed)()
/// Simplify expression with optional expansion/domain-sensitive options.
#let simplify(input, expand: false, allow-domain-sensitive: false, detail: 0, depth: none, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).simplify)(
  expand: expand,
  allow-domain-sensitive: allow-domain-sensitive,
  detail: detail,
  depth: depth,
)
/// Differentiate expression with optional order and step detail.
#let diff(input, var, order: 1, detail: 0, depth: none, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).diff)(
  var,
  order: order,
  detail: detail,
  depth: depth,
)
/// Integrate expression (definite or indefinite) with optional step detail.
#let integrate(input, var, definite: none, detail: 0, depth: none, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).integrate)(
  var,
  definite: definite,
  detail: detail,
  depth: depth,
)
/// Compute implicit derivative dy/dx from F(x,y)=0-style relation.
#let implicit-diff(input, x, y, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).implicit-diff)(
  x,
  y,
)
/// Solve equation `input = rhs` for variable `var`.
#let solve(input, rhs: 0, var: "x", detail: 0, depth: none, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).solve)(
  rhs: _to-expr(rhs),
  var: var,
  detail: detail,
  depth: depth,
)
/// Factor expression with respect to variable `var`.
#let factor(input, ..opts) = {
  let pos = opts.pos()
  let named = opts.named()

  if pos.len() > 1 {
    panic("factor: expected at most one positional argument after input")
  }

  let v = if "var" in named {
    named.at("var")
  } else if pos.len() == 1 {
    pos.at(0)
  } else {
    "x"
  }
  let assumptions = named.at("assumptions", default: none)
  let field = named.at("field", default: none)
  let strict = named.at("strict", default: none)

  (_as-query(input, assumptions: assumptions, field: field, strict: strict).factor)(v)
}
/// Compute limit as `var -> to`.
#let limit(input, var, to, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).limit)(var, to)
/// Compute Taylor expansion around `x0` to given order.
#let taylor(input, var, x0, order, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).taylor)(
  var,
  _to-expr(x0),
  order,
)
/// Evaluate expression numerically with provided bindings.
#let eval(input, bindings: (:), assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).eval)(bindings: bindings)
/// Substitute variable `var` with replacement expression `repl`.
#let substitute(input, var, repl, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).substitute)(
  var,
  _to-expr(repl),
)
/// Produce step trace for simplify/diff/integrate/solve operations.
#let trace(input, op, var: "x", rhs: 0, depth: none, detail: 2, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).trace)(
  op,
  var: var,
  rhs: _to-expr(rhs),
  depth: depth,
  detail: detail,
)
/// Produce simplify trace without op-string argument.
#let trace-simplify(input, detail: 2, depth: none, assumptions: none, field: none, strict: none) = trace(
  input,
  "simplify",
  depth: depth,
  detail: detail,
  assumptions: assumptions,
  field: field,
  strict: strict,
)
/// Produce derivative trace without op-string argument.
#let trace-diff(input, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none) = trace(
  input,
  "diff",
  var: var,
  depth: depth,
  detail: detail,
  assumptions: assumptions,
  field: field,
  strict: strict,
)
/// Produce integration trace without op-string argument.
#let trace-integrate(input, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none) = trace(
  input,
  "integrate",
  var: var,
  depth: depth,
  detail: detail,
  assumptions: assumptions,
  field: field,
  strict: strict,
)
/// Produce solve trace without op-string argument.
#let trace-solve(input, rhs: 0, var: "x", detail: 2, depth: none, assumptions: none, field: none, strict: none) = trace(
  input,
  "solve",
  var: var,
  rhs: rhs,
  depth: depth,
  detail: detail,
  assumptions: assumptions,
  field: field,
  strict: strict,
)
/// Return variable domain summary result for current query context.
#let domain(input, var, assumptions: none, field: none, strict: none) = (_as-query(input, assumptions: assumptions, field: field, strict: strict).domain)(var)

/// Convenience extractor for `.ok`.
#let ok(x) = if type(x) == dictionary and "ok" in x { x.ok } else { true }
/// Convenience extractor for first error message.
#let error-message(x, default: "unknown") = {
  if type(x) == dictionary and "errors" in x and x.errors != none and x.errors.len() > 0 {
    let first = x.errors.at(0)
    if type(first) == dictionary and "message" in first { return first.message }
  }
  default
}
/// Convenience extractor for expression payload.
#let expr-of(x, default: none) = {
  if type(x) == dictionary and "expr" in x and x.expr != none { return x.expr }
  if _is-query(x) { return parse(x.input) }
  if type(x) == str or type(x) == content or type(x) == int or type(x) == float { return parse(x) }
  if type(x) == dictionary and "type" in x { return x }
  default
}
/// Convenience extractor for numeric/auxiliary value payload.
#let value-of(x, default: none) = if type(x) == dictionary and "value" in x { x.value } else { default }
/// Convenience extractor for steps payload.
#let steps-of(x, default: ()) = {
  if type(x) == dictionary and "steps" in x and x.steps != none { return x.steps }
  default
}
/// Convenience extractor for roots payload.
#let roots-of(x, mode: "expr") = {
  if not (type(x) == dictionary and "roots" in x and x.roots != none) { return () }
  if mode == "meta" { return x.roots }
  let out = ()
  for r in x.roots {
    if type(r) == dictionary and "expr" in r and r.expr != none {
      out.push(r.expr)
    } else {
      out.push(r)
    }
  }
  out
}

/// Bind assumptions/field/strict once and reuse task-first operations.
#let with(assumptions: none, field: "real", strict: true) = (
  parsed: input => parsed(input, assumptions: assumptions, field: field, strict: strict),
  simplify: (input, expand: false, allow-domain-sensitive: false, detail: 0, depth: none) => simplify(
    input,
    expand: expand,
    allow-domain-sensitive: allow-domain-sensitive,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  diff: (input, var, order: 1, detail: 0, depth: none) => diff(
    input,
    var,
    order: order,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  integrate: (input, var, definite: none, detail: 0, depth: none) => integrate(
    input,
    var,
    definite: definite,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  implicit-diff: (input, x, y) => implicit-diff(
    input,
    x,
    y,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  solve: (input, rhs: 0, var: "x", detail: 0, depth: none) => solve(
    input,
    rhs: rhs,
    var: var,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  factor: (input, var: "x") => factor(input, var, assumptions: assumptions, field: field, strict: strict),
  limit: (input, var, to) => limit(input, var, to, assumptions: assumptions, field: field, strict: strict),
  taylor: (input, var, x0, order) => taylor(input, var, x0, order, assumptions: assumptions, field: field, strict: strict),
  eval: (input, bindings: (:)) => eval(input, bindings: bindings, assumptions: assumptions, field: field, strict: strict),
  substitute: (input, var, repl) => substitute(input, var, repl, assumptions: assumptions, field: field, strict: strict),
  trace: (input, op, var: "x", rhs: 0, depth: none, detail: 2) => trace(
    input,
    op,
    var: var,
    rhs: rhs,
    depth: depth,
    detail: detail,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  trace-simplify: (input, detail: 2, depth: none) => trace-simplify(
    input,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  trace-diff: (input, var: "x", detail: 2, depth: none) => trace-diff(
    input,
    var: var,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  trace-integrate: (input, var: "x", detail: 2, depth: none) => trace-integrate(
    input,
    var: var,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  trace-solve: (input, rhs: 0, var: "x", detail: 2, depth: none) => trace-solve(
    input,
    rhs: rhs,
    var: var,
    detail: detail,
    depth: depth,
    assumptions: assumptions,
    field: field,
    strict: strict,
  ),
  domain: (input, var) => domain(input, var, assumptions: assumptions, field: field, strict: strict),
  render-steps: (original, trace-or-steps, operation: none, var: none, rhs: none) => render-steps(
    original,
    trace-or-steps,
    operation: operation,
    var: var,
    rhs: rhs,
  ),
)
/// Construct matrix AST directly (avoids `cas.ast.matrix` field-call syntax).
#let matrix(rows) = cmat(rows)

/// Internal helper `_tool-query` for task-first matrix/system/poly wrappers.
#let _tool-query(field: none, strict: none) = {
  let f = if field == none { "real" } else { field }
  let s = if strict == none { true } else { strict }
  expr("0", field: f, strict: s)
}

/// Matrix addition.
#let mat-add(a, b, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.add)(_to-expr(a), _to-expr(b))
/// Matrix subtraction.
#let mat-sub(a, b, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.sub)(_to-expr(a), _to-expr(b))
/// Matrix scalar multiplication.
#let mat-scale(c, m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.scale)(_to-expr(c), _to-expr(m))
/// Matrix multiplication.
#let mat-mul(a, b, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.mul)(_to-expr(a), _to-expr(b))
/// Matrix transpose.
#let mat-transpose(m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.transpose)(_to-expr(m))
/// Matrix determinant.
#let mat-det(m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.det)(_to-expr(m))
/// Matrix inverse.
#let mat-inv(m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.inv)(_to-expr(m))
/// Solve linear matrix equation Ax = b.
#let mat-solve(a, b, field: none, strict: none) = {
  let rhs = if type(b) == array { b.map(v => _to-expr(v)) } else { b }
  (_tool-query(field: field, strict: strict).matrix.solve)(_to-expr(a), rhs)
}
/// Matrix eigenvalues.
#let mat-eigenvalues(m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.eigenvalues)(_to-expr(m))
/// Matrix eigenvectors.
#let mat-eigenvectors(m, field: none, strict: none) = (_tool-query(field: field, strict: strict).matrix.eigenvectors)(_to-expr(m))

/// Solve linear equation system.
#let solve-linear-system(equations, vars, field: none, strict: none) = (_tool-query(field: field, strict: strict).systems.linear)(equations, vars)
/// Solve nonlinear equation system numerically.
#let solve-nonlinear-system(equations, vars, initial, max-iters: 40, tol: 1e-10, field: none, strict: none) = (_tool-query(field: field, strict: strict).systems.nonlinear)(
  equations,
  vars,
  initial,
  max-iters: max-iters,
  tol: tol,
)

/// Polynomial long division.
#let poly-coeffs(expr, var, field: none, strict: none) = (_tool-query(field: field, strict: strict).poly.coeffs)(_to-expr(expr), var)
/// Rebuild polynomial expression from coefficient tuple.
#let coeffs-to-expr(coeffs, var, field: none, strict: none) = (_tool-query(field: field, strict: strict).poly.from-coeffs)(coeffs, var)
/// Polynomial long division.
#let poly-div(p, d, var, field: none, strict: none) = (_tool-query(field: field, strict: strict).poly.div)(_to-expr(p), _to-expr(d), var)
/// Partial fraction decomposition.
#let partial-fractions(expr, var, field: none, strict: none) = (_tool-query(field: field, strict: strict).poly.partial-fractions)(_to-expr(expr), var)

/// Public AST constructor bundle.
#let ast = (
  num: num,
  var: cvar,
  const: const-expr,
  add: add,
  mul: mul,
  pow: pow,
  div: cdiv,
  neg: neg,
  func: func,
  log: log-of,
  sum: csum,
  prod: cprod,
  matrix: cmat,
  piecewise: piecewise,
  complex: complex,
  is-complex: is-complex,
  complex-conj: complex-conj,
)
