// =========================================================================
// typcas v2 Parser
// =========================================================================
// Fresh recursive-descent parser for string/content math input.
// =========================================================================

#import "../expr.typ": *
#import "../truths/function-registry.typ": fn-canonical, fn-spec, fn-arity-ok, fn-arity-min

#let _is-digit(c) = c >= "0" and c <= "9"
#let _is-alpha(c) = {
  let u = str.to-unicode(c)
  (u >= 65 and u <= 90) or (u >= 97 and u <= 122)
}
#let _is-ident-start(c) = _is-alpha(c)
#let _is-ident-char(c) = _is-alpha(c) or _is-digit(c)

#let _tokenize(s) = {
  let out = ()
  let cs = s.clusters()
  let i = 0

  while i < cs.len() {
    let c = cs.at(i)

    if c == " " or c == "\t" or c == "\n" or c == "\r" {
      i += 1
      continue
    }

    if _is-digit(c) {
      let start = i
      i += 1
      while i < cs.len() and _is-digit(cs.at(i)) { i += 1 }
      if i < cs.len() and cs.at(i) == "." {
        i += 1
        while i < cs.len() and _is-digit(cs.at(i)) { i += 1 }
      }
      out.push((type: "num", val: cs.slice(start, i).join()))
      continue
    }

    if _is-ident-start(c) {
      let start = i
      i += 1
      while i < cs.len() and _is-ident-char(cs.at(i)) { i += 1 }
      out.push((type: "ident", val: cs.slice(start, i).join()))
      continue
    }

    if c == "π" {
      out.push((type: "ident", val: "pi"))
      i += 1
      continue
    }
    if c == "∞" {
      out.push((type: "ident", val: "inf"))
      i += 1
      continue
    }
    if c == "∑" {
      out.push((type: "ident", val: "sum"))
      i += 1
      continue
    }
    if c == "∏" {
      out.push((type: "ident", val: "product"))
      i += 1
      continue
    }
    if c == "∫" {
      out.push((type: "ident", val: "integral"))
      i += 1
      continue
    }
    if c == "−" { // unicode minus
      out.push((type: "op", val: "-"))
      i += 1
      continue
    }

    if c == "+" or c == "-" or c == "*" or c == "/" or c == "^" or c == "_" or c == "=" {
      out.push((type: "op", val: c))
      i += 1
      continue
    }

    if c == "(" {
      out.push((type: "lparen", val: "("))
      i += 1
      continue
    }
    if c == ")" {
      out.push((type: "rparen", val: ")"))
      i += 1
      continue
    }
    if c == "," {
      out.push((type: "comma", val: ","))
      i += 1
      continue
    }

    // Drop unknown glyphs (formatting wrappers, etc.)
    i += 1
  }

  out
}

#let _peek(tokens, pos) = if pos < tokens.len() { tokens.at(pos) } else { none }
#let _is-op(tokens, pos, op) = {
  let t = _peek(tokens, pos)
  t != none and t.type == "op" and t.val == op
}
#let _num-val(s) = if s.contains(".") { float(s) } else { int(s) }

#let _atom-subscript-piece(expr) = {
  if is-type(expr, "num") {
    if type(expr.val) == int { return str(expr.val) }
    if calc.abs(expr.val - calc.round(expr.val)) < 1e-10 {
      return str(int(calc.round(expr.val)))
    }
    return none
  }
  if is-type(expr, "var") or is-type(expr, "const") { return expr.name }
  if is-type(expr, "neg") and is-type(expr.arg, "num") and type(expr.arg.val) == int {
    return "-" + str(expr.arg.val)
  }
  none
}

#let _bind-sum-index(expr, idx) = {
  if is-type(expr, "num") or is-type(expr, "var") { return expr }
  if is-type(expr, "const") {
    if expr.name == idx { return cvar(idx) }
    return expr
  }
  if is-type(expr, "neg") { return neg(_bind-sum-index(expr.arg, idx)) }
  if is-type(expr, "add") { return add(_bind-sum-index(expr.args.at(0), idx), _bind-sum-index(expr.args.at(1), idx)) }
  if is-type(expr, "mul") { return mul(_bind-sum-index(expr.args.at(0), idx), _bind-sum-index(expr.args.at(1), idx)) }
  if is-type(expr, "div") { return cdiv(_bind-sum-index(expr.num, idx), _bind-sum-index(expr.den, idx)) }
  if is-type(expr, "pow") { return pow(_bind-sum-index(expr.base, idx), _bind-sum-index(expr.exp, idx)) }
  if is-type(expr, "func") {
    let xs = func-args(expr).map(x => _bind-sum-index(x, idx))
    return func(expr.name, ..xs)
  }
  if is-type(expr, "log") { return log-of(_bind-sum-index(expr.base, idx), _bind-sum-index(expr.arg, idx)) }
  if is-type(expr, "sum") {
    return csum(
      _bind-sum-index(expr.body, idx),
      expr.idx,
      _bind-sum-index(expr.from, idx),
      _bind-sum-index(expr.to, idx),
    )
  }
  if is-type(expr, "prod") {
    return cprod(
      _bind-sum-index(expr.body, idx),
      expr.idx,
      _bind-sum-index(expr.from, idx),
      _bind-sum-index(expr.to, idx),
    )
  }
  expr
}

