// =========================================================================
// CAS Expression Parser — Typst math string → CAS expression tree
// =========================================================================
// Parses strings like "x^2 + 3x - 1" into CAS expression trees.
// Two-phase: tokenization → recursive descent parsing.
// =========================================================================

#import "../expr.typ": *
#import "../truths/function-registry.typ": fn-canonical, fn-spec

// =========================================================================
// Phase 1: Tokenizer
// =========================================================================

/// Internal helper `_is-digit`.
#let _is-digit(c) = c >= "0" and c <= "9"

/// Internal helper `_is-alpha`.
#let _is-alpha(c) = {
  let code = str.to-unicode(c)
  (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
}

/// Internal helper `_is-ident-start`.
#let _is-ident-start(c) = _is-alpha(c)

/// Internal helper `_is-ident-char`.
#let _is-ident-char(c) = _is-alpha(c) or _is-digit(c)

/// Internal helper `_tokenize`.
#let _tokenize(s) = {
  let tokens = ()
  let chars = s.clusters()
  let i = 0
  let len = chars.len()

  while i < len {
    let c = chars.at(i)

    // Skip whitespace
    if c == " " or c == "\t" or c == "\n" {
      i += 1
      continue
    }

    // Numbers
    if _is-digit(c) {
      let start = i
      while i < len and _is-digit(chars.at(i)) { i += 1 }
      if i < len and chars.at(i) == "." {
        i += 1
        while i < len and _is-digit(chars.at(i)) { i += 1 }
      }
      tokens.push((type: "num", val: chars.slice(start, i).join()))
      continue
    }

    // Identifiers
    if _is-ident-start(c) {
      let start = i
      while i < len and _is-ident-char(chars.at(i)) { i += 1 }
      tokens.push((type: "ident", val: chars.slice(start, i).join()))
      continue
    }

    if c == "+" or c == "-" or c == "*" or c == "/" or c == "^" or c == "_" or c == "=" or c == "\u{2212}" {
      let val = if c == "\u{2212}" { "-" } else { c }
      tokens.push((type: "op", val: val))
      i += 1
      continue
    }

    // Symbols (from content)
    if c == "π" {
      tokens.push((type: "ident", val: "pi"))
      i += 1
      continue
    }
    if c == "∑" {
      tokens.push((type: "ident", val: "sum"))
      i += 1
      continue
    }
    if c == "∏" {
      tokens.push((type: "ident", val: "product"))
      i += 1
      continue
    }
    if c == "∫" {
      tokens.push((type: "ident", val: "integral"))
      i += 1
      continue
    }
    if c == "∞" {
      tokens.push((type: "ident", val: "infinity"))
      i += 1
      continue
    }
    if c == "∂" {
      tokens.push((type: "ident", val: "diff"))
      i += 1
      continue
    }
    if c == "(" {
      tokens.push((type: "lparen", val: "("))
      i += 1
      continue
    }
    if c == ")" {
      tokens.push((type: "rparen", val: ")"))
      i += 1
      continue
    }
    if c == "," {
      tokens.push((type: "comma", val: ","))
      i += 1
      continue
    }

    i += 1 // skip unknown
  }
  tokens
}

// =========================================================================
// Phase 2: Recursive Descent Parser
// =========================================================================

/// Internal helper `_pk`.
#let _pk(tokens, pos) = if pos < tokens.len() { tokens.at(pos) } else { none }

/// Internal helper `_is-op`.
#let _is-op(tokens, pos, v) = {
  let t = _pk(tokens, pos)
  t != none and t.type == "op" and t.val == v
}

/// Internal helper `_numval`.
#let _numval(s) = if s.contains(".") { float(s) } else { int(s) }

/// Internal helper `_subscript-piece`.
/// Convert a parsed subscript atom to a safe variable-name suffix.
#let _subscript-piece(expr) = {
  if is-type(expr, "num") {
    if type(expr.val) == int { return str(expr.val) }
    if calc.abs(expr.val - calc.round(expr.val)) < 1e-10 {
      return str(int(calc.round(expr.val)))
    }
    return none
  }
  if is-type(expr, "var") or is-type(expr, "const") {
    return expr.name
  }
  if is-type(expr, "neg") and is-type(expr.arg, "num") {
    if type(expr.arg.val) == int {
      return "-" + str(expr.arg.val)
    }
  }
  none
}

