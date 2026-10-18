// =========================================================================
// typcas v2 Integration
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "integrate-methods.typ": analyze-integral

#let _is-one(expr) = is-type(expr, "num") and expr.val == 1

#let _flatten-add(expr) = {
  if is-type(expr, "add") {
    return _flatten-add(expr.args.at(0)) + _flatten-add(expr.args.at(1))
  }
  (expr,)
}

#let _build-add(terms) = {
  if terms.len() == 0 { return num(0) }
  let out = terms.at(0)
  for i in range(1, terms.len()) {
    out = add(out, terms.at(i))
  }
  out
}

/// Keep integration constant `C` at the tail of a top-level sum.
#let integral-c-last(expr) = {
  let terms = _flatten-add(expr)
  let cterms = terms.filter(is-int-constant)
  if cterms.len() == 0 { return expr }

  let others = terms.filter(t => not is-int-constant(t))
  let reordered = others + cterms
  _build-add(reordered)
}

#let _integrate-core(expr, v, depth) = {
  let method = analyze-integral(expr, v)

  if method.kind == "const" {
    return mul(method.data.const, cvar(v))
  }

  if method.kind == "var" {
    return cdiv(pow(cvar(v), num(2)), num(2))
  }

  if method.kind == "add" {
    return add(_integrate-core(method.data.left, v, depth + 1), _integrate-core(method.data.right, v, depth + 1))
  }

  if method.kind == "neg" {
    return neg(_integrate-core(method.data.inner, v, depth + 1))
  }

  if method.kind == "const-factor" {
    return mul(method.data.const, _integrate-core(method.data.inner, v, depth + 1))
  }

  if method.kind == "u-sub" {
    let coeff = simplify(method.data.coeff)
    let ant = (method.data.antideriv)(method.data.u)
    if _is-one(coeff) { return ant }
    return mul(coeff, ant)
  }

  if method.kind == "by-parts" or method.kind == "partial-fraction" {
    return method.data.result
  }

  if method.kind == "power" {
    let n = method.data.n
    return cdiv(pow(cvar(v), num(n + 1)), num(n + 1))
  }

  if method.kind == "reciprocal" {
    return ln-of(abs-of(cvar(v)))
  }

  if method.kind == "func-primitive" {
    let ant = (method.data.antideriv)(method.data.u)
    if method.data.at("direct", default: false) {
      return ant
    }
    return cdiv(ant, simplify(method.data.du))
  }

  if method.kind == "square-family" {
    let ant = (method.data.antideriv)(method.data.u)
    let u = method.data.u
    if is-type(u, "var") and u.name == v {
      return ant
    }
    return cdiv(ant, simplify(method.data.du))
  }

  (type: "integral", expr: method.data.expr, var: v)
}

#let integrate(expr, v) = {
  let core = _integrate-core(expr, v, 0)
  integral-c-last(simplify(add(core, const-expr("C"))))
}