#let _parse-call-args(tokens, pos, p) = {
  if _peek(tokens, pos) == none or _peek(tokens, pos).type != "lparen" { return (none, pos) }

  let q = pos + 1
  let args = ()

  if _peek(tokens, q) != none and _peek(tokens, q).type == "rparen" {
    return (args, q + 1)
  }

  while q < tokens.len() {
    let (a, q1) = (p.expr)(tokens, q, p)
    args.push(a)
    q = q1

    let t = _peek(tokens, q)
    if t != none and t.type == "comma" {
      q += 1
      continue
    }
    if t != none and t.type == "rparen" {
      return (args, q + 1)
    }
    return (none, q)
  }

  (none, q)
}

#let _parse-atom(tokens, pos, p) = {
  let tok = _peek(tokens, pos)
  if tok == none {
    panic("cas-parse: unexpected end of input")
  }

  if tok.type == "num" {
    return (num(_num-val(tok.val)), pos + 1)
  }

  if tok.type == "lparen" {
    let (inner, q) = (p.expr)(tokens, pos + 1, p)
    if q >= tokens.len() or _peek(tokens, q).type != "rparen" {
      panic("cas-parse: expected ')' to close '('")
    }
    return (inner, q + 1)
  }

  if tok.type == "ident" {
    let name = tok.val
    let next = _peek(tokens, pos + 1)

    // Philosophy exception: structural binder syntax is parser-level, not registry-driven.
    // sum_(k=1)^n body
    if (name == "sum" or name == "product") and _is-op(tokens, pos + 1, "_") {
      let q = pos + 2
      if _peek(tokens, q) == none or _peek(tokens, q).type != "lparen" {
        panic("cas-parse: malformed " + name + " lower bound, expected '('")
      }
      q += 1

      let (idx-expr, q1) = (p.atom)(tokens, q, p)
      let idx = if is-type(idx-expr, "var") or is-type(idx-expr, "const") { idx-expr.name } else { none }
      if idx == none { panic("cas-parse: malformed " + name + " index variable") }
      if idx == "C" {
        panic("cas-parse: index variable 'C' is reserved; use C_0 or another symbol")
      }
      q = q1

      if not _is-op(tokens, q, "=") {
        panic("cas-parse: malformed " + name + ", expected '='")
      }
      q += 1

      let (from, q2) = (p.expr)(tokens, q, p)
      q = q2
      if _peek(tokens, q) == none or _peek(tokens, q).type != "rparen" {
        panic("cas-parse: malformed " + name + " lower bound, expected ')'")
      }
      q += 1

      if not _is-op(tokens, q, "^") {
        panic("cas-parse: malformed " + name + ", expected '^'")
      }
      q += 1

      let (to, q3) = (p.power)(tokens, q, p)
      q = q3
      let (body-raw, q4) = (p.power)(tokens, q, p)
      let body = _bind-sum-index(body-raw, idx)

      let node = if name == "sum" { csum(body, idx, from, to) } else { cprod(body, idx, from, to) }
      return (node, q4)
    }

    // Philosophy exception: log subscript grammar is a structural syntax form.
    // log_b(x) and log_b x
    if name == "log" and _is-op(tokens, pos + 1, "_") {
      let (base, q) = (p.atom)(tokens, pos + 2, p)
      let t = _peek(tokens, q)
      if t != none and t.type == "lparen" {
        let (arg, q2) = (p.expr)(tokens, q + 1, p)
        if q2 >= tokens.len() or _peek(tokens, q2).type != "rparen" {
          panic("cas-parse: malformed log subscript call, expected ')'")
        }
        return (log-of(base, arg), q2 + 1)
      }
      let (arg, q2) = (p.atom)(tokens, q, p)
      return (log-of(base, arg), q2)
    }

    // x_1 style subscripts -> variable name merge
    if name != "sum" and name != "product" and name != "log" and _is-op(tokens, pos + 1, "_") {
      let (subexpr, q) = (p.atom)(tokens, pos + 2, p)
      let suffix = _atom-subscript-piece(subexpr)
      if suffix != none and suffix != "" {
        return (cvar(name + "_" + suffix), q)
      }
      return (cvar(name), pos + 1)
    }

    // compatibility: log x => ln(x)
    if name == "log" and not (next != none and next.type == "lparen") {
      let q = pos + 1
      let arg-t = _peek(tokens, q)
      if arg-t != none and (arg-t.type == "num" or arg-t.type == "ident" or arg-t.type == "lparen") {
        let (arg, q2) = (p.power)(tokens, q, p)
        return (func("ln", arg), q2)
      }
    }

    // implicit unary call: sin x, sec^2 x
    let canonical = fn-canonical(name)
    let spec = fn-spec(name)
    if canonical != none and spec != none and spec.arity == 1 and spec.parse.allow-implicit and not (next != none and next.type == "lparen") {
      let q = pos + 1
      let fn-exp = none
      if spec.parse.allow-power-prefix and _is-op(tokens, q, "^") {
        let (e, q1) = (p.unary)(tokens, q + 1, p)
        fn-exp = e
        q = q1
      }

      let arg-t = _peek(tokens, q)
      if arg-t != none and (arg-t.type == "num" or arg-t.type == "ident" or arg-t.type == "lparen") {
        let (arg, q2) = (p.power)(tokens, q, p)
        let f = func(canonical, arg)
        if fn-exp != none { return (pow(f, fn-exp), q2) }
        return (f, q2)
      }
    }

    // function calls
    if next != none and next.type == "lparen" {
      // Philosophy exception: these are parser-only structural forms.
      if name == "frac" {
        let (n, q) = (p.expr)(tokens, pos + 2, p)
        if _peek(tokens, q) == none or _peek(tokens, q).type != "comma" {
          panic("cas-parse: malformed frac call, expected ','")
        }
        let (d, q2) = (p.expr)(tokens, q + 1, p)
        if _peek(tokens, q2) == none or _peek(tokens, q2).type != "rparen" {
          panic("cas-parse: malformed frac call, expected ')'")
        }
        return (cdiv(n, d), q2 + 1)
      }

      if name == "sqrt" {
        let (arg, q) = (p.expr)(tokens, pos + 2, p)
        if _peek(tokens, q) == none or _peek(tokens, q).type != "rparen" {
          panic("cas-parse: malformed sqrt call, expected ')'")
        }
        return (pow(arg, cdiv(num(1), num(2))), q + 1)
      }

      if name == "root" {
        let (idx, q) = (p.expr)(tokens, pos + 2, p)
        if _peek(tokens, q) == none or _peek(tokens, q).type != "comma" {
          panic("cas-parse: malformed root call, expected ','")
        }
        let (arg, q2) = (p.expr)(tokens, q + 1, p)
        if _peek(tokens, q2) == none or _peek(tokens, q2).type != "rparen" {
          panic("cas-parse: malformed root call, expected ')'")
        }
        return (pow(arg, cdiv(num(1), idx)), q2 + 1)
      }

      if name == "log" {
        let (first, q) = (p.expr)(tokens, pos + 2, p)
        if _peek(tokens, q) != none and _peek(tokens, q).type == "comma" {
          let (second, q2) = (p.expr)(tokens, q + 1, p)
          if _peek(tokens, q2) == none or _peek(tokens, q2).type != "rparen" {
            panic("cas-parse: malformed log(base,arg) call, expected ')'")
          }
          return (log-of(first, second), q2 + 1)
        }
        if _peek(tokens, q) == none or _peek(tokens, q).type != "rparen" {
          panic("cas-parse: malformed log call, expected ')'")
        }
        return (func("ln", first), q + 1)
      }

      let (args, q) = _parse-call-args(tokens, pos + 1, p)
      if args == none {
        panic("cas-parse: malformed function call for '" + name + "'")
      }

      if canonical != none and spec != none {
        if not fn-arity-ok(spec, args.len()) {
          if type(spec.arity) == int {
            panic(
              "cas-parse: '" + canonical + "' expects " + str(spec.arity)
              + " argument(s), got " + str(args.len())
            )
          }
          if type(spec.arity) == str and spec.arity == "variadic" {
            let minc = fn-arity-min(spec)
            panic(
              "cas-parse: '" + canonical + "' expects at least "
              + str(minc) + " argument(s), got " + str(args.len())
            )
          }
          panic("cas-parse: arity mismatch for '" + canonical + "'")
        }
        return (func(canonical, ..args), q)
      }
      return (func(name, ..args), q)
    }

    if name == "pi" { return (const-pi, pos + 1) }
    if name == "e" { return (const-e, pos + 1) }
    if name == "i" { return (const-expr("i"), pos + 1) }
    // Philosophy exception: bare C is reserved as the integration constant.
    if name == "C" { return (const-expr("C"), pos + 1) }

    return (cvar(name), pos + 1)
  }

  panic("cas-parse: unexpected token " + repr(tok))
}