/// Internal helper `_bind-index-symbol`.
/// Rebinds occurrences of a bound index symbol parsed as a constant
/// (notably `i`) back to a variable inside sum/product bodies.
#let _bind-index-symbol(expr, idx) = {
  if is-type(expr, "num") or is-type(expr, "var") {
    return expr
  }
  if is-type(expr, "const") {
    if expr.name == idx { return cvar(idx) }
    return expr
  }
  if is-type(expr, "neg") {
    return neg(_bind-index-symbol(expr.arg, idx))
  }
  if is-type(expr, "add") {
    return add(_bind-index-symbol(expr.args.at(0), idx), _bind-index-symbol(expr.args.at(1), idx))
  }
  if is-type(expr, "mul") {
    return mul(_bind-index-symbol(expr.args.at(0), idx), _bind-index-symbol(expr.args.at(1), idx))
  }
  if is-type(expr, "div") {
    return cdiv(_bind-index-symbol(expr.num, idx), _bind-index-symbol(expr.den, idx))
  }
  if is-type(expr, "pow") {
    return pow(_bind-index-symbol(expr.base, idx), _bind-index-symbol(expr.exp, idx))
  }
  if is-type(expr, "func") {
    let args = func-args(expr).map(a => _bind-index-symbol(a, idx))
    return func(expr.name, ..args)
  }
  if is-type(expr, "log") {
    return log-of(_bind-index-symbol(expr.base, idx), _bind-index-symbol(expr.arg, idx))
  }
  if is-type(expr, "sum") {
    return csum(
      _bind-index-symbol(expr.body, idx),
      expr.idx,
      _bind-index-symbol(expr.from, idx),
      _bind-index-symbol(expr.to, idx),
    )
  }
  if is-type(expr, "prod") {
    return cprod(
      _bind-index-symbol(expr.body, idx),
      expr.idx,
      _bind-index-symbol(expr.from, idx),
      _bind-index-symbol(expr.to, idx),
    )
  }
  expr
}

// All parser functions take `p` dict as last arg for mutual recursion.
// p.expr, p.term, p.unary, p.power, p.atom

/// Internal helper `_parse-call-args`.
/// Parses comma-separated arguments after a function name.
/// Expects `pos` to point at the opening `(` token.
#let _parse-call-args(tokens, pos, p) = {
  if _pk(tokens, pos) == none or _pk(tokens, pos).type != "lparen" { return (none, pos) }
  let q = pos + 1
  let args = ()
  if _pk(tokens, q) != none and _pk(tokens, q).type == "rparen" {
    return (args, q + 1)
  }
  while q < tokens.len() {
    let (arg, q1) = (p.expr)(tokens, q, p)
    args.push(arg)
    q = q1
    let t = _pk(tokens, q)
    if t != none and t.type == "comma" {
      q += 1
      continue
    }
    if t != none and t.type == "rparen" {
      q += 1
      return (args, q)
    }
    return (none, q)
  }
  (none, q)
}

/// Internal helper `_parse-atom`.
#let _parse-atom(tokens, pos, p) = {
  let tok = _pk(tokens, pos)
  if tok == none {
    panic("cas-parse: unexpected end of input")
  }

  if tok.type == "num" { return (num(_numval(tok.val)), pos + 1) }

  if tok.type == "lparen" {
    let (inner, q) = (p.expr)(tokens, pos + 1, p)
    if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
    return (inner, q)
  }

  if tok.type == "ident" {
    let name = tok.val
    let next = _pk(tokens, pos + 1)

    // log2(x), log10(x) shorthand
    if name == "log" and next != none and next.type == "num" {
      let base-num = next.val
      let after-base = _pk(tokens, pos + 2)
      if (base-num == "2" or base-num == "10") and after-base != none and after-base.type == "lparen" {
        let (arg, q) = (p.expr)(tokens, pos + 3, p)
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (func("log" + base-num, arg), q)
      }
    }

    // Sum/Product: sum_(k=1)^n expr
    if name == "sum" or name == "product" {
      if _is-op(tokens, pos + 1, "_") {
        let q = pos + 2
        // Expect '('
        let t1 = _pk(tokens, q)
        if t1 == none or t1.type != "lparen" { return (num(0), q) } // Error (advance q)
        q += 1

        // var
        let (var-expr, q2) = (p.atom)(tokens, q, p)

        // Extract var name checking for var OR const (e.g. "i")
        let var-name = none
        if is-type(var-expr, "var") {
          var-name = var-expr.name
        } else if is-type(var-expr, "const") {
          var-name = var-expr.name
        } else {
          // Error but consume tokens to avoid loop
          return (num(0), q2)
        }
        q = q2

        // =
        if not _is-op(tokens, q, "=") { return (num(0), pos) } // Error
        q += 1

        // start
        let (start, q3) = (p.expr)(tokens, q, p)
        q = q3

        // )
        if _pk(tokens, q).type != "rparen" { return (num(0), pos) } // Error
        q += 1

        // ^
        if not _is-op(tokens, q, "^") { return (num(0), pos) } // Error
        q += 1

        // end (parse as unary to allow -1, or power?)
        // upper bound is usually an atom or power. let's use unary to be safe?
        // Actually, ^(n+1) is atom (parens). ^n is atom.
        // Let's use p.power (for ^n^2?) or p.unary.
        let (end, q4) = (p.power)(tokens, q, p)
        q = q4

        // body (binds tightly? sum x + 1 -> (sum x) + 1)
        // So parse power.
        let (body-raw, q5) = (p.power)(tokens, q, p)
        let body = _bind-index-symbol(body-raw, var-name)

        let result = if name == "sum" {
          csum(body, var-name, start, end)
        } else {
          cprod(body, var-name, start, end)
        }
        return (result, q5)
      }
    }

    // Check for subscript: log_b(x)
    if name == "log" and _is-op(tokens, pos + 1, "_") {
      let (base, q) = (p.atom)(tokens, pos + 2, p)
      // Expect '(' next
      let next-tok = _pk(tokens, q)
      if next-tok != none and next-tok.type == "lparen" {
        let (arg, q2) = (p.expr)(tokens, q + 1, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (log-of(base, arg), q2)
      }
      // If no '(', treat next atom as arg (log_2 x)
      let (arg, q2) = (p.atom)(tokens, q, p)
      return (log-of(base, arg), q2)
    }

    // Generic variable subscript: x_1, a_i, theta_n.
    // Keep special underscore semantics above for log/sum/product.
    if name != "sum" and name != "product" and name != "log" and _is-op(tokens, pos + 1, "_") {
      let (sub-atom, q) = (p.atom)(tokens, pos + 2, p)
      let suffix = _subscript-piece(sub-atom)
      if suffix != none and suffix != "" {
        return (cvar(name + "_" + suffix), q)
      }
      // Malformed/unsupported subscript suffix: consume base token only.
      return (cvar(name), pos + 1)
    }

    // Implicit unary function application with optional exponent:
    // sec^2 x -> (sec(x))^2, ln x -> ln(x)
    // Compatibility: log x => ln(x)
    if name == "log" and not (next != none and next.type == "lparen") {
      let q = pos + 1
      let arg-tok = _pk(tokens, q)
      if arg-tok != none and (arg-tok.type == "num" or arg-tok.type == "ident" or arg-tok.type == "lparen") {
        let (arg, q2) = (p.power)(tokens, q, p)
        return (func("ln", arg), q2)
      }
    }

    let canonical = fn-canonical(name)
    let spec = fn-spec(name)
    if canonical != none and spec != none and spec.arity == 1 and spec.parse.allow-implicit and not (next != none and next.type == "lparen") {
      let q = pos + 1
      let fn-exp = none
      if spec.parse.allow-power-prefix and _is-op(tokens, q, "^") {
        let (exp, q1) = (p.unary)(tokens, q + 1, p)
        fn-exp = exp
        q = q1
      }
      let arg-tok = _pk(tokens, q)
      if arg-tok != none and (arg-tok.type == "num" or arg-tok.type == "ident" or arg-tok.type == "lparen") {
        let (arg, q2) = (p.power)(tokens, q, p)
        let base-fn = func(canonical, arg)
        if fn-exp != none {
          return (pow(base-fn, fn-exp), q2)
        }
        return (base-fn, q2)
      }
    }

    // Function call (ident followed by '(')
    if next != none and next.type == "lparen" {
      if name == "frac" {
        let (n, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" { q += 1 }
        let (d, q2) = (p.expr)(tokens, q, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (cdiv(n, d), q2)
      }
      if name == "sqrt" {
        let (arg, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (pow(arg, cdiv(num(1), num(2))), q)
      }
      if name == "root" {
        // root(index, x)
        let (index, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" { q += 1 }
        let (arg, q2) = (p.expr)(tokens, q, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (pow(arg, cdiv(num(1), index)), q2)
      }
      if name == "log" {
        let (first, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" {
          q += 1
          let (second, q2) = (p.expr)(tokens, q, p)
          if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
          return (log-of(first, second), q2)
        }
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (func("ln", first), q)
      }

      let (args, q) = _parse-call-args(tokens, pos + 1, p)
      if args == none {
        // Ensure forward progress for malformed function-call syntax.
        return (num(0), calc.max(q, pos + 1))
      }

      let canonical = fn-canonical(name)
      let spec = fn-spec(name)
      if canonical != none and spec != none {
        // Keep canonical form even on arity mismatch so parsing is stable.
        return (func(canonical, ..args), q)
      }

      // Unknown function names stay as symbolic function calls.
      return (func(name, ..args), q)
    }

    // Constants
    if name == "pi" { return (const-pi, pos + 1) }
    if name == "e" { return (const-e, pos + 1) }
    // Reserve lowercase i for potential imaginary unit support.
    if name == "i" { return (const-expr("i"), pos + 1) }


    return (cvar(name), pos + 1)
  }

  panic("cas-parse: unexpected token " + repr(tok))
}

/// Internal helper `_parse-power`.
#let _parse-power(tokens, pos, p) = {
  let (base, q) = _parse-atom(tokens, pos, p)
  if _is-op(tokens, q, "^") {
    let (exp, q2) = (p.unary)(tokens, q + 1, p)
    return (pow(base, exp), q2)
  }
  (base, q)
}

/// Internal helper `_parse-unary`.
#let _parse-unary(tokens, pos, p) = {
  if _is-op(tokens, pos, "-") {
    let (operand, q) = _parse-unary(tokens, pos + 1, p)
    if is-type(operand, "num") { return (num(-operand.val), q) }
    return (neg(operand), q)
  }
  if _is-op(tokens, pos, "+") {
    return _parse-unary(tokens, pos + 1, p)
  }
  _parse-power(tokens, pos, p)
}

/// Internal helper `_parse-term`.
#let _parse-term(tokens, pos, p) = {
  let (result, q) = _parse-unary(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "*") {
      let (right, q2) = _parse-unary(tokens, q + 1, p)
      if q2 <= q { break }
      result = mul(result, right)
      q = q2
      continue
    }
    if _is-op(tokens, q, "/") {
      let (right, q2) = _parse-unary(tokens, q + 1, p)
      if q2 <= q { break }
      result = cdiv(result, right)
      q = q2
      continue
    }
    // Implicit multiplication
    let tok = _pk(tokens, q)
    if tok.type == "num" or tok.type == "ident" or tok.type == "lparen" {
      let (right, q2) = _parse-power(tokens, q, p)
      if q2 <= q { break }
      result = mul(result, right)
      q = q2
      continue
    }
    break
  }
  (result, q)
}

/// Internal helper `_parse-expr`.
#let _parse-expr(tokens, pos, p) = {
  let (result, q) = _parse-term(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "+") {
      let (right, q2) = _parse-term(tokens, q + 1, p)
      if q2 <= q { break }
      result = add(result, right)
      q = q2
      continue
    }
    if _is-op(tokens, q, "-") {
      let (right, q2) = _parse-term(tokens, q + 1, p)
      if q2 <= q { break }
      if is-type(right, "num") { result = add(result, num(-right.val)) } else { result = add(result, neg(right)) }
      q = q2
      continue
    }
    break
  }
  (result, q)
}