#let _parse-power(tokens, pos, p) = {
  let (b, q) = _parse-atom(tokens, pos, p)
  if _is-op(tokens, q, "^") {
    let (e, q2) = (p.unary)(tokens, q + 1, p)
    return (pow(b, e), q2)
  }
  (b, q)
}

#let _parse-unary(tokens, pos, p) = {
  if _is-op(tokens, pos, "-") {
    let (x, q) = _parse-unary(tokens, pos + 1, p)
    if is-type(x, "num") { return (num(-x.val), q) }
    return (neg(x), q)
  }
  if _is-op(tokens, pos, "+") {
    return _parse-unary(tokens, pos + 1, p)
  }
  _parse-power(tokens, pos, p)
}

#let _starts-atom(tok) = tok != none and (tok.type == "num" or tok.type == "ident" or tok.type == "lparen")

#let _parse-term(tokens, pos, p) = {
  let (left, q) = _parse-unary(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "*") {
      let (r, q2) = _parse-unary(tokens, q + 1, p)
      left = mul(left, r)
      q = q2
      continue
    }
    if _is-op(tokens, q, "/") {
      let (r, q2) = _parse-unary(tokens, q + 1, p)
      left = cdiv(left, r)
      q = q2
      continue
    }

    let t = _peek(tokens, q)
    if _starts-atom(t) {
      let (r, q2) = _parse-power(tokens, q, p)
      left = mul(left, r)
      q = q2
      continue
    }

    break
  }
  (left, q)
}