// Build the parser dict with all functions referencing each other
/// Internal helper `_parser`.
#let _parser = (
  expr: _parse-expr,
  term: _parse-term,
  unary: _parse-unary,
  power: _parse-power,
  atom: _parse-atom,
)

// =========================================================================
// Content Tokenizer (De-structuring)
// =========================================================================

/// Internal helper `_tokenize-content`.
#let _tokenize-content(c) = {
  let tokens = ()

  // Base case: String
  if type(c) == str {
    return _tokenize(c)
  }

  if type(c) == content {
    let func = c.func()

    // 1. Text element (leaf)
    if c.has("text") and type(c.text) == str {
      return _tokenize(c.text)
    }

    // 2. Math Equation ($...$)
    if func == math.equation {
      return _tokenize-content(c.body)
    }

    // 3. Styled wrapper (e.g., math.italic variable glyphs)
    if c.has("child") and repr(func).contains("styled") {
      return _tokenize-content(c.child)
    }

    // 4. Fractions ($x/y$ or $frac(x, y)$)
    if func == math.frac {
      tokens.push((type: "ident", val: "frac"))
      tokens.push((type: "lparen", val: "("))
      tokens += _tokenize-content(c.num)
      tokens.push((type: "comma", val: ","))
      tokens += _tokenize-content(c.denom)
      tokens.push((type: "rparen", val: ")"))
      return tokens
    }

    // 5. Attachments ($x^2$, $x_i$, $sum^n_k$)
    if func == math.attach {
      tokens += _tokenize-content(c.base)
      if c.has("b") {
        // subscript -> _( ... )
        tokens.push((type: "op", val: "_"))
        tokens.push((type: "lparen", val: "("))
        tokens += _tokenize-content(c.b)
        tokens.push((type: "rparen", val: ")"))
      }
      if c.has("t") {
        // superscript -> ^( ... )
        tokens.push((type: "op", val: "^"))
        tokens.push((type: "lparen", val: "("))
        tokens += _tokenize-content(c.t)
        tokens.push((type: "rparen", val: ")"))
      }
      return tokens
    }

    // 6. Roots ($sqrt(x)$, $root(3, x)$)
    if func == math.root {
      // index is optional. If missing, it's sqrt (index 2).
      // Map to root(index, radicand) string syntax.
      tokens.push((type: "ident", val: "root"))
      tokens.push((type: "lparen", val: "("))
      if c.has("index") {
        tokens += _tokenize-content(c.index)
      } else {
        tokens.push((type: "num", val: "2"))
      }
      tokens.push((type: "comma", val: ","))
      tokens += _tokenize-content(c.radicand)
      tokens.push((type: "rparen", val: ")"))
      return tokens
    }

    // 7. Math Operator (Custom functions/Op)
    if func == math.op {
      return _tokenize-content(c.text)
    }

    // 8. LR grouping (parentheses)
    if func == math.lr {
      return _tokenize-content(c.body)
    }

    // 9. Math class elements (operators like +, −, ⋅)
    // Typst wraps math operators in math.class with a "class" field
    if func == math.class {
      // The body contains the operator glyph
      let body-tokens = _tokenize-content(c.body)
      // If it produced an ident like "minus", map to op
      if body-tokens.len() == 0 {
        // Try repr-based fallback for operator glyphs
        let r = repr(c.body)
        if r.contains("−") or r.contains("minus") {
          return ((type: "op", val: "-"),)
        }
        if r.contains("+") {
          return ((type: "op", val: "+"),)
        }
        if r.contains("⋅") or r.contains("dot.op") {
          return ((type: "op", val: "*"),)
        }
        if r.contains("×") or r.contains("times") {
          return ((type: "op", val: "*"),)
        }
      }
      return body-tokens
    }

    // 10. Space (ignore)
    if repr(func) == "space" { return () }

    // 11. Sequence ([a, b] or $a b$ or {a; b})
    // Keep this fallback AFTER math-specific handlers so we don't lose
    // structure like superscripts/subscripts on math.attach nodes.
    if c.has("children") {
      for child in c.children {
        tokens += _tokenize-content(child)
      }
      return tokens
    }

    // 12. Symbol element — check for operator symbols
    let r = repr(c)
    if r.contains("−") or r.contains("minus") {
      return ((type: "op", val: "-"),)
    }
    if r.contains("⋅") or r.contains("dot.op") {
      return ((type: "op", val: "*"),)
    }
    if r.contains("×") or r.contains("times") {
      return ((type: "op", val: "*"),)
    }

    // Fallback: try to see if it has body?
    if c.has("body") {
      return _tokenize-content(c.body)
    }
  }

  tokens
}

// =========================================================================
// Public API
// =========================================================================

/// Parse a Typst math string OR content into a CAS expression tree.
///
/// ```typst
/// #let expr = cas-parse("x^2 + 3x - 1")
/// #let expr2 = cas-parse($x^2 + frac(1, 2)$)
/// $ #cas-display(expr) $   // x² + 3x − 1
/// ```
#let cas-parse(input) = {
  if type(input) == dictionary and "type" in input { return input }
  if type(input) == int or type(input) == float { return num(input) }
  let tokens = ()
  if type(input) == str {
    tokens = _tokenize(input)
  } else if type(input) == content {
    tokens = _tokenize-content(input)
  } else {
    panic("cas-parse: input must be string or content (math)")
  }

  if tokens.len() == 0 { return num(0) }
  let (result, end) = _parse-expr(tokens, 0, _parser)
  if end < tokens.len() {
    panic("cas-parse: unparsed trailing tokens starting at " + repr(tokens.at(end)))
  }
  result
}