#let _parse-expr(tokens, pos, p) = {
  let (left, q) = _parse-term(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "+") {
      let (r, q2) = _parse-term(tokens, q + 1, p)
      left = add(left, r)
      q = q2
      continue
    }
    if _is-op(tokens, q, "-") {
      let (r, q2) = _parse-term(tokens, q + 1, p)
      left = add(left, neg(r))
      q = q2
      continue
    }
    break
  }
  (left, q)
}

#let _parser = (
  expr: _parse-expr,
  term: _parse-term,
  unary: _parse-unary,
  power: _parse-power,
  atom: _parse-atom,
)

#let _content-to-source(c) = {
  if type(c) == str { return c }

  if type(c) == content {
    let f = c.func()

    if c.has("text") and type(c.text) == str {
      return c.text
    }

    if f == math.equation {
      return _content-to-source(c.body)
    }

    if f == math.frac {
      return "frac(" + _content-to-source(c.num) + "," + _content-to-source(c.denom) + ")"
    }

    if f == math.root {
      let idx = if c.has("index") { _content-to-source(c.index) } else { "2" }
      return "root(" + idx + "," + _content-to-source(c.radicand) + ")"
    }

    if f == math.attach {
      let base = _content-to-source(c.base)
      let sub = if c.has("b") { "_(" + _content-to-source(c.b) + ")" } else { "" }
      let sup = if c.has("t") { "^(" + _content-to-source(c.t) + ")" } else { "" }
      return base + sub + sup
    }

    if f == math.op {
      return _content-to-source(c.text)
    }

    if f == math.lr {
      return "(" + _content-to-source(c.body) + ")"
    }

    if c.has("children") {
      let out = ""
      for ch in c.children {
        out += _content-to-source(ch)
      }
      return out
    }

    if c.has("body") {
      return _content-to-source(c.body)
    }
  }

  ""
}

#let cas-parse(input) = {
  if type(input) == dictionary and "type" in input { return normalize-int-constant(input) }
  if type(input) == int or type(input) == float { return num(input) }

  let source = if type(input) == str { input } else if type(input) == content { _content-to-source(input) } else {
    panic("cas-parse: input must be string/content/expression")
  }

  let tokens = _tokenize(source)
  if tokens.len() == 0 { return num(0) }

  let (expr, q) = _parse-expr(tokens, 0, _parser)
  if q < tokens.len() {
    panic("cas-parse: unparsed trailing token " + repr(tokens.at(q)))
  }
  normalize-int-constant(expr)
}
